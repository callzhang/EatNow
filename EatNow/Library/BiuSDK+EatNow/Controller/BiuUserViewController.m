//
//  BiuUserViewController.m
//  EatNow
//
//  Created by Zitao Xiong on 3/1/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import "BiuUserViewController.h"

@interface BiuUserViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;

@end

@implementation BiuUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameLabel.text = [NSString stringWithFormat:@"User Name: %@", self.user.nickname];
    self.userIdLabel.text = [NSString stringWithFormat:@"User ID: %@", self.user.userId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
