//
//  ENServerManager.h
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#define kUUID                       @"UUID"
#define kSearchUrl                  @"https://dry-fortress-8563.herokuapp.com/search"
#define kFetchedRestaurantList      @"fetched_restaurant_list"
#define kUpdatedLocation            @"updated_location"

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface ENServerManager : NSObject
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) BOOL isRequesting;
@property (nonatomic, strong) NSDate *lastUpdatedLocation;
+ (instancetype)sharedInstance;
- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block;
@end
