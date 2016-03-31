//
//  ENCategoryModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENCategoryModel : JSONModel

// TODO: _id
@property (nonatomic, strong) NSString *identifier; // id
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *global;
@property (nonatomic, strong) NSString *shortName;
@property (nonatomic) BOOL primary;

@end
