//
//  ResturantInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ResturantInterfaceController.h"
#import "Restaurant.h"
#import "AFNetworking.h"


@interface ResturantInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantCategory;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantDistance;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantPrice;
@property (nonatomic, strong) Restaurant *restaurant;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *actionButtonGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *actionButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *openTil;
@end


@implementation ResturantInterfaceController

- (void)awakeWithContext:(Restaurant *)context {
    [super awakeWithContext:context];
    self.restaurant = context;
    [self.restaurant getWalkDurationWithCompletion:^(NSTimeInterval time, NSError *error) {
        self.restaurantDistance.text = [NSString stringWithFormat:@"%.1f mins walk", time / 60.0];
    }];
    NSLog(@"load restaurant:%@", context);
    
    self.restaurantName.text = context.name;
    self.restaurantCategory.text = context.cuisineStr;
    self.restaurantPrice.text = [context.price valueForKey:@"currency"];
    self.openTil.text = context.openInfo;
    self.restaurantDistance.text = [NSString stringWithFormat:@"%@", @(context.distance.floatValue/1000)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:self.restaurant.imageUrls.firstObject];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *placeholder = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.actionButtonGroup setBackgroundImage:placeholder];
        });
    });
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
    if ([segueIdentifier isEqualToString:@"toRestaurantDetail"]) {
        return self.restaurant;
    }
    
    return self.restaurant;
}

#pragma mark -
- (NSString *)stringFromArray:(NSArray *)array{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *key in array) {
        [string appendFormat:@"%@, ", key];
    }
    return [string substringToIndex:string.length-2];
}
@end



