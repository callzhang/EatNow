//
//  ENSocialLoginResponse.h
//  EatNow
//
//  Created by GaoYongqing on 10/18/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENUser.h"
#import "ENToken.h"

/**
 *  Response of social login
 */
@interface ENSocialLoginResponse : NSObject

- (instancetype)initWithToken:(ENToken *)token andUser:(ENUser *)user;

@property (nonatomic,strong) ENToken *token;

@property (nonatomic,strong) ENUser *user;

@end
