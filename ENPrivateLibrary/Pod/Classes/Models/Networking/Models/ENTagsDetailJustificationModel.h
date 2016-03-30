//
//  ENTagsDetailJustificationModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENTagsDetailJustificationModel : JSONModel

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *total;

@end
