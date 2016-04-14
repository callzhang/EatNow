//
//  ENNetworkingTest.m
//  EatNow
//
//  Created by Veracruz on 16/3/12.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JSONAPI.h"
#import "ENServerManager.h"
#import "ENLocationManager.h"
#import "ENRestaurant.h"
#import "ENRestaurantModel.h"
#import "NSDate+Extension.h"
#import "ENLocationManager.h"
#import "ENMapManager.h"

#define EXPECTATION_TIME_OUT 100

@interface ENNetworkingTest : XCTestCase

@property (strong, nonatomic) CLLocation *simulateLocation;

@end

@implementation ENNetworkingTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    DDTTYLogger *log = [DDTTYLogger sharedInstance];
    [DDLog addLogger:log];
    
    [log setColorsEnabled:YES];
    [log setForegroundColor:[UIColor colorWithRed:0.000 green:0.816 blue:0.004 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagInfo];
    
    _simulateLocation = [[CLLocation alloc] initWithLatitude:22.492058 longitude:113.935189];
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRestaurantSearching {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    DDLogInfo(@"Location: (%f, %f)", _simulateLocation.coordinate.longitude, _simulateLocation.coordinate.latitude);
    
    XCTestExpectation *userExpectation = [self expectationWithDescription:@"get user expactation"];
    [[ENServerManager sharedInstance] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        
        if (error) {
            return;
        }
        
        DDLogInfo(@"%@", user);
        [userExpectation fulfill];
    }];
    
    
    XCTestExpectation *restaurantExpectation = [self expectationWithDescription:@"get restaurant expactation"];
    [[ENServerManager sharedInstance] searchRestaurantsAtLocation:_simulateLocation WithCompletion:^(BOOL success, NSError *error, NSArray <ENRestaurant *> *response) {
        
        XCTAssert(success);
        
        for (ENRestaurantModel *restaurant in response) {
            DDLogInfo(@"Restaurant ID: %@", restaurant.identifier);
        }
        
        [restaurantExpectation fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:EXPECTATION_TIME_OUT handler:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@", error.localizedDescription);
        }
    }];
    
}

- (void)testRestaurantModel {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *myID = [ENUtil myUUID];
    NSDictionary *parameters = @{@"username":myID,
                                 @"latitude":@(_simulateLocation.coordinate.latitude),
                                 @"longitude":@(_simulateLocation.coordinate.longitude),
                                 //@"time": [NSDate date].ISO8601
                                 //@"radius":@500
                                 };
    NSString *url = [NSString stringWithFormat:@"%@/%@", kServerUrl, @"search"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"get restaurant"];
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        
        for (NSDictionary *restaurantDictionary in responseObject) {
            NSError *error;
            ENRestaurantModel *model = [[ENRestaurantModel alloc] initWithDictionary:restaurantDictionary error:&error];
            if (error) {
                DDLogError(@"%@", error.localizedDescription);
            }
            else {
                DDLogInfo(@"Restaurant ID: %@", model.identifier);
            }
            XCTAssertNil(error);
        }
        
        [expectation fulfill];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error.localizedDescription);
        XCTAssert(NO);
    }];
    
    [self waitForExpectationsWithTimeout:EXPECTATION_TIME_OUT handler:nil];
}

- (void)testLocationManager {
    
    CLLocation *cachedLocation = [ENLocationManager cachedCurrentLocation];
    DDLogInfo(@"Cached Location: %f, %f", cachedLocation.coordinate.longitude, cachedLocation.coordinate.latitude);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"get location"];
    [[ENLocationManager sharedInstance] getLocationWithCompletion:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        XCTAssert(status == INTULocationStatusSuccess);
        DDLogInfo(@"Location Status: %ld", (long)status);
        DDLogInfo(@"Current Location: %f, %f", currentLocation.coordinate.longitude, currentLocation.coordinate.latitude);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:EXPECTATION_TIME_OUT handler:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@", error.localizedDescription);
        }
    }];
}

- (void)testMapManager {
    
    ENMapManager *manager = [[ENMapManager alloc] initWithMap:[[MKMapView alloc] init]];
    
    XCTestExpectation *directionsExpectation = [self expectationWithDescription:@"get directions"];
    
    CLLocation *nearbyLocation = [[CLLocation alloc] initWithLatitude:22.492058 longitude:113.955189];
    [manager findDirectionsTo:nearbyLocation completion:^(MKDirectionsResponse *response, NSError *error) {
        XCTAssert(error == nil);
        [directionsExpectation fulfill];
    }];
    
    XCTestExpectation *walkingExpectation = [self expectationWithDescription:@"walking time"];
    [manager estimatedWalkingTimeToLocation:nearbyLocation completion:^(MKRoute *route, NSError *error) {
        XCTAssert(error == nil);
        DDLogInfo(@"Walking time: %f", route.expectedTravelTime);
        [walkingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:EXPECTATION_TIME_OUT handler:^(NSError * _Nullable error) {
        if (error) {
            DDLogError(@"%@", error.localizedDescription);
        }
    }];
}

/*
 - (void)testPerformanceExample {
 // This is an example of a performance test case.
 [self measureBlock:^{
 // Put the code you want to measure the time of here.
 }];
 }
 */

@end
