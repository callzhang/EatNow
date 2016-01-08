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

- (BFTask *)getFriendActions {
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    [[BiuSdk sharedInstance] getFriendsActions:@"friends.go.to.this.restaurant" beginTime:[[NSDate dateWithTimeIntervalSince1970:0] timeIntervalSince1970] endTime:[[NSDate date] timeIntervalSince1970] callback:^(AsyncCallResult *result) {
        if (result.dataClsName.length <= 0 || ![result.data isKindOfClass:[NSArray class]]) {
            [taskSource setError:[NSError biuErrorWithCode:ENBiuErrorCodeClassMisMatch userInfo:nil]];
            return ;
        }
        
        NSArray *results = (NSArray *)result.data;
        if (!results.firstObject) {
            [taskSource setResult:nil];
            return;
        }
        
        if ([results.firstObject isKindOfClass:NSClassFromString(result.dataClsName)]) {
            [taskSource setResult:results];
        }
        else {
            [taskSource setError:[NSError biuErrorWithCode:ENBiuErrorCodeClassMisMatch userInfo:nil]];
        }
    }];
    
    return taskSource.task;
}
@end
