//
//  ENTagsFailedModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENTagsFailedModel.h"

@implementation ENTagsFailedModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *map = @{
                          @"tag": @"tag",
                          @"id": @"identifier",
                          @"reason": @"reason"
                          };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}


@end
