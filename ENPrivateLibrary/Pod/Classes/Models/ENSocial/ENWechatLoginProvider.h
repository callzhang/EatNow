//
//  WechatLoginProvider.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENSocialLoginProviderProtocol.h"

@interface ENWechatLoginProvider : NSObject <ENSocialLoginProviderProtocol>

/**
 *  Handle response from url
 *
 *  @param resp The response
 */
- (void)handleResponse:(id)resp;

@end
