//
//  ENTagsDetailModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"
#import "ENTagsDetailJustificationModel.h"

@interface ENTagsDetailModel : JSONModel

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSArray <ENTagsDetailJustificationModel *> *justifications;

@end
