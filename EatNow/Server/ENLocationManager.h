//
//  ENLocationManager.h
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENServer.h"
@import CoreLocation;

@interface ENLocationManager : NSObject
@property (nonatomic, assign) ENLocationStatus locationStatus;

- (void)getLocationWithCompletion:(void (^)(CLLocation *location))completion;
- (void)getLocationWithCompletion:(void (^)(CLLocation *location))completion forece:(BOOL)forceUpdate;

/**
 *  return last fetched current location, if any.
 */
+ (CLLocation *)cachedCurrentLocation;

+ (void)registerLocationDeniedHandler:(void(^)(void))handler;
+ (void)registerLocationDisabledHanlder:(void (^)(void))handler;
@end
