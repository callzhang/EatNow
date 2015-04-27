//
//  GlanceController.m
//  EatNow WatchKit Extension
//
//  Created by Zitao Xiong on 4/1/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "GlanceController.h"
#import "ENLocationManager.h"
#import "ENServerManager.h"
#import "NSError+TMError.h"
#import "ENRestaurant.h"
#import "ENMapManager.h"
#import "extobjc.h"

@interface GlanceController()
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel1;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *reviewLabel1;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *walkMins1;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel2;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *reviewLabel2;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *walkMins2;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel3;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *reviewLabel3;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *walkMIns3;

@property (nonatomic, strong) ENMapManager *mapManager;
@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    self.mapManager = [[ENMapManager alloc] init];
    
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        NSLog(@"got location:%@", location);
        [self.serverManager searchRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            @strongify(self);
            for (NSUInteger i = 0; i < 3 && i < response.count; i++) {
                ENRestaurant *restaurant = response[i];
                if (i == 0) {
                    [self.nameLabel1 setText:restaurant.name];
                    [self.reviewLabel1 setText:[NSString stringWithFormat:@"%@", restaurant.rating]];
                    [self.mapManager estimatedWalkingTimeToLocation:restaurant.location completion:^(NSTimeInterval length, NSError *error) {
                        self.walkMins1.text = [NSString stringWithFormat:@"%.1f mins walk", length / 60.0];
                    }];
                }
                else if (i == 1) {
                    [self.nameLabel2 setText:restaurant.name];
                    [self.reviewLabel2 setText:[NSString stringWithFormat:@"%@", restaurant.rating]];
                    [self.mapManager estimatedWalkingTimeToLocation:restaurant.location completion:^(NSTimeInterval length, NSError *error) {
                        self.walkMins2.text = [NSString stringWithFormat:@"%.1f mins walk", length / 60.0];
                    }];
                }
                else if (i == 2) {
                    [self.nameLabel3 setText:restaurant.name];
                    [self.reviewLabel3 setText:[NSString stringWithFormat:@"%@", restaurant.rating]];
                    [self.mapManager estimatedWalkingTimeToLocation:restaurant.location completion:^(NSTimeInterval length, NSError *error) {
                        self.walkMIns3.text = [NSString stringWithFormat:@"%.1f mins walk", length / 60.0];
                    }];
                }
            }
        }];
    } forece:YES];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

@end



