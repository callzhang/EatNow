//
//  ENUtil.h
//  EatNow
//
//  Created by Lee on 2/13/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENDefines.h"
#import "JGProgressHUD.h"
typedef enum{
    hudStyleSuccess,
    hudStyleFailed,
    hudStyleWarning,
    HUDStyleInfo
}HUDStyle;
#define kUUID                       @"UUID"

extern DDLogLevel const ddLogLevel;
@interface ENUtil : UIView
+ (void)initLogging;
+ (NSString *)myUUID;
+ (NSString *)generateUUID;
+ (NSString *)date2String:(NSDate *)date;
+ (NSString *)array2String:(NSArray *)array;

//HUD
+ (void)showWatingHUB;
+ (void)showSuccessHUBWithString:(NSString *)string;
+ (void)showFailureHUBWithString:(NSString *)string;
+ (void)showWarningHUBWithString:(NSString *)string;
+ (void)dismissHUDinView:(UIView *)view;
+ (UIView *)getTopView;
+ (UIViewController *)topViewController;

@end

@interface UIView(HUD)

- (JGProgressHUD *)showNotification:(NSString *)alert WithStyle:(HUDStyle)style audoHide:(float)timeout;
- (JGProgressHUD *)showSuccessNotification:(NSString *)alert;
- (JGProgressHUD *)showFailureNotification:(NSString *)alert;
- (JGProgressHUD *)showLoopingWithTimeout:(float)timeout;
@end

@interface UIWindow(Extensions)
+ (UIWindow *)mainWindow;
@end