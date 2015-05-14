//
//  ENLocationManager.h
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENServer.h"
#import "GCDSingleton.h"
#import "INTULocationManager.h"

typedef void (^ENLocationCompletionBlock)(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, ENLocationStatus status);
#define kENLocationMinimumInterval  30
#define kENLocationRequestTimeout   10

@interface ENLocationManager : NSObject
@property (nonatomic, assign) ENLocationStatus locationStatus;
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENLocationManager)
- (void)getLocationWithCompletion:(ENLocationCompletionBlock)completion;
- (void)getLocationWithCompletion:(ENLocationCompletionBlock)completion forece:(BOOL)forceUpdate;
- (void)cancelLocationRequest;

/**
 *  return last fetched current location, if any.
 */
+ (CLLocation *)cachedCurrentLocation;
+ (INTULocationServicesState)locationServicesState;

+ (void)registerLocationDeniedHandler:(void(^)(void))handler;
+ (void)registerLocationDisabledHanlder:(void (^)(void))handler;

//+ (INTULocationServicesState)locationServicesState;
@end
