//
//  ENServerManager.h
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#define kMaxSelectedRestaurantRetainTime			3600
#define kServerUrl                  @"http://api.eatnow.cc"
#define kCuisineNames        @"Afghan,African,American,Argentine,Asian,Australian,Bakery,Bangladeshi,Bars,Belgian,Brasseries,Brazilian,Breakfast,British,Buffets,Cafes,Cambodian,Caribbean,Chinese,Coffee,Creperie,Cuban,Czech,Delis,Dessert,Eastern_European,Ethiopian,Fast_Food,Fast_Truck,Filipino,Food_Truck,French,German,Greek,Halal,Hawaiian,Healthy,Himalayan,Indian,Indonesian,Italian,Japanese,Korean,Kosher,Latin_American,Malaysian,Mediterranean,Mexican,Middle_Eastern,Modern,Mongolian,Moroccan,Night_Life,Northern_European,Pakistani,Persian,Peruvian,Polish,Russian,Seafood,Southern,Spanish,Steakhouses,Tea_Rooms,Thai,Turkish,Ukrainian,Vegetarian,Vietnamese"



extern NSString * const kHistroyUpdated;
extern NSString * const kRatingUpdated;
extern NSString * const kPreferenceUpdated;
extern NSString * const kUserUpdated;

#import <Foundation/Foundation.h>
//@import CoreLocation;
#import "AFNetworking.h"
#import "ENDefines.h"
#import "ENRestaurant.h"
#import "ENServer.h"
#import "GCDSingleton.h"

@class CLLocation;
@interface ENServerManager : NSObject
//@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) NSArray *cuisines;
@property (nonatomic, assign) ENResturantDataStatus fetchStatus;
@property (nonatomic, strong) ENRestaurant *selectedRestaurant;
@property (nonatomic, strong) NSDate *selectedTime;
@property (nonatomic, strong) NSString *selectionHistoryID;
/**
 *  keeps users LATEST rating for restaurants
 *  Example: {restaurant_id: {rating: 9, date: Mar 15, 2015}}
 */
@property (nonatomic, strong) NSMutableDictionary *userRating;
@property (nonatomic, strong) NSMutableDictionary *history;
@property (nonatomic, strong) NSDictionary *preference;
@property (nonatomic, strong) NSDictionary *me;
@property (nonatomic, strong) NSString *myID;

//We still need Singleton as it stores shared information
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENServerManager)

//functions
//- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block;
- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block;
- (void)searchRestaurantsAtLocation:(CLLocation *)location WithCompletion:(void (^)(BOOL success, NSError *error, NSArray *response))block;
- (void)updateRestaurant:(ENRestaurant *)restaurant withInfo:(NSDictionary *)dic completion:(void (^)(NSError *error))block;

//select restaurant
- (void)selectRestaurant:(ENRestaurant *)restaurant like:(NSInteger)value completion:(ErrorBlock)block;
- (void)cancelSelectedRestaurant:(NSString *)historyID completion:(ErrorBlock)block;
- (BOOL)canSelectNewRestaurant;
- (void)clearSelectedRestaurant;
@end
