//
//  ENBiuController.h
//  EatNow
//
//  Created by Zitao Xiong on 1/8/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts.h>

@class BiuUser;

@interface ENBiuController : NSObject
+ (instancetype)shared;

- (BFTask *)getFriendActions;
- (BFTask *)getUserByIDAsync:(NSString *)userID;
- (BiuUser *)getUserByID:(NSString *)userID;
- (BFTask *)getCountOfFriends;
@end


UIImage *ENImageFromBase64String(NSString *string);