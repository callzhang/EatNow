//
//  ENPriceModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENPriceModel : JSONModel

@property (nonatomic, strong) NSNumber *tier;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *currency;

@end
