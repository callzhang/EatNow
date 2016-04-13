//
//  NSString+Extend.m
//  EatNow
//
//  Created by GaoYongqing on 8/30/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "NSString+Extend.h"

@implementation NSString (Extend)

- (NSString *)URLEncodedString
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;

}

- (NSString *)URLDecodedString
{
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark - JSON

- (NSDictionary *)toJson
{
    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
//        DDLogError(@"Convert to json error:%@",error);
        return nil;
    }
    
    return json;
    
}

@end
