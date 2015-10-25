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

- (void)presentLoginActionSheetInViewController:(UIViewController *)viewController withCompletionHandler:(ENSocialLoginHandler)handler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (id<ENSocialLoginProviderProtocol> provider in [[ENSocialLoginManager sharedInstance] providers]) {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:provider.displayName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [provider loginWithHandler:^(ENSocialLoginResponse *resp, NSError *error) {
                
                if (handler) {
                    handler(resp,error);
                }
                
            }];
            
        }];
        
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Private

- (void)setup
{
    ENWechatLoginProvider *wechatProvider = [ENWechatLoginProvider new];
    ENFacebookLoginProvider *fbProvider = [ENFacebookLoginProvider new];
    
    _providers = @[wechatProvider,fbProvider];
    _wechatProvider = wechatProvider;
}

@end
