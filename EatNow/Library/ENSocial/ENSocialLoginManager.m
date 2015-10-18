//
//  ENSocialLoginManager.m
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENSocialLoginManager.h"
#import "ENWechatLoginProvider.h"
#import "ENFacebookLoginProvider.h"

@implementation ENSocialLoginManager

#pragma - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static ENSocialLoginManager *instance;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [ENSocialLoginManager new];
    });
    
    return instance;
}

#pragma mark - Public

- (id<ENSocialLoginProviderProtocol>)findProviderByName:(NSString *)providerName
{
    for (id<ENSocialLoginProviderProtocol> provider in self.providers) {
        if ([provider.name isEqualToString:providerName]) {
            return provider;
        }
    }
    
    return nil;
}

#pragma mark - Private

- (void)setup
{
    ENWechatLoginProvider *wechatProvider = [ENWechatLoginProvider new];
    ENFacebookLoginProvider *fbProvider = [ENFacebookLoginProvider new];
    
    _providers = @[wechatProvider,fbProvider];
}

@end
