//
//  ENTagsModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENTagsModel.h"

@implementation ENTagsModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (void)setDetailsWithNSArray:(NSArray *)array {
    NSMutableArray *details = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        ENTagsDetailModel *detail = [[ENTagsDetailModel alloc] initWithDictionary:dic error:NULL];
        [details addObject:detail];
    }
    self.details = [details copy];
}

- (void)setFailedWithNSArray:(NSArray *)array {
    NSMutableArray *faileds = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        ENTagsFailedModel *failed = [[ENTagsFailedModel alloc] initWithDictionary:dic error:NULL];
        [faileds addObject:failed];
    }
    self.failed = [faileds copy];
}

@end
