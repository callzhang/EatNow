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
            if (self.lastUpdatedLocationDate.timeIntervalSinceNow < 60) {
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
	//request
    @weakify(self);
    [self.locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse timeout:10 delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
		
        @strongify(self);
		//update location
		self.currentLocation = currentLocation;
		if (status == INTULocationStatusSuccess) {
			DDLogVerbose(@"Location aquired");
			self.locationStatus = ENLocationStatusGotLocation;
		}
		else if (status == INTULocationStatusTimedOut){
			DDLogVerbose(@"Use best location at timeout");
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
			if (!currentLocation) {
				DDLogWarn(@"Failed location request: %ld", (long)status);
				static NSInteger locationRetryCount;
				if (locationRetryCount < 5) {
					locationRetryCount++;
					DDLogWarn(@"Retrying location for the %@th time", @(locationRetryCount));
					[self getLocationWithCompletion:completion forece:forceUpdate];
					return;
				}
			}
		}
		else{
			self.locationStatus = ENLocationStatusUnknown;
			DDLogWarn(@"Unexpected location status: %ld", (long)status);
		}
		
		if (completion) {
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
