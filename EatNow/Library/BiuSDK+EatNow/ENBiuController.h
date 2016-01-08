//
//  ENBiuController.h
//  EatNow
//
//  Created by Zitao Xiong on 1/8/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts.h>

@interface ENBiuController : NSObject
+ (instancetype)shared;

- (BFTask *)getFriendActions;
@end
