//
//  ENUtil.h
//  EatNow
//
//  Created by Lee on 2/13/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENDefines.h"

#define kUUID                       @"UUID"

extern DDLogLevel const ddLogLevel;
@interface ENUtil : UIView
+ (void)initLogging;
+ (NSString *)myUUID;
+ (NSString *)generateUUID;
+ (NSString *)date2String:(NSDate *)date;
@end
