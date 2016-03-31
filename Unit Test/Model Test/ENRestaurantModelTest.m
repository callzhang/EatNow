//
//  ENRestaurantModelTest.m
//  EatNow
//
//  Created by Veracruz on 16/3/31.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ENRestaurantModel.h"

@interface ENRestaurantModelTest : XCTestCase

@end

@implementation ENRestaurantModelTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    DDTTYLogger *log = [DDTTYLogger sharedInstance];
    [DDLog addLogger:log];
    
    [log setColorsEnabled:YES];
    [log setForegroundColor:[UIColor colorWithRed:0.000 green:0.816 blue:0.004 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagInfo];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRestaurantModel {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString *path = [[NSBundle bundleForClass:[ENRestaurantModelTest class]] pathForResource:@"test_data" ofType:@"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    JSONModelError *error;
    ENRestaurantModel *model = [[ENRestaurantModel alloc] initWithString:jsonString error:&error];
    
    if (error) {
        DDLogError(@"%@", error.localizedDescription);
    } else {
        DDLogInfo(@"Success: data test below");
        
        DDLogInfo(@"model.identifier : %@", model.identifier);
        DDLogInfo(@"model.rating : %@", model.rating);
        DDLogInfo(@"model.ratingColor : %@", model.ratingColor);
        DDLogInfo(@"model.name : %@", model.name);
        DDLogInfo(@"model.hasMenu : %d", model.hasMenu);
        DDLogInfo(@"model.vendorURL : %@", model.vendorURL);
        
        DDLogInfo(@"model.price.tier) : %@", model.price.tier);
        DDLogInfo(@"model.price.message : %@", model.price.message);
        DDLogInfo(@"model.price.currency : %@", model.price.currency);
        
        DDLogInfo(@"model.contact.phone : %@", model.contact.phone);
        DDLogInfo(@"model.contact.formattedPhone : %@", model.contact.formattedPhone);
        DDLogInfo(@"model.contact.twitter : %@", model.contact.twitter);
        DDLogInfo(@"model.contact.facebook : %@", model.contact.facebook);
        
        DDLogInfo(@"model.location.address : %@", model.location.address);
        DDLogInfo(@"model.location.city : %@", model.location.city);
        DDLogInfo(@"mmodel.location.state : %@", model.location.state);
        DDLogInfo(@"model.location.country : %@", model.location.country);
        DDLogInfo(@"model.location.countryCode : %@", model.location.countryCode);
        DDLogInfo(@"model.location.postalCode : %@", model.location.postalCode);
        for (NSString *address in model.location.formattedAddress) {
            DDLogInfo(@"model.location.formattedAddress<NSArray> : %@", address);
        }
        DDLogInfo(@"model.location.longitude : %f", model.location.longitude);
        DDLogInfo(@"model.location.latitude : %f", model.location.latitude);
        
        for (NSString *imageURL in model.foodImageURL) {
            DDLogInfo(@"model.foodImageURL<NSArray> : %@", imageURL);
        }
        
        DDLogInfo(@"model.categories.firstObject.identifier : %@", model.categories.firstObject.identifier);
        DDLogInfo(@"model.categories.firstObject.name : %@", model.categories.firstObject.name);
        DDLogInfo(@"model.categories.firstObject.global : %@", model.categories.firstObject.global);
        DDLogInfo(@"model.categories.firstObject.shortName : %@", model.categories.firstObject.shortName);
        DDLogInfo(@"model.categories.firstObject.primary : %d", model.categories.firstObject.primary);
        
        DDLogInfo(@"model.stats.tipCount : %@", model.stats.tipCount);
        DDLogInfo(@"model.stats.checkinsCount : %@", model.stats.checkinsCount);
        DDLogInfo(@"model.stats.usersCount : %@", model.stats.usersCount);
        
        DDLogInfo(@"model.photos.count : %@", model.photos.count);
        DDLogInfo(@"model.photos.updated : %@", model.photos.updated);
        DDLogInfo(@"model.photos.items.firstObject.type : %@", model.photos.items.firstObject.type);
        DDLogInfo(@"model.photos.items.firstObject.createAt : %@", model.photos.items.firstObject.createAt);
        DDLogInfo(@"model.photos.items.firstObject.prefix : %@", model.photos.items.firstObject.prefix);
        DDLogInfo(@"model.photos.items.firstObject.suffix : %@", model.photos.items.firstObject.suffix);
        DDLogInfo(@"model.photos.items.firstObject.width : %@", model.photos.items.firstObject.width);
        DDLogInfo(@"model.photos.items.firstObject.height : %@", model.photos.items.firstObject.height);
        DDLogInfo(@"model.photos.items.firstObject.tags.firstObject : %@", model.photos.items.firstObject.tags.firstObject);
        DDLogInfo(@"model.photos.items.firstObject.descriptionString : %@", model.photos.items.firstObject.descriptionString);
        
        DDLogInfo(@"model.tags.count : %@", model.tags.count);
        DDLogInfo(@"model.tags.updated : %@", model.tags.updated);
        DDLogInfo(@"model.tags.items.firstObject : %@", model.tags.items.firstObject);
        DDLogInfo(@"model.tags.details.firstObject.tag : %@", model.tags.details.firstObject.tag);
        DDLogInfo(@"model.tags.details.firstObject.score : %@", model.tags.details.firstObject.score);
        DDLogInfo(@"model.tags.details.firstObject.justifications.firstObject.text : %@", model.tags.details.firstObject.justifications.firstObject.text);
        DDLogInfo(@"model.tags.details.firstObject.justifications.firstObject.type : %@", model.tags.details.firstObject.justifications.firstObject.type);
        DDLogInfo(@"model.tags.details.firstObject.justifications.firstObject.count : %@", model.tags.details.firstObject.justifications.firstObject.count);
        DDLogInfo(@"model.tags.details.firstObject.justifications.firstObject.total : %@", model.tags.details.firstObject.justifications.firstObject.total);
        DDLogInfo(@"model.tags.failed.firstObject.tag : %@", model.tags.failed.firstObject.tag);
        DDLogInfo(@"model.tags.failed.firstObject.identifier : %@", model.tags.failed.firstObject.identifier);
        DDLogInfo(@"model.tags.failed.firstObject.reason : %@", model.tags.failed.firstObject.reason);
        
        DDLogInfo(@"model.attributes.updated : %@", model.attributes.updated);
        
        DDLogInfo(@"model.score.totalScore : %@", model.score.totalScore);
        DDLogInfo(@"model.score.modeScore : %@", model.score.modeScore);
        DDLogInfo(@"model.score.timeScore : %@", model.score.timeScore);
        DDLogInfo(@"model.score.priceScore : %@", model.score.priceScore);
        DDLogInfo(@"model.score.commentScore : %@", model.score.commentScore);
        DDLogInfo(@"model.score.distanceScore : %@", model.score.distanceScore);
        DDLogInfo(@"model.score.cuisineScore : %@", model.score.cuisineScore);
        DDLogInfo(@"model.score.ratingScore : %@", model.score.ratingScore);
        DDLogInfo(@"model.score.averageDistan : %@", model.score.averageDistance);
        DDLogInfo(@"model.score.averagePrice : %@", model.score.averagePrice);
        DDLogInfo(@"model.score.averageRating : %@", model.score.averageRating);
        DDLogInfo(@"model.score.averageLike : %@", model.score.averageLike);
        
    }
    
}

@end
