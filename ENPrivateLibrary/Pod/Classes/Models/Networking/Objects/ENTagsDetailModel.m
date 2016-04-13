//
//  ENTagsDetailModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENTagsDetailModel.h"

@implementation ENTagsDetailModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (void)setJustificationsWithNSArray:(NSArray *)array {
    NSMutableArray *justifications = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        ENTagsDetailJustificationModel *justification = [[ENTagsDetailJustificationModel alloc] initWithDictionary:dic error:NULL];
        [justifications addObject:justification];
    }
    self.justifications = [justifications copy];
}


@end
