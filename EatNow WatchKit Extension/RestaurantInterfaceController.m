//
//  RestaurantInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "RestaurantInterfaceController.h"


@interface RestaurantInterfaceController()

@end


@implementation RestaurantInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSLog(@"context: %@", context);
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



