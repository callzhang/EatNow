//
//  ENRestaurantView.h
//  EatNow
//
//  Created by Lei Zhang on 4/10/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

#define kRestaurantViewImageChangedNotification     @"restaurant_view_image_changed"

typedef NS_ENUM(NSInteger, ENRestaurantViewStatus){
    ENRestaurantViewStatusCard,
    ENRestaurantViewStatusDetail
};

@interface ENRestaurantView : UIView
@property (nonatomic, strong) Restaurant *restaurant;
@property (nonatomic, assign) ENRestaurantViewStatus status;
@property (nonatomic, weak) UISnapBehavior *snap;

+ (instancetype)loadView;
@end
