//
//  UserAction.h
//  biuSdk
//
//  Created by bujiong on 15/12/25.
//  Copyright © 2015年 bujiong. All rights reserved.
//

#ifndef UserAction_h
#define UserAction_h

@interface UserAction : NSObject

// 用户id
@property(nonatomic, strong) NSString *userId;

// 行为id
@property(nonatomic, strong) NSString *actionId;

// 目标id
@property(nonatomic, strong) NSString *targetId;

// 描述
@property(nonatomic, strong) NSString *desc;

// appid
@property(nonatomic, strong) NSString *appId;

// 时间
@property(nonatomic, assign) long time;

@end

#endif /* UserAction_h */
