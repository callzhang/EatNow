//
//  ENRestaurantView.h
//  EatNow
//
//  Created by Lei Zhang on 4/10/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENRestaurant.h"


extern NSString * const kRestaurantViewImageChangedNotification;
extern NSString * const kSelectedRestaurantNotification;
extern NSString * const kMapViewDidShow;
extern NSString * const kMapViewDidDismiss;

typedef NS_ENUM(NSInteger, ENRestaurantViewStatus){
    ENRestaurantViewStatusCard,
    ENRestaurantViewStatusDetail,
    ENRestaurantViewStatusMinimum,
    ENRestaurantViewStatusHistoryDetail,
};

@protocol ENCardViewControllerProtocol <NSObject>
@property (nonatomic, weak) UISnapBehavior *snap;
@property (nonatomic, readonly) BOOL canSwipe;
- (void)didChangedToFrontCard;

@end

@interface ENRestaurantViewController : UIViewController<ENCardViewControllerProtocol>
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (nonatomic, assign) ENRestaurantViewStatus status;
@property (nonatomic, weak) UISnapBehavior *snap;
@property (weak, nonatomic) IBOutlet UIView *info;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UIButton *goButton;

+ (instancetype)viewController;
- (void)switchToStatus:(ENRestaurantViewStatus)status withFrame:(CGRect)frame animated:(BOOL)animate completion:(VoidBlock)block;
- (void)didChangedToFrontCard;
- (void)addViewDidLayoutBlock:(VoidBlock)block;
- (void)updateLayout;
@end
