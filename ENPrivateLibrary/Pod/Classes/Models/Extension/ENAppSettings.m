//
//  ENAppSettings.m
//  EatNow
//
//  Created by GaoYongqing on 8/27/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENAppSettings.h"

static NSString* const kENSettingCouchStatusKey = @"com.eatnow.setting.couchstatus";
static NSString* const kENSettingMoodKey = @"com.eatnow.setting.mood";

@implementation ENAppSettings

+ (instancetype)sharedInstance
{
    static ENAppSettings *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [ENAppSettings new];
    });
    
    return instance;
}

- (ENCouchStatus)couchStatus
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kENSettingCouchStatusKey];
}

- (void)setCouchStatus:(ENCouchStatus)couchStatus
{
    [[NSUserDefaults standardUserDefaults] setInteger:couchStatus forKey:kENSettingCouchStatusKey];
}

- (NSInteger)mood
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kENSettingMoodKey];
}

- (void)setMood:(NSInteger)mood
{
    [[NSUserDefaults standardUserDefaults] setInteger:mood forKey:kENSettingMoodKey];
}

@end
