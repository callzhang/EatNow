
//
//  ENCategoryModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENCategoryModel.h"

@implementation ENCategoryModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *map = @{
                          @"id": @"identifier",
                          @"name": @"name",
                          @"global": @"global",
                          @"shortName": @"shortName",
                          @"primary": @"primary",
                          };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}


@end
