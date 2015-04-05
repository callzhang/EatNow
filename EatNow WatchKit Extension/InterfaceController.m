//
//  InterfaceController.m
//  EatNow WatchKit Extension
//
//  Created by Zitao Xiong on 4/1/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "InterfaceController.h"
#import "ENLocationManager.h"
#import "ENServerManager.h"

DDLogLevel const ddLogLevel = DDLogLevelVerbose;

@interface InterfaceController()
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

//    NSLog(@"start to request");
//    [[self class] openParentApplication:@{} reply:^(NSDictionary *replyInfo, NSError *error) {
//        NSLog(@"reply:%@", replyInfo);
//    }];
    self.locationManager = [[ENLocationManager alloc] init];
    self.serverManager = [[ENServerManager alloc] init];
    
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            NSLog(@"response:%@, error:%@", response, error);
        }];
    } forece:YES];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



