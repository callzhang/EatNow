//
//  ENBiuController.m
//  EatNow
//
//  Created by Zitao Xiong on 1/8/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import "ENBiuController.h"
#import "BiuSdk.h"
#import "ENBiuError.h"

@implementation ENBiuController
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static ENBiuController *controller = nil;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] init];
    });
    return controller;
}

- (BFTask *)validateAndSetAsyncCallResult:(AsyncCallResult *)result {
    if (result.dataClsName.length <= 0 || ![result.data isKindOfClass:[NSArray class]]) {
        return [BFTask taskWithError:[NSError biuErrorWithCode:ENBiuErrorCodeClassMisMatch userInfo:nil]];
    }
    
    NSArray *results = (NSArray *)result.data;
    if (!results.firstObject) {
        return [BFTask taskWithResult:nil];
    }
    
    if ([results.firstObject isKindOfClass:NSClassFromString(result.dataClsName)]) {
        return [BFTask taskWithResult:results];
    }
    else {
        return [BFTask taskWithError:[NSError biuErrorWithCode:ENBiuErrorCodeClassMisMatch userInfo:nil]];
    }
}

- (BFTask *)getCountOfFriends {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    [[BiuSdk sharedInstance] getFriendsActions:@"friends.go.to.this.restaurant" beginTime:[[NSDate dateWithTimeIntervalSince1970:0] timeIntervalSince1970] endTime:[[NSDate date] timeIntervalSince1970] callback:^(AsyncCallResult *result) {
        BFTask *task = [self validateAndSetAsyncCallResult:result];
        if (task.isFaulted) {
            [taskSource setError:task.error];
        }
        else {
            if ([task.result isKindOfClass:[NSArray class]]) {
                [taskSource setResult:@([task.result count])];
            }
        }
    }];
    
    return taskSource.task;
}

- (BFTask *)getFriendActions {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    [[BiuSdk sharedInstance] getFriendsActions:@"friends.go.to.this.restaurant" beginTime:[[NSDate dateWithTimeIntervalSince1970:0] timeIntervalSince1970] endTime:[[NSDate date] timeIntervalSince1970] callback:^(AsyncCallResult *result) {
        BFTask *task = [self validateAndSetAsyncCallResult:result];
        if (task.isFaulted) {
            [taskSource setError:task.error];
        }
        else {
            [taskSource setResult:task.result];
        }
    }];
    
    return taskSource.task;
}

- (BFTask *)getUserByIDAsync:(NSString *)userID {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    BiuUser *user = [[BiuSdk sharedInstance] getUser:userID];
    
    [taskSource setResult:user];
    
    return taskSource.task;
}

- (BiuUser *)getUserByID:(NSString *)userID {
    BiuUser *user = [[BiuSdk sharedInstance] getUser:userID];
    return user;
}
@end

UIImage *ENImageFromBase64String(NSString *string) {
    NSURL *url = [NSURL URLWithString:string];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:imageData];
}