//
//  TMLog.h
//  Pods
//
//  Created by Zitao Xiong on 5/5/15.
//
//

#import <Foundation/Foundation.h>
#define LOG_LEVEL_DEF tmLogLevel
#import <CocoaLumberjack/CocoaLumberjack.h>

#ifdef DEBUG
static const DDLogLevel tmLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel tmLogLevel = DDLogLevelWarning;
#endif