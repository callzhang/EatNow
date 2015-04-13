//
//  ENServerManager.m
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#import "ENServerManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Restaurant.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FBKVOController.h"

@import CoreLocation;

@interface ENServerManager()<CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;
@property (nonatomic, strong) NSMutableArray *completionGroup;
@end


@implementation ENServerManager
//+ (instancetype)sharedInstance{
//    static ENServerManager *manager;
//    if (!manager) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            manager = [ENServerManager new];
//        });
//    }
//    return manager;
//}

- (ENServerManager *)init{
    self = [super init];
    if (self) {
        
        _restaurants = [NSMutableArray new];
        _completionGroup = [NSMutableArray new];
        
        //indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
		
        /**
		//reachability
		self.reachability = [AFNetworkReachabilityManager sharedManager];
		[self.reachability startMonitoring];
		__block ENServerManager *weakManager = self;
		[self.reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
			switch (status) {
				case AFNetworkReachabilityStatusUnknown:{
					weakManager.status |= DeterminReachability;
					weakManager.status &= ~IsReachable;
				}
					break;
				case AFNetworkReachabilityStatusNotReachable:{
					weakManager.status &= ~DeterminReachability;
					weakManager.status &= ~IsReachable;
				}
					break;

				default:{
					weakManager.status &= ~DeterminReachability;
					weakManager.status |= IsReachable;
				}
					break;
			}
		}];
         **/
    }
    return self;
}

#pragma mark - Main method

- (void)getRestaurantsAtLocation:(CLLocation *)currenLocation WithCompletion:(void (^)(BOOL success, NSError *error, NSArray *response))block{
    //add to completion block
    [self.completionGroup addObject:block];
    
    if (self.fetchStatus == ENResturantDataStatusFetchingRestaurant) {
        DDLogInfo(@"Already requesting restaurant.");
        return;
    }
    
    self.fetchStatus = ENResturantDataStatusFetchingRestaurant;
    
    DDLogVerbose(@"Start requesting restaurants");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *myID = [[self class] myUUID];
    NSDictionary *dic = @{@"username":myID,
                          @"latitude":@(currenLocation.coordinate.latitude),
                          @"longitude":@(currenLocation.coordinate.longitude)//,
                          //@"radius":@500
                          };
    DDLogInfo(@"Request restaurant: %@", dic);
    [manager GET:kSearchUrl parameters:dic
          success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
              DDLogVerbose(@"GET restaurant list %ld", (unsigned long)responseObject.count);
              TIC
              NSMutableArray *mutableResturants = [NSMutableArray array];
              for (NSDictionary *restaurant_json in responseObject) {
                  Restaurant *restaurant = [Restaurant new];
                  
                  restaurant.ID = restaurant_json[@"id"];
                  restaurant.url = restaurant_json[@"url"];
                  restaurant.rating = (NSNumber *)restaurant_json[@"rating"];
                  restaurant.reviews = (NSNumber *)restaurant_json[@"ratingSignals"];
                  NSArray *list = restaurant_json[@"categories"];
                  restaurant.cuisines = [list valueForKey:@"shortName"];
                  restaurant.imageUrls = restaurant_json[@"food_image_url"];
                  restaurant.phone = [restaurant_json valueForKeyPath:@"contact.formattedPhone"];
                  restaurant.name = restaurant_json[@"name"];
                  restaurant.price = restaurant_json[@"price"];
                  //location
                  NSDictionary *address = restaurant_json[@"location"];
                  CLLocationDegrees lat = [(NSNumber *)address[@"lat"] doubleValue];
                  CLLocationDegrees lon = [(NSNumber *)address[@"lng"] doubleValue];
                  CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                  restaurant.location = loc;
                  restaurant.distance = [(NSNumber *)address[@"distance"] doubleValue]/1000;
                  if (!restaurant.distance) {
                      restaurant.distance = [currenLocation distanceFromLocation:restaurant.location]/1000;
                  }
                  restaurant.json = restaurant_json;
                  //score
                  NSDictionary *scores = restaurant_json[@"score"];
                  NSNumber *totalScore = scores[@"total_score"];
                  if ([totalScore isEqual: [NSNull null]]) {
                      NSString *str = [NSString stringWithFormat:@"Returned null score (ID = %@", restaurant.ID];
//						  ENAlert(str);
                      DDLogError(@"error:%@", str);
                      NSNumber *commentScore = scores[@"comment_score"] != [NSNull null] ? scores[@"comment_score"]:@0;
                      NSNumber *cuisineScore = scores[@"cuisine_score"] != [NSNull null] ? scores[@"cuisine_score"]:@0;
                      NSNumber *distanceScore = scores[@"distance_score"] != [NSNull null] ? scores[@"distance_score"]:@0;
                      NSNumber *priceScore = scores[@"price_score"] != [NSNull null] ? scores[@"price_score"]:@0;
                      NSNumber *ratingScore = scores[@"rating_score"] != [NSNull null] ? scores[@"rating_score"]:@0;
                      totalScore = @(commentScore.floatValue + cuisineScore.floatValue + distanceScore.floatValue + priceScore.floatValue + ratingScore.floatValue);
                  }
                  restaurant.score = totalScore;
                  
                  
                  if ([restaurant validate]) {
                      [mutableResturants addObject:restaurant];
                  }
              }
              
              TOC
              DDLogInfo(@"Processed %ld restaurant", (unsigned long)mutableResturants.count);
              
              //server returned sorted from high to low
              [mutableResturants sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
              
              
              if (self.completionGroup) {
                  for (id completion in self.completionGroup) {
                      void (^cachedCompletion)(BOOL, NSError*, NSArray*) = completion;
                      cachedCompletion(YES, nil, mutableResturants.copy);
                  }
                  
                  [self.completionGroup removeAllObjects];
              }
              
              //post notification
              self.fetchStatus = ENResturantDataStatusFetchedRestaurant;
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSString *str = [NSString stringWithFormat:@"Failed to get restaurant list with Error: %@", error];
              DDLogError(@"%@", str);
//                  ENAlert(str);
              if (block) {
                  block(NO, error, nil);
              }
              
              self.fetchStatus = ENResturantDataStatusError;
          }];
}

- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *myID = [self.class myUUID];
    NSString *url = [NSString stringWithFormat:@"%@%@",kUserUrl, myID];
    DDLogInfo(@"Requesting user: %@", url);
    [manager GET:url parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *s = [NSString stringWithFormat:@"Failed to get user: %@", error];
        DDLogError(s);
        block(nil, error);
    }];
}

- (void)selectRestaurant:(Restaurant *)restaurant like:(NSInteger)value completion:(void (^)(NSError *error))block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *myID = [[self class] myUUID];
    NSDictionary *dic = @{@"username": myID, @"restaurant": restaurant.json, @"like": @(value)};
    DDLogVerbose(@"Select restaurant: %@", dic);
    [manager POST:kEatUrl parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
        NSString *s = [NSString stringWithFormat:@"%@", error];
        DDLogError(s);
    }];
}

+ (NSString *)myUUID{
    NSString *myID = [[NSUserDefaults standardUserDefaults] objectForKey:kUUID];
    if (!myID) {
        myID = [self generateUUID];
        [[NSUserDefaults standardUserDefaults] setObject:myID forKey:kUUID];
    }
    return myID;
}

+ (NSString *)generateUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return (__bridge NSString *)string;
}

#pragma mark - Tools
- (NSArray *)cuisines{
    if (!_cuisines) {
        _cuisines = [kCuisineNames componentsSeparatedByString:@","];
    }
    
    return _cuisines;
}

@end
