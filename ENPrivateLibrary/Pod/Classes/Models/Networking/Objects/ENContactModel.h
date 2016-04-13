//
//  ENContactModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENContactModel : JSONModel

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *formattedPhone;
@property (nonatomic, strong) NSString *twitter;
@property (nonatomic, strong) NSString *facebook;

@end
