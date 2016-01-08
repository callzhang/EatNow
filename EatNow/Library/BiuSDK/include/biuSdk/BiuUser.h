//
//  BiuUser.h
//  biuSdk
//
//  Created by bujiong on 15/12/25.
//  Copyright © 2015年 bujiong. All rights reserved.
//

#ifndef BiuUser_h
#define BiuUser_h

@interface BiuUser : NSObject

// 用户id
@property(nonatomic, strong) NSString *userId;

// 不囧号
@property(nonatomic, strong) NSString *biuId;

// 用户昵称
@property(nonatomic, strong) NSString *nickname;

// 图像（base64）
@property(nonatomic, strong) NSString *avatar;

// 最近位置(经纬度)
@property(nonatomic, strong) NSNumber *longitude;

@property(nonatomic, strong) NSNumber *latitude;

// 所在位置（城市）
@property(nonatomic, strong) NSString *location;

// 邮箱
@property(nonatomic, strong) NSString *email;

// 性别
@property(nonatomic, strong) NSNumber *sex;

// 地址
@property(nonatomic, strong) NSString *address;

// 个性签名
@property(nonatomic, strong) NSString *signature;

@end

#endif /* BiuUser_h */
