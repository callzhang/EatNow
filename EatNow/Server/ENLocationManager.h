//
//  ENLocationManager.h
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENServer.h"
#import "INTULocationManager.h"
#import "GCDSingleton.h"

@interface ENLocationManager : NSObject
@property (nonatomic, assign) ENLocationStatus locationStatus;
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENLocationManager)
- (void)getLocationWithCompletion:(void (^)(CLLocation *location, INTULocationAccuracy achievedAccuracy, INTULocationStatus status))completion;
- (void)getLocationWithCompletion:(void (^)(CLLocation *location, INTULocationAccuracy achievedAccuracy, INTULocationStatus status))completion forece:(BOOL)forceUpdate;

/**
 *  return last fetched current location, if any.
 */
+ (CLLocation *)cachedCurrentLocation;

+ (void)registerLocationDeniedHandler:(void(^)(void))handler;
+ (void)registerLocationDisabledHanlder:(void (^)(void))handler;

+ (INTULocationServicesState)locationServicesState;
@end
