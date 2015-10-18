//
//  ENSocialLoginResponse.h
//  EatNow
//
//  Created by GaoYongqing on 10/18/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ENToken, ENUser;

/**
 *  Response of social login
 */
@interface ENSocialLoginResponse : NSObject

@property (nonatomic,strong) ENToken *token;

@property (nonatomic,strong) ENUser *user;

@end
