//
//  ResturantInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ResturantInterfaceController.h"
#import "Restaurant.h"


@interface ResturantInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantRating;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantCategory;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantHighlights;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantDistance;
@property (nonatomic, strong) Restaurant *restaurant;
@end


@implementation ResturantInterfaceController

- (void)awakeWithContext:(Restaurant *)context {
    [super awakeWithContext:context];
    
    self.restaurantName.text = context.name;
    self.restaurantRating.text = [NSString stringWithFormat:@"%.2f", [context.rating floatValue]];
    self.restaurantCategory.text = [self stringFromArray:context.cuisines];
    self.restaurantHighlights.text = context.name;
    self.restaurantDistance.text = [NSString stringWithFormat:@"%@", @(context.distance)];
    
    self.restaurant = context;
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



