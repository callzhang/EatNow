//
//  ENLocationReporter.m
//  EatNow
//
//  Created by GaoYongqing on 1/17/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import "ENLocationReporter.h"
#import "ENServerManager.h"
#import <CoreLocation/CoreLocation.h>

@interface ENLocationReporter () <CLLocationManagerDelegate>

@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation ENLocationReporter

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENLocationReporter)

- (void)startMonitor
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    
    [_locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitor
{
    if (self.locationManager) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    [[ENServerManager shared] updateLocation:lastLocation completion:^(NSError *error) {
        if (error) {
            DDLogError(@"update location error = %@",error);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DDLogError(@"locationManager failed = %@",error);
}

@end
