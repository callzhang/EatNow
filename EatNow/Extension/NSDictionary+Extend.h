//
//  NSDictionary+Extend.h
//  EatNow
//
//  Created by GaoYongqing on 8/30/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extend)

/**
 *  Convert dictionary to a UTF-8 encoded string
 *
 *  @return A UTF-8 encoded string represents the dictionary
 */
- (NSString *)toJsonString;


@end
