//
//  ENMyProfileViewController.m
//  EatNow
//
//  Created by GaoYongqing on 9/5/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENMyProfileViewController.h"
#import "SUNSlideSwitchView.h"
#import "CALayer+UIColor.h"
#import <BlocksKit.h>
#import "ENHistoryViewController.h"

@interface ENMyProfileViewController ()<SUNSlideSwitchViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *profileView;
@property (nonatomic, weak) IBOutlet UIImageView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet SUNSlideSwitchView *switchView;

//
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIButton *reloadButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *closeMapButton;
@property (nonatomic, weak) IBOutlet UIButton *openInMapsButton;

@end

@implementation ENMyProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}


#pragma mark - Actions

- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SUNSlideSwitchViewDelegate

- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view
{
    return 2;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    switch (number) {
        case 0:
        {
            ENHistoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ENHistoryViewController"];
            vc.mainViewController = self;
            vc.mainView = self.detailView;
            
            return vc;
        }
        case 1:
            return [self.storyboard instantiateViewControllerWithIdentifier:@"ENProfileMoreViewController"];
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UI

- (void)setupUI
{
    self.switchView.tabItemNormalColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35];
    self.switchView.tabItemSelectedColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    [self.switchView buildUI];
    
    self.currentMode = ENMainViewControllerModeStart;
}

- (void)setCurrentMode:(ENMainViewControllerMode)mode {
    
    _currentMode = mode;
    
    switch (_currentMode) {
        case ENMainViewControllerModeStart:{
            [self showControllers:@[self.profileView]];
            break;
        }
        case ENMainViewControllerModeMain: {
            [self showControllers:@[self.containerView, self.reloadButton, self.shareButton]];
            break;
        }
        case ENMainViewControllerModeDetail: {
            [self showControllers:@[self.containerView, self.closeButton,self.shareButton]];
            break;
        }
        case ENMainViewControllerModeHistory: {
            [self showControllers:@[self.profileView]];
            break;
        }
        case ENMainViewControllerModeHistoryDetail: {
            [self showControllers:@[self.containerView, self.closeButton]];
            break;
        }
        case ENMainViewControllerModeMap: {
            [self showControllers:@[self.containerView, self.closeMapButton, self.openInMapsButton]];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)showControllers:(NSArray *)controls animated:(BOOL)animated {
    [self showViews:controls inAllViews:@[self.reloadButton, self.shareButton, self.closeButton, self.closeMapButton, self.openInMapsButton,self.profileView,self.containerView] animated:animated];
}

- (void)showControllers:(NSArray *)controls {
    [self showControllers:controls animated:YES];
}

- (void)showViews:(NSArray *)showViews inAllViews:(NSArray *)allViews animated:(BOOL)animated {
    NSArray *hideViews = [allViews bk_reject:^BOOL(id obj) {
        return [showViews containsObject:obj];
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [showViews bk_each:^(UIView *obj) {
                obj.alpha = 1.0f;
            }];
            
            [hideViews bk_each:^(UIView *obj) {
                obj.alpha = 0.0f;
            }];
        }];
    }
    else {
        [showViews bk_each:^(UIView *obj) {
            obj.alpha = 1.0f;
        }];
        
        [hideViews bk_each:^(UIView *obj) {
            obj.alpha = 0.0f;
        }];
    }
}

@end
