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
#import "NSError+TMError.h"

DDLogLevel const ddLogLevel = DDLogLevelVerbose;

@interface InterfaceController()
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;

@end


@implementation InterfaceController
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    self.locationManager = [[ENLocationManager alloc] init];
    self.serverManager = [[ENServerManager alloc] init];
    
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            NSMutableArray *restaurants = [NSMutableArray array];
            NSMutableArray *objests = [NSMutableArray array];
            for (NSUInteger i = 0; i < 12 && i < response.count; i++) {
                [restaurants addObject:@"ResturantInterfaceController"];
                [objests addObject:response[i]];
            }
            [WKInterfaceController reloadRootControllersWithNames:restaurants contexts:objests];
        }];
    } forece:YES];
}
@end



