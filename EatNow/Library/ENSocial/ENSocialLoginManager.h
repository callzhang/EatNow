//
//  ENSocialLoginManager.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENUser.h"
#import "ENSocialLoginProviderProtocol.h"
#import "ENWechatLoginProvider.h"

@interface ENSocialLoginManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  Wechat provider
 */
@property (nonatomic,readonly,strong) ENWechatLoginProvider *wechatProvider;

/**
 *  Supported social login providers
 */
@property (nonatomic, readonly, strong) NSArray *providers;


- (id<ENSocialLoginProviderProtocol>)findProviderByName:(NSString *)providerName;

@end
