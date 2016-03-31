//
//  ENLocationModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENLocationModel.h"

@implementation ENLocationModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *map = @{
                          @"address": @"address",
                          @"city": @"city",
                          @"state": @"state",
                          @"country": @"country",
                          @"cc": @"countryCode",
                          @"postalCode": @"postalCode",
                          @"formattedAddress": @"formattedAddress",
                          @"lng": @"longitude",
                          @"lat": @"latitude"
                          };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}


@end
