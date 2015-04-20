//
//  ENServerManager.m
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#import "ENServerManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ENRestaurant.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FBKVOController.h"
#import "ENLocationManager.h"
#import "ENUtil.h"
#import "NSDate+Extension.h"

@import CoreLocation;

@interface ENServerManager()<CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;
@property (nonatomic, strong) NSMutableArray *completionGroup;
@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;
@end


@implementation ENServerManager
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENServerManager)

- (ENServerManager *)init{
    self = [super init];
    if (self) {
        
        //_restaurants = [NSMutableArray new];
        _completionGroup = [NSMutableArray new];
        
        //indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
		
		//manager
		self.requestManager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

#pragma mark - Main method
//TODO: need to cancel previous operation
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
    
    NSString *myID = [[self class] myUUID];
    NSDictionary *dic = @{@"username":myID,
                          @"latitude":@(currenLocation.coordinate.latitude),
                          @"longitude":@(currenLocation.coordinate.longitude),
						  @"time": [NSDate date].ISO8601
                          //@"radius":@500
                          };
    DDLogInfo(@"Request restaurant: %@", dic);
    NSString *path = [NSString stringWithFormat:@"%@/%@", kServerUrl, @"search"];
    [manager GET:path parameters:dic
          success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
              DDLogVerbose(@"GET restaurant list %ld", (unsigned long)responseObject.count);
              
              //process data
              NSMutableArray *mutableResturants = [NSMutableArray array];
              for (NSDictionary *restaurant_json in responseObject) {
				  ENRestaurant *restaurant = [ENRestaurant restaurantWithData:restaurant_json];
				  
                  if (restaurant) {
                      [mutableResturants addObject:restaurant];
                  }
              }
              
              DDLogInfo(@"Processed %ld restaurant", (unsigned long)mutableResturants.count);
              
              //server returned sorted from high to low
              [mutableResturants sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
              
              
              //change status
              self.fetchStatus = ENResturantDataStatusFetchedRestaurant;
              
              if (self.completionGroup) {
                  for (id completion in self.completionGroup) {
                      void (^cachedCompletion)(BOOL, NSError*, NSArray*) = completion;
                      cachedCompletion(YES, nil, mutableResturants.copy);
                  }
                  
                  [self.completionGroup removeAllObjects];
              }
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              NSString *str = [NSString stringWithFormat:@"Failed to get restaurant list with Error: %@", error];
              DDLogError(@"%@", str);
              if (block) {
                  block(NO, error, nil);
              }
              
              self.fetchStatus = ENResturantDataStatusError;
          }];
}

- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *myID = [self.class myUUID];
    NSString *url = [NSString stringWithFormat:@"%@/user/%@",kServerUrl, myID];
    DDLogInfo(@"Requesting user: %@", url);
    [manager GET:url parameters:@{} success:^(AFHTTPRequestOperation *operation, id user) {
		NSParameterAssert([user isKindOfClass:[NSDictionary class]]);
		self.me = user;
        
        //parse history rating
        NSArray *history = [user valueForKeyPath:@"user.history"];
        self.userRating = [NSMutableDictionary new];
        for (NSDictionary *data in history) {
            NSString *dateStr = data[@"date"];
            NSDate *date = [NSDate dateFromISO1861:dateStr];
            if (!date) {
                DDLogWarn(@"Date string not expected %@", dateStr);
                continue;
            }
            NSNumber *rate = data[@"like"];
            NSDictionary *restaurant = data[@"restaurant"];
            NSString *ID = restaurant[@"_id"];
            NSDictionary *ratingDic = self.userRating[ID] ?: [NSDictionary new];
            if (ratingDic.allKeys.count == 0) {
                _userRating[ID] = @{@"rating": rate, @"time":date};
            }else{
                NSDate *prevTime = ratingDic[@"time"];
                if ([prevTime compare:date] == NSOrderedAscending) {
                    //date is later
                    _userRating[ID] = @{@"rating": rate, @"time":date};
                }
            }
        }
        
        //return
        block(user, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *s = [NSString stringWithFormat:@"Failed to get user: %@", error];
        DDLogError(s);
        block(nil, error);
    }];
}

- (void)selectRestaurant:(ENRestaurant *)restaurant like:(NSInteger)value completion:(void (^)(NSError *error))block{
	NSParameterAssert(!self.selectedRestaurant);
	if (value > 0) {
		self.selectedRestaurant = restaurant;
		self.selectedTime = [NSDate date];
	}
	
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *myID = [[self class] myUUID];
    NSDictionary *dic = @{@"username": myID,
						  @"restaurantId": restaurant.ID,
						  @"like": @(value),
						  @"date": [NSDate date].ISO8601,
						  @"latitude": @([ENLocationManager cachedCurrentLocation].coordinate.latitude),
						  @"longitude": @([ENLocationManager cachedCurrentLocation].coordinate.longitude),
						  @"distance": restaurant.distance};
    DDLogVerbose(@"Select restaurant: %@", dic);
    NSString *path = [NSString stringWithFormat:@"%@/%@", kServerUrl, @"select"];
    [manager POST:path parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
        NSString *s = [NSString stringWithFormat:@"%@", error];
        DDLogError(s);
    }];
}

- (BOOL)canSelectNewRestaurant{
	if (self.selectedRestaurant) {
		if ([[NSDate date] timeIntervalSinceDate:self.selectedTime] < kMaxSelectedRestaurantRetainTime) {
			return NO;
		}
		else{
			[self clearSelectedRestaurant];
		}
	}
	return YES;
}

- (void)clearSelectedRestaurant{
	self.selectedRestaurant = nil;
	self.selectedTime = nil;
}

- (void)updateRestaurant:(ENRestaurant *)restaurant withInfo:(NSDictionary *)dic completion:(void (^)(NSError *))block{
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.requestSerializer = [AFJSONRequestSerializer serializer];
	
	//DDLogVerbose(@"update restaurant(%@): %@", restaurant.ID, dic);
	NSParameterAssert([dic.allKeys containsObject:@"img_url"]);
	NSParameterAssert([dic[@"img_url"] isKindOfClass:[NSArray class]]);
	NSString *url = [NSString stringWithFormat:@"%@%@/%@",kServerUrl, @"restaurant", restaurant.ID];
	[manager PUT:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if(block) block(nil);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if(block) block(error);
		DDLogError(error.localizedDescription);
	}];

}

#pragma mark - Tools

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
