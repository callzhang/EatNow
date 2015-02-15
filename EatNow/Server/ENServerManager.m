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
#import "ENUtil.h"

@interface ENServerManager()<CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;
@end


@implementation ENServerManager
+ (instancetype)sharedInstance{
    static ENServerManager *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [ENServerManager new];
        });
    }
    return manager;
}

- (ENServerManager *)init{
    self = [super init];
    if (self) {
        
        _restaurants = [NSMutableArray new];
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        //_locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            NSLog(@"kCLAuthorizationStatusNotDetermined");
            [_locationManager requestWhenInUseAuthorization];
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusRestricted){
            //need pop alert
            NSLog(@"Location service disabled");
            [[[UIAlertView alloc] initWithTitle:@"Location disabled" message:@"Location service is needed to provide you the best restaurants around you. Click [Setting] to update the authorization." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Setting", nil] show];
        }else{
            [_locationManager startUpdatingLocation];
			//add getting location trait
			self.status = self.status & GettingLocation;
#ifdef DEBUG
            //use default location in 10s
            if (_currentLocation) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"No location obtained, using fake location" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                    NSLog(@"Using fake location");
                    _currentLocation = [[CLLocation alloc] initWithLatitude:41 longitude:-73];
					self.status = self.status & ~GettingLocation;
					self.status = self.status & GotLocation;
                });
            }
#endif
        }
        
        //indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
		
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
    }
    return self;
}

#pragma mark - Alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - Main method

- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block{
    if (-_lastUpdatedLocation.timeIntervalSinceNow > 600) {
        NSLog(@"Location outdated, set to nil");
        _currentLocation = nil;
    }
    //first remove old location
    if (!_currentLocation || (self.status & GettingLocation)) {
        NSLog(@"locating, delay request");
        self.status = self.status & ~FetchingRestaurant;
        //request new location and watch for the notification
        //start location manager
        [_locationManager startUpdatingLocation];
        
        //listen to updates
        [self.KVOController observe:self keyPath:@"status" options:NSKeyValueObservingOptionNew block:^(id observer, ENServerManager *object, NSDictionary *change) {
			if (object.status & GotLocation) {
				[self.KVOController unobserve:self keyPath:@"status"];
				[self getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
					if (block) {
						block(success, error);
					}
				}];
			}
        }];
    }else{
		if (self.status & FetchingRestaurant) {
			NSLog(@"Already requesting restaurant.");
			return;
		}
		self.status |= FetchingRestaurant;
		
        NSLog(@"Start requesting restaurants");
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        //[manager.requestSerializer setValue:kParseApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
        //[manager.requestSerializer setValue:kParseRestAPIId forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSString *myID = [ENUtil myUUID];
        NSDictionary *dic = @{@"username":myID,
                              @"latitude":@(_currentLocation.coordinate.latitude),
                              @"longitude":@(_currentLocation.coordinate.longitude)
                              };
        NSLog(@"Request: %@", dic);
        [manager POST:kSearchUrl parameters:dic
              success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                  NSLog(@"GET restaurant list %ld", responseObject.count);
                  for (NSDictionary *restaurant_json in responseObject) {
                      Restaurant *restaurant = [Restaurant new];
					  restaurant.ID = restaurant_json[@"id"];
                      restaurant.url = restaurant_json[@"mobile_url"];
                      restaurant.rating = [(NSNumber *)restaurant_json[@"rating"] floatValue];
                      restaurant.reviews = [(NSNumber *)restaurant_json[@"review_count"] integerValue];
                      NSArray *list = restaurant_json[@"categories"];
                      NSArray *cuisines = [ENServerManager getArrayOfCategories:list];
                      restaurant.cuisines = cuisines;
					  restaurant.imageUrls = restaurant_json[@"food_image_url"];
                      restaurant.phone = restaurant_json[@"phone"];
                      restaurant.name = restaurant_json[@"name"];
                      restaurant.price = [(NSNumber *)restaurant_json[@"price"] floatValue];
                      //location
                      NSDictionary *coordinate = [restaurant_json valueForKeyPath:@"location.coordinate"];
                      CLLocationDegrees lat = [(NSNumber *)coordinate[@"latitude"] doubleValue];
                      CLLocationDegrees lon = [(NSNumber *)coordinate[@"longitude"] doubleValue];
                      CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                      restaurant.location = loc;
                      //score
                      NSDictionary *scores = restaurant_json[@"score"];
                      NSNumber *totalScore = scores[@"total_score"];
                      if ([totalScore isEqual: [NSNull null]]) {
						  NSString *str = [NSString stringWithFormat:@"Returned null score (ID = %@", restaurant.ID];
						  ENAlert(str);
						  NSNumber *commentScore = scores[@"comment_score"] != [NSNull null] ? scores[@"comment_score"]:@0;
                          NSNumber *cuisineScore = scores[@"cuisine_score"] != [NSNull null] ? scores[@"cuisine_score"]:@0;
                          NSNumber *distanceScore = scores[@"distance_score"] != [NSNull null] ? scores[@"distance_score"]:@0;
                          NSNumber *priceScore = scores[@"price_score"] != [NSNull null] ? scores[@"price_score"]:@0;
                          NSNumber *ratingScore = scores[@"rating_score"] != [NSNull null] ? scores[@"rating_score"]:@0;
                          totalScore = @(commentScore.floatValue + cuisineScore.floatValue + distanceScore.floatValue + priceScore.floatValue + ratingScore.floatValue);
                      }
                      restaurant.score = [totalScore floatValue];
                      
                      [_restaurants addObject:restaurant];
					  
					  DDLogInfo(@"Processed restaurant: %@", restaurant.name);
                  }
				  
				  //server returned sorted from high to low
				  //[_restaurants sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
				  
				  
                  if (block) {
                      block(YES, nil);
				  }
				  
				  //post notification
				  self.status &= ~FetchingRestaurant;
				  self.status |= FetchedRestaurant;
				  
              }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
                  
                  NSLog(@"Failed to get restaurant list with Error: %@", error);
                  if (block) {
                      block(NO, error);
                  }
				  self.status &= ~FetchedRestaurant;
				  self.status |= FetchedRestaurant;
              }];
        
    }
}

- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block{
    NSLog(@"Start requesting user");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *myID = [ENUtil myUUID];
    [manager GET:[NSString stringWithFormat:@"%@%@",kUserUrl, myID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *s = [NSString stringWithFormat:@"Failed to get user: %@", error];
        DDLogError(s);
        ENAlert(s);
        block(nil, error);
    }];
}

#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _currentLocation = locations.firstObject;
    _lastUpdatedLocation = [NSDate date];
    NSLog(@"Get location of %@", locations);
    [_locationManager stopUpdatingLocation];
	self.status &= ~GettingLocation;
	self.status |= GotLocation;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
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

#pragma mark - Tools

+ (NSArray *)getArrayOfCategories:(NSArray *)list{
    NSMutableArray *types = [NSMutableArray new];
    for (NSArray *sub in list) {
        [types addObject:sub.firstObject];
    }
    return types.copy;
}


@end
