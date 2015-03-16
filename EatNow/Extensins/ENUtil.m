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
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    __strong static ENUtil *sharedInstance_;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [ENUtil new];
    });
    return sharedInstance_;
}

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

+ (NSDate *)string2date:(NSString *)string{
    NSDateFormatter *parseFormatter = [[NSDateFormatter alloc] init];
    parseFormatter.timeZone = [NSTimeZone defaultTimeZone];
    [parseFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date = [parseFormatter dateFromString:string];
    return date;
}

+ (NSString *)getStringFromTimeInterval:(NSTimeInterval)time{
	
	NSString *timeStr;
	time = fabs(time);
	NSInteger t = (NSInteger)time;
	CGFloat days = time / 3600 / 24;
	CGFloat hours = (t % (3600*24)) / 3600;
	CGFloat minutes = floor((t % 3600)/60);
	CGFloat seconds = t % 60;
	
	if (days >=2) {
		timeStr = [NSString stringWithFormat:@"%ld days", (long)days];
	}else if (days >=1) {
		timeStr = [NSString stringWithFormat:@"1 day %ld hours", (long)hours-24];
	}else if (hours > 10) {
		timeStr = [NSString stringWithFormat:@"%ld hours", (long)(hours)];
	}else if (hours >= 1){
		timeStr = [NSString stringWithFormat:@"%.1f hours", hours + minutes/60];
	}else if(minutes >= 1){
		timeStr = [NSString stringWithFormat:@"%ld minutes",(long)minutes];
	}else{
		timeStr = [NSString stringWithFormat:@"%ld seconds",(long)seconds];
	}
	return timeStr;
}

#pragma mark - HUD
- (instancetype)init{
    self = [super init];
    if (self) {
        self.HUDs = [NSMutableArray new];
    }
    return self;
}

+ (JGProgressHUD *)showSuccessHUBWithString:(NSString *)string{
    UIView *rootView = [self topView];
    JGProgressHUD *hud = [rootView showSuccessNotification:string];
    [[ENUtil shared].HUDs addObject:hud];
    return hud;
}

+ (JGProgressHUD *)showFailureHUBWithString:(NSString *)string{
    UIView *rootView = [self topView];
    JGProgressHUD *hud = [rootView showFailureNotification:string];
    [[ENUtil shared].HUDs addObject:hud];
    return hud;
}

+ (JGProgressHUD *)showWarningHUBWithString:(NSString *)string{
    UIView *rootView = [self topView];
    JGProgressHUD *hud = [rootView showNotification:string WithStyle:hudStyleWarning audoHide:4];
    [[ENUtil shared].HUDs addObject:hud];
    return hud;
}

+ (JGProgressHUD *)showWatingHUB{
    [self dismissHUD];
    UIView *rootView = [self topView];
    JGProgressHUD *hud = [rootView showLoopingWithTimeout:0];
    [[ENUtil shared].HUDs addObject:hud];
    return hud;
}

+ (UIView *)topView{
    return [self topViewController].view;
}

+ (UIViewController *)topViewController{
    UIViewController *rootController = [UIWindow mainWindow].rootViewController;
    while (rootController.presentedViewController) {
        rootController = rootController.presentedViewController;
    }
    if ([rootController isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)rootController topViewController];
    }else{
        return  rootController;
    }
    return nil;
}

+ (void)dismissHUD{
    for (JGProgressHUD *hud in [ENUtil shared].HUDs) {
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
                hud.indicatorView = [[JGProgressHUDIndicatorView alloc] initWithContentView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]]];
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
    return [self showNotification:alert WithStyle:hudStyleSuccess audoHide:2];
}

- (JGProgressHUD *)showFailureNotification:(NSString *)alert{
    return [self showNotification:alert WithStyle:hudStyleFailed audoHide:2];
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

- (void)dismissHUD{
    NSArray *huds = [JGProgressHUD allProgressHUDsInView:self];
    for (JGProgressHUD *hud in huds) {
        [hud dismiss];
    }
}

@end

@implementation UIWindow (Extensions)
+ (UIWindow *)mainWindow {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return delegate.window;
}
@end

@implementation NSArray(Extend)

- (NSString *)string{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *key in self) {
        [string appendFormat:@"%@, ", key];
    }
    return [string substringToIndex:string.length-2];
}

@end

@implementation NSDate (Extend)

- (NSString *)string{
    NSDateFormatter *parseFormatter = [[NSDateFormatter alloc] init];
    parseFormatter.timeZone = [NSTimeZone defaultTimeZone];
    parseFormatter.dateFormat = @"M/d";
    return [parseFormatter stringFromDate:self];
}

@end

