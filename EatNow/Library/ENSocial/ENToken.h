//
//  ENToken.h
//  EatNow
//
//  Created by GaoYongqing on 10/18/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENToken : NSObject

/**
 *  Token string
 */
@property (nonatomic, copy) NSString *token;

@property (nonatomic, strong) NSDate *refreshDate;

/**
 *  The date which the token would expired.
 */
@property (nonatomic, assign) NSDate *expirationDate;

/**
 *  Refresh token
 */
@property (nonatomic, copy) NSString *refreshToken;

@end
