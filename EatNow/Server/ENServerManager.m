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
@implementation ENServerManager
+ (instancetype)sharedInstance{
    static ENServerManager *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [ENServerManager new];
            manager.restaurants = [NSMutableArray new];
        });
    }
    return manager;
}
- (void)getRestaurantListWithCompletion:(void (^)(BOOL, NSError *))block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    //[manager.requestSerializer setValue:kParseApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
    //[manager.requestSerializer setValue:kParseRestAPIId forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *myID = [ENServerManager myUUID];
    NSDictionary *dic = @{@"username":myID,
                          @"latitude":@40.750124,
                          @"longitude":@-73.990478
                          };
    
    [manager POST:kSearchUrl parameters:dic
          success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
              NSLog(@"GET restaurant list %lu", responseObject.count);
              for (NSDictionary *restaurant_json in responseObject) {
                  Restaurant *restaurant = [Restaurant new];
                  NSNumber *distance = restaurant_json[@"distance"];
                  restaurant.url = restaurant_json[@"mobile_url"];
                  restaurant.rating = [(NSNumber *)restaurant_json[@"rating"] floatValue];
                  restaurant.reviews = [(NSNumber *)restaurant_json[@"review_count"] integerValue];
                  restaurant.cuisines = restaurant_json[@"categories"];
                  restaurant.objectID = restaurant_json[@"id"];
                  restaurant.imageUrl = restaurant_json[@"snippet_image_url"];
                  restaurant.phone = restaurant_json[@"phone"];
                  restaurant.name = restaurant_json[@"name"];
                  NSDictionary *coordinate = [restaurant_json valueForKeyPath:@"location.coordinate"];
                  CLLocationDegrees lat = [(NSNumber *)coordinate[@"latitute"] doubleValue];
                  CLLocationDegrees lon = [(NSNumber *)coordinate[@"longitute"] doubleValue];
                  CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                  restaurant.location = loc;
                  
                  [_restaurants addObject:restaurant];
                  
                  NSLog(@"Fetched restaurant: %@", restaurant.name);
              }
              
              //post notification
              [[NSNotificationCenter defaultCenter] postNotificationName:kFetchedRestaurantList object:nil];
              
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              
              NSLog(@"Failed to get restaurant list with Error: %@", error);
              
          }];

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
