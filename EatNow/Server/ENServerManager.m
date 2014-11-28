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
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [_locationManager startUpdatingLocation];
    }
    return self;
}

#pragma mark - Main method

- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block{
    //first remove old location
    _currentLocation = nil;
    //start location manager
    [_locationManager startUpdatingLocation];
    //listen to updates
    [[NSNotificationCenter defaultCenter] addObserverForName:kUpdatedLocation object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSParameterAssert(_currentLocation);
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
                      restaurant.imageUrl = restaurant_json[@"snippet_image_url"];
                      restaurant.phone = restaurant_json[@"phone"];
                      restaurant.name = restaurant_json[@"name"];
                      NSDictionary *coordinate = [restaurant_json valueForKeyPath:@"location.coordinate"];
                      CLLocationDegrees lat = [(NSNumber *)coordinate[@"latitude"] doubleValue];
                      CLLocationDegrees lon = [(NSNumber *)coordinate[@"longitude"] doubleValue];
                      CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                      restaurant.location = loc;
                      
                      [_restaurants addObject:restaurant];
                      
                      NSLog(@"Fetched restaurant: %@", restaurant.name);
                  }
                  
                  //post notification
                  [[NSNotificationCenter defaultCenter] postNotificationName:kFetchedRestaurantList object:nil];
                  
                  if (block) {
                      block(YES, nil);
                  }
                  
              }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
                  
                  NSLog(@"Failed to get restaurant list with Error: %@", error);
                  if (block) {
                      block(NO, error);
                  }
              }];
    }];
    

}

#pragma mark - Location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _currentLocation = locations.firstObject;
    NSLog(@"Get location of %@", locations);
    [_locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatedLocation object:nil];
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
