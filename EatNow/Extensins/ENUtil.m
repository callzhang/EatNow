//
//  ENUtil.m
//  EatNow
//
//  Created by Lee on 2/13/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENUtil.h"
#import <CrashlyticsLogger.h>
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "JGProgressHUD.h"
#import "JGProgressHUDSuccessIndicatorView.h"
#import "JGProgressHUDErrorIndicatorView.h"
#import "JGProgressHUDFadeZoomAnimation.h"
#import "AppDelegate.h"
@import UIKit;
DDLogLevel const ddLogLevel = DDLogLevelVerbose;

@implementation ENUtil
+ (void)initLogging{
	[DDLog addLogger:[DDASLLogger sharedInstance]];
	DDTTYLogger *log = [DDTTYLogger sharedInstance];
	[DDLog addLogger:log];
	
	// we also enable colors in Xcode debug console
	// because this require some setup for Xcode, commented out here.
	// https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/XcodeColors
	[log setColorsEnabled:YES];
	[log setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
	[log setForegroundColor:[UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0] backgroundColor:nil forFlag:LOG_FLAG_WARN];
	[log setForegroundColor:[UIColor orangeColor] backgroundColor:nil forFlag:LOG_FLAG_INFO];
	//white for debug
	[log setForegroundColor:[UIColor darkGrayColor] backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
	
	//file logger
	DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
	fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
	fileLogger.logFileManager.maximumNumberOfLogFiles = 7;//keep a week's log
	[DDLog addLogger:fileLogger];
	
	//crashlytics logger
	[DDLog addLogger:[CrashlyticsLogger sharedInstance]];
}

+ (NSString *)myUUID{
    NSString *myID = [[NSUserDefaults standardUserDefaults] objectForKey:kUUID];
    if (!myID) {
        myID = [self generateUUID];
        [[NSUserDefaults standardUserDefaults] setObject:myID forKey:kUUID];
    }
    return myID;
}

+ (NSString *)generateUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return (__bridge NSString *)string;
}

+ (NSString *)date2String:(NSDate *)date{
    NSDateFormatter *parseFormatter = [[NSDateFormatter alloc] init];
    parseFormatter.timeZone = [NSTimeZone defaultTimeZone];
    parseFormatter.dateFormat = @"M-d";
    return [parseFormatter stringFromDate:date];
}

+ (NSString *)array2String:(NSArray *)array{
    
    if (array.count == 0) {
        return @"";
    }
    NSMutableString *string = [NSMutableString new];
    for (NSString *c in array) {
        [string appendFormat:@"%@, ", c];
    }
    [string deleteCharactersInRange:NSMakeRange(string.length-2, 2)];
    return string.copy;
}

#pragma mark - HUD
+ (void)showSuccessHUBWithString:(NSString *)string{
    UIView *rootView = [self getTopView];
    [rootView showSuccessNotification:string];
}

+ (void)showFailureHUBWithString:(NSString *)string{
    UIView *rootView = [self getTopView];
    [rootView showFailureNotification:string];
}

+ (void)showWarningHUBWithString:(NSString *)string{
    UIView *rootView = [self getTopView];
    [rootView showNotification:string WithStyle:hudStyleWarning audoHide:5];
}

+ (void)showWatingHUB{
    UIView *rootView = [self getTopView];
    [rootView showLoopingWithTimeout:0];
}

+ (UIView *)getTopView{
    UIView *rootView;
    UIViewController *rootController = [UIWindow mainWindow].rootViewController;
    if (rootController.presentedViewController) {
        rootController = rootController.presentedViewController;
    }
    if ([rootController isKindOfClass:[UINavigationController class]]) {
        rootView = [(UINavigationController *)rootController topViewController].view;
    }else{
        rootView = rootController.view;
    }
    return rootView;
}

+ (UIViewController *)topViewController{
    UIViewController *rootController = [UIWindow mainWindow].rootViewController;
    if (rootController.presentedViewController) {
        rootController = rootController.presentedViewController;
    }
    if ([rootController isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)rootController topViewController];
    }else{
        return  rootController;
    }
    return nil;
}

+ (void)dismissHUDinView:(UIView *)view{
    NSArray *huds = [JGProgressHUD allProgressHUDsInView:view];
    for (JGProgressHUD *hud in huds) {
        [hud dismiss];
    }
}

@end


@implementation UIView(HUD)

- (JGProgressHUD *)showNotification:(NSString *)alert WithStyle:(HUDStyle)style audoHide:(float)timeout{
    for (JGProgressHUD *hud in [JGProgressHUD allProgressHUDsInView:self]) {
        [hud dismiss];
    }
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        JGProgressHUDFadeZoomAnimation *an = [JGProgressHUDFadeZoomAnimation animation];
        hud.animation = an;
        hud.textLabel.text = alert;
        switch (style) {
            case hudStyleSuccess:
                hud.indicatorView = [JGProgressHUDSuccessIndicatorView new];
                break;
                
            case hudStyleFailed:
                hud.indicatorView = [JGProgressHUDErrorIndicatorView new];
                break;
                
            case hudStyleWarning:
                hud.indicatorView = [[JGProgressHUDIndicatorView alloc] initWithContentView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning_37x"]]];
                break;
                
            default:
                break;
        }
        [hud showInView:self];
        if (timeout > 0) {
            [hud dismissAfterDelay:timeout];
        }
        
    });
    return hud;
}

- (JGProgressHUD *)showSuccessNotification:(NSString *)alert{
    return [self showNotification:alert WithStyle:hudStyleSuccess audoHide:4];
}

- (JGProgressHUD *)showFailureNotification:(NSString *)alert{
    return [self showNotification:alert WithStyle:hudStyleFailed audoHide:4];
}

- ( JGProgressHUD*)showLoopingWithTimeout:(float)timeout{
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    hud.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud showInView:self];
        if (timeout > 0) {
            [hud dismissAfterDelay:timeout];
        }
    });
    
    return hud;
}

@end

@implementation UIWindow (Extensions)
+ (UIWindow *)mainWindow {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return delegate.window;
}
@end