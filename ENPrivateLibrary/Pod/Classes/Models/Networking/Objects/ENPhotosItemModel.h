//
//  ENPhotosItemModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENPhotosItemModel : JSONModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *createAt;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSArray <NSString *> *tags;
@property (nonatomic, strong) NSString *descriptionString; // description

@end
