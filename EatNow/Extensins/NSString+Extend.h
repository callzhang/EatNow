//
//  NSString+Extend.h
//  EatNow
//
//  Created by GaoYongqing on 8/30/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)

/**
 *  Convert current string to a url encoded string
 *
 *  @return A url encoded string
 */
- (NSString *)toUrlEncodedString;

@end
