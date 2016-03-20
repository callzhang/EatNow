//
//  NSDictionary+Extend.m
//  EatNow
//
//  Created by GaoYongqing on 8/30/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "NSDictionary+Extend.h"

@implementation NSDictionary (Extend)

- (NSString *)toJsonString
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Serial to json string error: %@", error);
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
