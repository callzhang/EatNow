//
//  BiuSdk.h
//  BiuSdk
//
//  Created by bujiong on 15/12/25.
//  Copyright © 2015年 bujiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiuUser.h"
#import "UserAction.h"
#import "AsyncCallResult.h"

#define ACT_ID  @"eat-now-act1"
#define APP_ID  @"eVhk3ep382MnzX9"

// 回调 block
typedef void (^AsyncResultCallback)(AsyncCallResult *);

@interface BiuSdk : NSObject

+ (BiuSdk *) sharedInstance;

/**
 * 获取当前登录用户
 */
- (BiuUser *) getCurrentUser;

/**
 * 获取用户
 * @param userId 用户id
 * 
 */
- (BiuUser *) getUser:(NSString *)userId;

/******************************************************
 * 异步回调的返回结果指的是callback的回调参数AsyncCallResult
 ******************************************************/

/**
 * 报告行为
 * @param appId 分配的第三方appid [必须]
 * @param actionId 定义的行为id 必须
 * @param targetId 行为对象标识，由第三方解释 [必须]
 * @param desc 本次行为描述 [可选]
 * @param callback 异步回调block [可选]
 * @return 成功code为0，否则非0，同时message描述错误原因
 */
- (void) reportAction:(NSString *)appId
             actionId:(NSString *)actionId
             targetId:(NSString *)targetId
                 desc:(NSString *)desc
             callback:(AsyncResultCallback)callback;

/**
 * 获取用户好友行为
 *
 * @param actionId 要获取的行为id [必须]
 * @param beginTime 开始时间 [必须]
 * @param endTime 结束时间 [必须]
 * @param callback 结果回调 [必须]
 *
 * @return 返回数据类型为UserAction
 */
- (void) getFriendsActions:(NSString *)actionId
                 beginTime:(long)beginTime
                   endTime:(long)endTime
                  callback:(AsyncResultCallback)callback;

@end
