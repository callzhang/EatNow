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

@interface ENMyProfileViewController ()<SUNSlideSwitchViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet SUNSlideSwitchView *switchView;


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
            return [self.storyboard instantiateViewControllerWithIdentifier:@"ENProfileMoreViewController"];
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
}

@end
