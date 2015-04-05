//
//  ENLocationManager.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENLocationManager.h"
#import "ENServerManager.h"
#import "FBKVOController.h"


static CLLocation *_cachedCurrentLocation = nil;
static void (^_locationDisabledHanlder)(void) = nil;
static void (^_locationDeniedHanlder)(void) = nil;

@interface ENLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^getLocationCompletion) (CLLocation *location);
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDate *lastUpdatedLocationDate;
@end

@implementation ENLocationManager
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    //_locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"kCLAuthorizationStatusNotDetermined");
        [_locationManager requestWhenInUseAuthorization];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusRestricted){
        //need pop alert
        NSLog(@"Location service disabled");
        if (_locationDisabledHanlder) {
            _locationDisabledHanlder();
        }
    }
    else{
        [_locationManager startUpdatingLocation];
        //add getting location trait
        self.locationStatus = ENLocationStatusGettingLocation;
#ifdef DEBUG
        //            //use default location in 10s
        //            if (_currentLocation) {
        //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //                    [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"No location obtained, using fake location" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        //                    NSLog(@"Using fake location");
        //                    _currentLocation = [[CLLocation alloc] initWithLatitude:41 longitude:-73];
        //					self.status = self.status & ~GettingLocation;
        //					self.status = self.status & GotLocation;
        //                });
        //            }
#endif
    }
}

- (void)getLocationWithCompletion:(void (^)(CLLocation *))completion {
    [self getLocationWithCompletion:completion forece:NO];
}

- (void)getLocationWithCompletion:(void (^)(CLLocation *location))completion forece:(BOOL)forceUpdate {
    if (!forceUpdate) {
        if (self.lastUpdatedLocationDate) {
            if (self.lastUpdatedLocationDate.timeIntervalSinceNow < 600) {
                completion(self.currentLocation);
            }
            else {
                self.currentLocation = nil;
                self.lastUpdatedLocationDate = nil;
                [self getLocationWithCompletion:^(CLLocation *location) {
                    completion(location);
                }];
            }
            return;
        }
    }
    
    
    //    if (!self.currentLocation || self.locationStatus == ENLocationStatusGotLocation) {
    [self.locationManager startUpdatingLocation];
    self.locationStatus = ENLocationStatusGettingLocation;
    self.getLocationCompletion = completion;
    //    }
}

#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentLocation = locations.firstObject;
    self.lastUpdatedLocationDate = [NSDate date];
    NSLog(@"Get location of %@", locations);
    [manager stopUpdatingLocation];
    self.locationStatus = ENLocationStatusGotLocation;
    
    if (self.getLocationCompletion) {
        self.getLocationCompletion(self.currentLocation);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            if (_locationDeniedHanlder) {
                _locationDeniedHanlder();
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"kCLAuthorizationStatusAuthorizedWhenInUse");
            manager.desiredAccuracy = kCLLocationAccuracyBest;
            manager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            [manager startUpdatingLocation];
            
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"kCLAuthorizationStatusAuthorizedAlways");
            manager.desiredAccuracy = kCLLocationAccuracyBest;
            manager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
            [manager startUpdatingLocation];
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"kCLAuthorizationStatusRestricted");
            break;
    }
}

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    _currentLocation = currentLocation;
    if (_currentLocation) {
        _cachedCurrentLocation = _currentLocation;
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
