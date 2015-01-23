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

@interface ENServerManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
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
            [_locationManager requestWhenInUseAuthorization];
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusRestricted){
            //need pop alert
            NSLog(@"Location service disabled");
        }else{
            [_locationManager startUpdatingLocation];
        }
        
        //indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

#pragma mark - Main method

- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block{
    if (-_lastUpdatedLocation.timeIntervalSinceNow > 600) {
        NSLog(@"Location outdated, set to nil");
        _currentLocation = nil;
    }
    //first remove old location
    if (!_currentLocation) {
        NSLog(@"No location yet, locating.");
        _isRequesting = NO;
        //request new location and watch for the notification
        //start location manager
        [_locationManager startUpdatingLocation];
        
        //listen to updates
        [[NSNotificationCenter defaultCenter] addObserverForName:kUpdatedLocation object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
                if (block) {
                    block(success, error);
                }
            }];
        }];
    }else{
        if (_isRequesting) {
            NSLog(@"Already requesting restaurants from server, skip");
            return;
        }
        
        _isRequesting = YES;
        
        NSLog(@"Got location, start requesting");
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        //[manager.requestSerializer setValue:kParseApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
        //[manager.requestSerializer setValue:kParseRestAPIId forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSString *myID = [ENServerManager myUUID];
        NSDictionary *dic = @{@"username":myID,
                              @"latitude":@(_currentLocation.coordinate.latitude),
                              @"longitude":@(_currentLocation.coordinate.longitude)
                              };
        NSLog(@"Request: %@", dic);
        [manager POST:kSearchUrl parameters:dic
              success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
                  NSLog(@"GET restaurant list %lu", (unsigned long)responseObject.count);
                  for (NSDictionary *restaurant_json in responseObject) {
                      Restaurant *restaurant = [Restaurant new];
                      restaurant.url = restaurant_json[@"mobile_url"];
                      restaurant.rating = [(NSNumber *)restaurant_json[@"rating"] floatValue];
                      restaurant.reviews = [(NSNumber *)restaurant_json[@"review_count"] integerValue];
                      NSArray *list = restaurant_json[@"categories"];
                      NSArray *cuisines = [ENServerManager getArrayOfCategories:list];
                      restaurant.cuisines = cuisines;
                      restaurant.objectID = restaurant_json[@"id"];
                      restaurant.imageUrl = restaurant_json[@"food_image_url"];
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
                          NSNumber *commentScore = scores[@"comment_score"] != [NSNull null] ? scores[@"comment_score"]:@0;
                          NSNumber *cuisineScore = scores[@"cuisine_score"] != [NSNull null] ? scores[@"cuisine_score"]:@0;
                          NSNumber *distanceScore = scores[@"distance_score"] != [NSNull null] ? scores[@"distance_score"]:@0;
                          NSNumber *priceScore = scores[@"price_score"] != [NSNull null] ? scores[@"price_score"]:@0;
                          NSNumber *ratingScore = scores[@"rating_score"] != [NSNull null] ? scores[@"rating_score"]:@0;
                          totalScore = @(commentScore.floatValue + cuisineScore.floatValue + distanceScore.floatValue + priceScore.floatValue + ratingScore.floatValue);
                      }
                      restaurant.score = [totalScore floatValue];
                      
                      [_restaurants addObject:restaurant];
                      
                      NSLog(@"%@", restaurant);
                      NSLog(@"Score: %@", restaurant_json[@"score"]);
                  }
                  
                  [_restaurants sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
                  
                  //post notification
                  [[NSNotificationCenter defaultCenter] postNotificationName:kFetchedRestaurantList object:nil];
                  
                  if (block) {
                      block(YES, nil);
                  }
                  _isRequesting = NO;
                  
              }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
                  
                  NSLog(@"Failed to get restaurant list with Error: %@", error);
                  if (block) {
                      block(NO, error);
                  }
                  _isRequesting = NO;
                  
                  [self getRestaurantListWithCompletion:NULL];
              }];
        
    }
}

#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _currentLocation = locations.firstObject;
    _lastUpdatedLocation = [NSDate date];
    NSLog(@"Get location of %@", locations);
    [_locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedLocation object:nil];
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

+ (NSString *)myUUID{
    NSString *myID = [[NSUserDefaults standardUserDefaults] objectForKey:kUUID];
    if (!myID) {
        myID = [ENServerManager generateUUID];
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
@end
