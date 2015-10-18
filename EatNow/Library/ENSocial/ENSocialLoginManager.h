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

@interface ENSocialLoginManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  Supported social login providers
 */
@property (nonatomic, readonly, strong) NSArray *providers;


- (id<ENSocialLoginProviderProtocol>)findProviderByName:(NSString *)providerName;

@end
