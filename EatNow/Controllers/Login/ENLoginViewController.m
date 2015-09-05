//
//  ENLoginViewController.m
//  EatNow
//
//  Created by GaoYongqing on 9/3/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENLoginViewController.h"
#import "ENWechatLoginProvider.h"
#import "ENFacebookLoginProvider.h"
#import "FBSDKCoreKit.h"

@interface ENLoginViewController ()

@end

@implementation ENLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onWechatLogin:(id)sender
{    
    ENFacebookLoginProvider *provider = [ENFacebookLoginProvider new];
    [provider loginWithHandler:^(id resp, NSError *error) {
        
        FBSDKProfile *profile = [FBSDKProfile currentProfile];
        
        DDLogDebug(@"FB Access token: %@",[FBSDKAccessToken currentAccessToken]);
        
    }];
}

@end
