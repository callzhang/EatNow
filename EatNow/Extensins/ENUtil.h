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

void ENLogError(NSString *fmt, ...);

@interface ENUtil : UIView
+ (instancetype)shared;
+ (void)initLogging;
+ (NSString *)myUUID;
+ (NSString *)generateUUID;
+ (NSDate *)string2date:(NSString *)string;

//time
+ (NSString *)getStringFromTimeInterval:(NSTimeInterval)time;

//HUD
@property (nonatomic, strong) NSMutableArray *HUDs;
+ (JGProgressHUD *)showWatingHUB;
+ (JGProgressHUD *)showSuccessHUBWithString:(NSString *)string;
+ (JGProgressHUD *)showFailureHUBWithString:(NSString *)string;
+ (JGProgressHUD *)showWarningHUBWithString:(NSString *)string;
+ (void)dismissHUD;
+ (UIView *)topView;
+ (UIViewController *)topViewController;

@end

@interface UIView(HUD)
- (JGProgressHUD *)showNotification:(NSString *)alert WithStyle:(HUDStyle)style audoHide:(float)timeout;
- (JGProgressHUD *)showSuccessNotification:(NSString *)alert;
- (JGProgressHUD *)showFailureNotification:(NSString *)alert;
- (JGProgressHUD *)showLoopingWithTimeout:(float)timeout;
- (void)dismissHUD;
@end

@interface UIWindow(Extensions)
+ (UIWindow *)mainWindow;
@end

@interface NSArray(Extend)
- (NSString *)string;
@end

@interface NSDate (Extend)
- (NSString *)string;
/**
 *  2012-04-23T18:25:43.511Z
 *
 *  @return ISO8601 date format
 */
- (NSString *)ISO8601;
@end

@interface UIImage (Blur)
- (UIImage *)bluredImage;
@end