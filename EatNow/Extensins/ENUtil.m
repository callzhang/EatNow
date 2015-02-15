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
    parseFormatter.dateFormat = @"EEE, MMM dd";
    return [parseFormatter stringFromDate:date];
}

@end
