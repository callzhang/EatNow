//
//  ENLocationManager.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENLocationManager.h"
#import "FBKVOController.h"
#import "extobjc.h"
#import "NSTimer+BlocksKit.h"


static CLLocation *_cachedCurrentLocation = nil;
static void (^_locationDisabledHanlder)(void) = nil;
static void (^_locationDeniedHanlder)(void) = nil;

@interface ENLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) INTULocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDate *lastUpdatedLocationDate;
@property (nonatomic, assign) INTULocationAccuracy achievedAccuracy;
@property (nonatomic, strong) NSMutableArray *completionBlocks;
@property (nonatomic, assign) INTULocationRequestID request;
@property (nonatomic, strong) NSDate *requestTime;
@end

@implementation ENLocationManager
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENLocationManager)
- (instancetype)init{
    self = [super init];
    if (self) {
        self.completionBlocks = [NSMutableArray array];
        self.locationManager = [INTULocationManager sharedInstance];
    }
    return self;
}

- (void)getLocationWithCompletion:(ENLocationCompletionBlock)completion {
    [self getLocationWithCompletion:completion forece:NO];
}

+ (INTULocationServicesState)locationServicesState{
    return [INTULocationManager locationServicesState];
}

- (void)getLocationWithCompletion:(ENLocationCompletionBlock)completion forece:(BOOL)forceUpdate {
    if (!forceUpdate) {
        if (self.currentLocation) {
            if (self.lastUpdatedLocationDate.timeIntervalSinceNow < kENLocationMinimumInterval) {
                [self.completionBlocks addObject:completion];
                [self completeLocationRequest];
            }
            else {
                self.currentLocation = nil;
                [self getLocationWithCompletion:completion];
            }
            return;
        }
    }
    
    if (self.request) {
        DDLogWarn(@"Already requesting location");
        [self.completionBlocks addObject:completion];
        return;
    }
    
	//status
	self.locationStatus = ENLocationStatusGettingLocation;
    DDLogVerbose(@"Getting location");
    self.requestTime = [NSDate date];
    
	//request
    @weakify(self);
    
    self.request = [self.locationManager subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        @strongify(self);
		//update location
        if (achievedAccuracy > self.achievedAccuracy) {
            self.achievedAccuracy = achievedAccuracy;
            self.currentLocation = currentLocation;
            [self completeLocationRequest];
        }
		if (status == INTULocationStatusSuccess) {
			DDLogVerbose(@"Location aquired");
            self.locationStatus = ENLocationStatusGotLocation;
            [self completeLocationRequest];
		}
		else if (status == INTULocationStatusTimedOut){
			DDLogInfo(@"Use best location at timeout");
			self.locationStatus = ENLocationStatusGotLocation;
		}
		else if (status == INTULocationStatusServicesDisabled){
			self.locationStatus = ENLocationStatusError;
			if (_locationDisabledHanlder) {
				_locationDisabledHanlder();
			}
		}
		else if (status == INTULocationStatusServicesDenied || status == INTULocationStatusServicesRestricted){
			self.locationStatus = ENLocationStatusError;
			if (_locationDeniedHanlder) {
				_locationDeniedHanlder();
			}
		}
		else if (status == INTULocationStatusError){
            self.locationStatus = ENLocationStatusError;
            DDLogWarn(@"Failed location request but will retry");
		}
		else{
			self.locationStatus = ENLocationStatusUnknown;
			DDLogError(@"Unexpected location status: %ld", (long)status);
		}
	}];
    
    [NSTimer bk_scheduledTimerWithTimeInterval:kENLocationRequestTimeout block:^(NSTimer *timer) {
        [self.locationManager forceCompleteLocationRequest:self.request];
        [self completeLocationRequest];
    } repeats:NO];
}

- (void)completeLocationRequest{
    for (ENLocationCompletionBlock block in self.completionBlocks) {
        block(self.currentLocation, self.achievedAccuracy, self.locationStatus);
    }
    [self.completionBlocks removeAllObjects];
    [self.locationManager cancelLocationRequest:self.request];
    self.request = 0;
    DDLogInfo(@"It took %.0fs to get location", [[NSDate date] timeIntervalSinceDate:self.requestTime]);
}

- (void)cancelLocationRequest{
    [self.locationManager forceCompleteLocationRequest:self.request];
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    _currentLocation = currentLocation;
    if (_currentLocation) {
		_cachedCurrentLocation = _currentLocation;
		self.locationStatus = ENLocationStatusGotLocation;
		//update time
		self.lastUpdatedLocationDate = [NSDate date];
    }
}

+ (CLLocation *)cachedCurrentLocation {
    return _cachedCurrentLocation;
}

+ (void)registerLocationDeniedHandler:(void (^)(void))handler {
    _locationDeniedHanlder = handler;
}

+ (void)registerLocationDisabledHanlder:(void (^)(void))handler {
    _locationDisabledHanlder = handler;
}
@end
