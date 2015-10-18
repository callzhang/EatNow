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
/**
 *  Token expired million seconds since 1970/1/1
 */
@property (nonatomic, assign) NSUInteger expired;

/**
 *  Refresh token
 */
@property (nonatomic, copy) NSString *refreshToken;

@end
