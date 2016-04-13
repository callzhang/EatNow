//
//  ENTagsFailedModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENTagsFailedModel : JSONModel

@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *identifier; // id
@property (nonatomic, strong) NSString *reason;

@end
