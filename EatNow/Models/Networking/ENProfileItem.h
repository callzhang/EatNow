//
//  ENProfileItem.h
//  EatNow
//
//  Created by GaoYongqing on 10/7/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ENProfileItemActionBlock)(id sender);

@interface ENProfileItem : NSObject

- (instancetype)initWithTitle:(NSString *)title value:(NSString *)value;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, copy) ENProfileItemActionBlock actionBlock;

@end
