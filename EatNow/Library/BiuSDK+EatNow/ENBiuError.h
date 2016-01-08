//
//  ENBiuError.h
//  EatNow
//
//  Created by Zitao Xiong on 1/8/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ENBiuErrorDomain;

typedef enum : NSUInteger {
    ENBiuErrorCodeUnkown = -1,
    ENBiuErrorCodeClassMisMatch = -998,
} ENBiuErrorCode;

@interface NSError (ENBiuError)
+ (instancetype)biuErrorWithCode:(NSInteger)errorCode userInfo:(NSDictionary *)userInfo;
@end
