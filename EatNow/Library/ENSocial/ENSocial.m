//
//  ENSocial.m
//  EatNow
//
//  Created by GaoYongqing on 10/15/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENSocial.h"
#import "ENAppSettings.h"
#import "WXApi.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ENSocial () <WXApiDelegate>

@end


@implementation ENSocial

#pragma mark - life cycle

+ (instancetype)sharedInstance
{
    static ENSocial *instance;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [ENSocial new];
    });
    
    return instance;
}

#pragma mark - Public

+ (void)registerWechatApp:(NSString *)appId
{
    [WXApi registerApp:appId];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    DDLogDebug(@"open url:%@, source app:%@",url, sourceApplication);
    
    if ([url.scheme isEqualToString:@"eatnow"]) {
        
        return [self handleDeepLinkUrl:url];
    }
    
    if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if( [sourceApplication isEqualToString:@"com.facebook.Facebook"]){
        
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    return NO;
}

#pragma mark - Weixin api delegate

- (void)onReq:(BaseReq *)req
{
}

- (void)onResp:(BaseResp *)resp
{
}

#pragma mark - URL handling

- (BOOL)handleDeepLinkUrl:(NSURL *)url
{
    if (![url.scheme isEqualToString:@"eatnow"]) {
        
        return NO;
    }
    
//    ENRestaurant *restaurant = [self parseRestaurantFromUrl:url];
//    if (!restaurant) {
//        return NO;
//    }
//    
//    [self.mainViewController showRestaurantAsFrontCard:restaurant];
    
    return YES;
    
}

//- (ENRestaurant *)parseRestaurantFromUrl:(NSURL *)url
//{
//    NSAssert(url.query, @"Invalid deep link url");
//    
//    // Get url data
//    NSArray *params = [url.query componentsSeparatedByString:@"="];
//    if (params.count != 2) {
//        DDLogError(@"Invalid deep link parameter string");
//        return nil;
//    }
//    
//    NSString *dataString = params[1];
//    dataString = [dataString URLDecodedString];
//    
//    NSDictionary *json = [dataString toJson];
//    if (!json) {
//        return nil;
//    }
//    
//    return [[ENRestaurant alloc] initRestaurantWithDictionary:json];
//    
//}

@end
