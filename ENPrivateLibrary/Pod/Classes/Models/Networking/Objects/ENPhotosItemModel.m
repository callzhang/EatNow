//
//  ENPhotosItemModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENPhotosItemModel.h"

@implementation ENPhotosItemModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *map = @{
                          @"type": @"type",
                          @"createAt": @"createAt",
                          @"prefix": @"prefix",
                          @"suffix": @"suffix",
                          @"width": @"width",
                          @"height": @"height",
                          @"tags": @"tags",
                          @"description": @"descriptionString"
                          };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}


@end
