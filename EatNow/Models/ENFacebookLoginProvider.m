//
//  ENFacebookLoginProvider.m
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENFacebookLoginProvider.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@implementation ENFacebookLoginProvider
{
    FBSDKLoginManager *_loginManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _loginManager = [FBSDKLoginManager new];
    }
    
    return self;
}

- (NSString *)name
{
    return @"facebook";
}

- (void)loginWithHandler:(ENSocialLoginHandler)handler
{
    [_loginManager logInWithReadPermissions: @[@"public_profile"]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         if (handler) {
             handler(result,error);
         }
         
     }];
}

- (void)logout
{
    [_loginManager logOut];
}

@end
