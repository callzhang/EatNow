//
//  ResturantInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ResturantInterfaceController.h"
#import "ENRestaurant.h"
#import "AFNetworking.h"
#import "ENMapManager.h"


@interface ResturantInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantCategory;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantDistance;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantPrice;
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *actionButtonGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *actionButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *openTil;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *ratingLabel;
@property (nonatomic, strong) ENMapManager *mapManager;
@end


@implementation ResturantInterfaceController

- (void)awakeWithContext:(ENRestaurant *)context {
    [super awakeWithContext:context];
    self.restaurant = context;
    NSLog(@"load restaurant:%@", context);
    self.mapManager = [[ENMapManager alloc] init];
    
    [self.mapManager estimatedWalkingTimeToLocation:self.restaurant.location
                                         completion:^(NSTimeInterval length, NSError *error) {
                                             self.restaurantDistance.text = [NSString stringWithFormat:@"%.1f mins walk", length / 60.0];
                                         }];
    
    
    self.restaurantName.text = context.name;
    self.restaurantCategory.text = context.cuisineStr;
    self.restaurantPrice.text = [context.price valueForKey:@"currency"];
    self.openTil.text = context.openInfo;
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", context.rating.floatValue];
//    self.restaurantDistance.text = [NSString stringWithFormat:@"%@", @(context.distance.floatValue/1000)];
    
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



