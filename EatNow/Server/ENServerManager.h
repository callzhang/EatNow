//
//  ENServerManager.h
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#define kSearchUrl                  @"http://dry-fortress-8563.herokuapp.com/search"
#define kUserUrl                    @"http://dry-fortress-8563.herokuapp.com/"
#define kEatUrl                     @"http://dry-fortress-8563.herokuapp.com/select"
#define kCuisineNames        @"Afghan,African,American_(New),American_(Traditional),Middle_Eastern,Argentine,Armenian,Asian,Spanish,Australian,Eastern_European,Delis,Bangladeshi,German,Bars,Pubs,Belgian,Brasseries,Turkish,Brazilian,Brunch,British,Buffets,Bulgarian,Fast_Food,Burmese,Cafes,Southern,Cambodian,Caribbean,Chilean,Chinese,Mediterranean,Cuban,Czech,Northern_European,Ethiopian,Filipino,French,Russian,Healthy,Greek,Hawaiian,Himalayan/Nepalese,Indian,Indonesian,Italian,Japanese,Korean,Persian,Laos,Latin_American,Seafood,Malaysian,Mexican,Mongolian,Moroccan,New_Zealand,Night_Food,Pakistani,Peruvian,Polish,International,Singaporean,Steakhouses,Taiwanese,Thai,Ukrainian,Vegetarian,Vietnamese,Tea_Rooms,Bubble_Tea"

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
#import "AFNetworking.h"
#import "ENDefines.h"
#import "Restaurant.h"

@interface ENServerManager : NSObject
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic) ENServerManagerStatus status;
@property (nonatomic, strong) NSDate *lastUpdatedLocation;
@property (nonatomic, strong) NSArray *cuisines;

+ (instancetype)sharedInstance;

//functions
- (void)getRestaurantListWithCompletion:(void (^)(BOOL success, NSError *error))block;
- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block;
- (void)selectRestaurant:(Restaurant *)restaurant like:(NSInteger)value completion:(void (^)(NSError *error))block;
@end
