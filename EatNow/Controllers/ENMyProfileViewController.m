//
//  ENMyProfileViewController.m
//  EatNow
//
//  Created by GaoYongqing on 9/5/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENMyProfileViewController.h"

@interface ENMyProfileViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *headerView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;


@end

@implementation ENMyProfileViewController

#pragma mark - Lifecycel

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)onClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
