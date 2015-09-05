//
//  ENUser.h
//  EatNow
//
//  Created by GaoYongqing on 9/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENUser : NSObject

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *avatarUrl;

@property (nonatomic, copy) NSString *address;

@property (nonatomic, strong) NSDate *dayOfBirth;

@end
