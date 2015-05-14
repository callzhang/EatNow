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


static CLLocation *_cachedCurrentLocation = nil;
static void (^_locationDisabledHanlder)(void) = nil;
static void (^_locationDeniedHanlder)(void) = nil;

@interface ENLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, readonly) INTULocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDate *lastUpdatedLocationDate;
@end

@implementation ENLocationManager
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENLocationManager)
- (INTULocationManager *)locationManager {
    return [INTULocationManager sharedInstance];
}

+ (INTULocationServicesState)locationServicesState {
    return [INTULocationManager locationServicesState];
}

- (void)getLocationWithCompletion:(void (^)(CLLocation *location, INTULocationAccuracy achievedAccuracy, INTULocationStatus status))completion {
    [self getLocationWithCompletion:completion forece:NO];
}

- (void)getLocationWithCompletion:(void (^)(CLLocation *location, INTULocationAccuracy achievedAccuracy, INTULocationStatus status))completion forece:(BOOL)forceUpdate {
    if (!forceUpdate) {
        if (self.currentLocation) {
            if (self.lastUpdatedLocationDate.timeIntervalSinceNow < 30) {
                completion(self.currentLocation, INTULocationAccuracyHouse, INTULocationStatusSuccess);
            }
            else {
                self.currentLocation = nil;
                [self getLocationWithCompletion:^(CLLocation *location, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                    completion(location, achievedAccuracy, status);
                }];
            }
            return;
        }
    }
    
	//status
	self.locationStatus = ENLocationStatusGettingLocation;
    DDLogVerbose(@"Getting location");
    NSDate *startTime = [NSDate date];
    NSTimeInterval timeout = 10;
	//request
    @weakify(self);
    [self.locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:timeout delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
		
        @strongify(self);
		//update location
		self.currentLocation = currentLocation;
		if (status == INTULocationStatusSuccess) {
			DDLogVerbose(@"Location aquired");
			self.locationStatus = ENLocationStatusGotLocation;
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
			if ([[NSDate date] timeIntervalSinceDate:startTime] < timeout) {
				DDLogWarn(@"Failed location request but will retry");
                //[self getLocationWithCompletion:completion forece:forceUpdate];
                return;
            }else {
                self.locationStatus = ENLocationStatusError;
                DDLogWarn(@"After trying location for 5 times, still get error");
			}
		}
		else{
			self.locationStatus = ENLocationStatusUnknown;
			DDLogWarn(@"Unexpected location status: %ld", (long)status);
		}
		
		if (completion) {
            DDLogInfo(@"===> It took %.0fs to get location", [[NSDate date] timeIntervalSinceDate:startTime]);
			completion(currentLocation, achievedAccuracy, status);
		}
	}];
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
