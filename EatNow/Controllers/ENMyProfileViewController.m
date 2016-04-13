//
//  ENMyProfileViewController.m
//  EatNow
//
//  Created by GaoYongqing on 9/5/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENMyProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SUNSlideSwitchView.h"
#import "CALayer+UIColor.h"
#import <BlocksKit.h>
#import "ENHistoryViewController.h"
#import "ENServerManager.h"
#import <GNMapOpener.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ENMyProfileViewController ()<SUNSlideSwitchViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *profileView;
@property (nonatomic, weak) IBOutlet UIImageView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet SUNSlideSwitchView *switchView;

//History container properties
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIButton *reloadButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *closeMapButton;
@property (nonatomic, weak) IBOutlet UIButton *openInMapsButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) ENHistoryViewController *historyViewController;

@end

@implementation ENMyProfileViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    [self updateUserLabelAndAvatar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdated) name:kUserUpdated object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Actions

- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCloseHistoryCard:(id)sender
{
    [self.historyViewController closeRestaurantView];
}

- (IBAction)onCloseMap:(id)sender
{
    [self.historyViewController.restaurantViewController closeMap];
    self.currentMode = ENMainViewControllerModeHistoryDetail;
}

- (IBAction)onOpenInMap:(id)sender
{
    ENRestaurantViewController *restaurantVC = self.historyViewController.restaurantViewController;
    
    CLLocation *location = restaurantVC.restaurant.location;
    GNMapOpenerItem *item = [[GNMapOpenerItem alloc] initWithLocation:location];
    item.name = restaurantVC.restaurant.name;
    item.directionsType = GNMapOpenerDirectionsTypeWalk;
    [[GNMapOpener sharedInstance] openItem:item presetingViewController:self];
}

- (IBAction)onDeleteHistoryButton:(id)sender
{
    [self.historyViewController deleteHistory];
}

- (void)onUserUpdated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUserLabelAndAvatar];
    });
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
            if (self.historyViewController) {
                return self.historyViewController;
            }
            
            self.historyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ENHistoryViewController"];
            self.historyViewController.mainViewController = self;
            self.historyViewController.mainView = self.cardContainer;
            
            return self.historyViewController;
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
    self.switchView.tabViewBorderColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.45];
    [self.switchView buildUI];
    
    self.headerView.layer.masksToBounds = YES;
    self.headerView.layer.cornerRadius = self.headerView.bounds.size.width / 2.0f;
    
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

- (void)updateUserLabelAndAvatar
{
    NSDictionary *user = [ENServerManager shared].me;
    
    if (!user) {
        return;
    }
    
    NSString *avatarString = user[@"profile_url"];
    [self.headerView setImageWithURL:[NSURL URLWithString:avatarString]];
    NSString *name = user[@"name"];
    if (!name || name.length == 0) {
        name = @"Name";
    }
    self.nameLabel.text = name;
    
    NSMutableString *briefInfo = [[NSMutableString alloc] init];
    
    if (user[@"sex"]) {
        [briefInfo appendString:user[@"sex"]];
    }

    if (user[@"age"]) {
        if (briefInfo.length > 0) {
            [briefInfo appendString:@","];
        }
        id ageObj = [user objectForKey:@"age"];
        if (ageObj) {
            NSInteger age = [ageObj integerValue];
            [briefInfo appendString:[NSString stringWithFormat:@"%ld",(long)age]];
        }
        
    }
    
    if (user[@"address"]) {
        if (briefInfo.length > 0) {
            [briefInfo appendString:@","];
        }
        [briefInfo appendString:[NSString stringWithFormat:@"%@",user[@"address"]]];
    }
    
    if (!briefInfo || briefInfo.length == 0) {
        [briefInfo appendString:@"No details"];
    }
    
    self.detailLabel.text = [briefInfo copy];
}

@end
