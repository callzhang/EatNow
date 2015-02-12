//
//  ENServerManager.h
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#define kUUID                       @"UUID"
#define kSearchUrl                  @"https://dry-fortress-8563.herokuapp.com/search"

typedef NS_OPTIONS(NSInteger, ENServerManagerStatus){
	DeterminReachability = 1 << 0,
	IsReachable = 1 << 1, //opposite of not reachable
	GettingLocation = 1 << 2,
	GotLocation = 1 << 3, //opposite of failed
	FetchingRestaurant = 1 << 4,
	FetchedRestaurant = 1 << 5 //opposite of failed
};

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface ENServerManager : NSObject
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) ENServerManagerStatus status;
@property (nonatomic, strong) NSDate *lastUpdatedLocation;
+ (instancetype)sharedInstance;
- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block;
@end
