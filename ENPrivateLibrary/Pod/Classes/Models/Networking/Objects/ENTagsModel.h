//
//  ENTagsModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"
#import "ENTagsDetailModel.h"
#import "ENTagsFailedModel.h"

@interface ENTagsModel : JSONModel

@property (nonatomic, strong) NSNumber *count;
//@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSArray <NSString *> *items;
@property (nonatomic, strong) NSArray <ENTagsDetailModel *> *details;
@property (nonatomic, strong) NSArray <ENTagsFailedModel *> *failed;

@end
