//
//  ENServerManager.h
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#define kSearchUrl                  @"http://dry-fortress-8563.herokuapp.com/search"
#define kUserUrl                    @"http://dry-fortress-8563.herokuapp.com/user/"
#define kEatUrl                     @"http://dry-fortress-8563.herokuapp.com/select"
#define kCuisineNames        @"Afghan,African,American,Argentine,Asian,Australian,Bakery,Bangladeshi,Bars,Belgian,Brasseries,Brazilian,Breakfast,British,Buffets,Cafes,Cambodian,Caribbean,Chinese,Coffee,Creperie,Cuban,Czech,Delis,Dessert,Eastern_European,Ethiopian,Fast_Food,Fast_Truck,Filipino,Food_Truck,French,German,Greek,Halal,Hawaiian,Healthy,Himalayan,Indian,Indonesian,Italian,Japanese,Korean,Kosher,Latin_American,Malaysian,Mediterranean,Mexican,Middle_Eastern,Modern,Mongolian,Moroccan,Night_Life,Northern_European,Pakistani,Persian,Peruvian,Polish,Russian,Seafood,Southern,Spanish,Steakhouses,Tea_Rooms,Thai,Turkish,Ukrainian,Vegetarian,Vietnamese"

#import <Foundation/Foundation.h>
//@import CoreLocation;
#import "AFNetworking.h"
#import "ENDefines.h"
#import "Restaurant.h"
#import "ENServer.h"

@class CLLocation;
@interface ENServerManager : NSObject
@property (nonatomic, strong) NSMutableArray *restaurants;
//@property (nonatomic, strong) CLLocation *currentLocation;
//@property (nonatomic, strong) NSDate *lastUpdatedLocation;
@property (nonatomic, strong) NSArray *cuisines;

@property (nonatomic, assign) ENResturantDataStatus fetchStatus;

//+ (instancetype)sharedInstance;

//functions
//- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block;
- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block;
- (void)selectRestaurant:(Restaurant *)restaurant like:(NSInteger)value completion:(void (^)(NSError *error))block;
- (void)getRestaurantsAtLocation:(CLLocation *)location WithCompletion:(void (^)(BOOL success, NSError *error, NSArray *response))block;
@end