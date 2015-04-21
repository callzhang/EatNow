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
#define kMapViewDidShow                             @"map_view_did_show"
#define kMapViewDidDismiss                          @"map_view_did_dismiss"

//typedef void (^VoidBlock)();

typedef NS_ENUM(NSInteger, ENRestaurantViewStatus){
    ENRestaurantViewStatusCard,
    ENRestaurantViewStatusDetail,
    ENRestaurantViewStatusMinimum
};

@interface ENRestaurantView : UIView
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (nonatomic, assign) ENRestaurantViewStatus status;
@property (nonatomic, weak) UISnapBehavior *snap;
@property (weak, nonatomic) IBOutlet UIView *info;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

+ (instancetype)loadView;
- (void)switchToStatus:(ENRestaurantViewStatus)status withFrame:(CGRect)frame animated:(BOOL)animate;
- (void)didChangedToFrontCard;
- (void)didDismiss;
@end
