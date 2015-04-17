//
//  ENRestaurantView.h
//  EatNow
//
//  Created by Lei Zhang on 4/10/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENRestaurant.h"

#define kRestaurantViewImageChangedNotification     @"restaurant_view_image_changed"
#define kSelectedRestaurantNotification				@"selected_restaurant"

//typedef void (^VoidBlock)();

typedef NS_ENUM(NSInteger, ENRestaurantViewStatus){
    ENRestaurantViewStatusCard,
    ENRestaurantViewStatusDetail,
    ENRestaurantViewStatusMinimum
};

@interface ENRestaurantView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (nonatomic, assign) ENRestaurantViewStatus status;
@property (nonatomic, weak) UISnapBehavior *snap;

+ (instancetype)loadView;
- (void)switchToStatus:(ENRestaurantViewStatus)status withFrame:(CGRect)frame animated:(BOOL)animate;
- (void)didChangedToFrontCard;
@end
