//
//  ENAppSettings.h
//  EatNow
//
//  Created by GaoYongqing on 8/27/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ENAppSetting [ENAppSettings sharedInstance]

typedef enum : NSUInteger {
    ENCouchStatusNone = 0,
    ENCouchStatusSwipeCard = 1 << 0,
    ENCouchStatusTapToViewDetail = 1 << 1,
    ENCouchStatusDone = ENCouchStatusSwipeCard | ENCouchStatusTapToViewDetail
} ENCouchStatus;


@interface ENAppSettings : NSObject

+ (instancetype)sharedInstance;

@property (assign, nonatomic) ENCouchStatus couchStatus;
@property (assign, nonatomic) NSInteger mood;

@end
