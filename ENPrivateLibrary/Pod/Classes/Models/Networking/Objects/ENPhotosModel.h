//
//  ENPhotosModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"
#import "ENPhotosItemModel.h"

@interface ENPhotosModel : JSONModel

@property (nonatomic, strong) NSNumber *count;
//@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSArray <ENPhotosItemModel *> *items;

@end
