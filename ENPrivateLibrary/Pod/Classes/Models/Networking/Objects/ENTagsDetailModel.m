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
    if (!array || array.count <= 0) {
        return;
    }
    NSMutableArray *justifications = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        NSError *error;
        ENTagsDetailJustificationModel *justification = [[ENTagsDetailJustificationModel alloc] initWithDictionary:dic error:&error];
        if (error) {
            NSLog(@"ENTagsDetailJustificationModel init error: %@", error.localizedDescription);
        } else {
            [justifications addObject:justification];
        }
    }
    self.justifications = [justifications copy];
}


@end
