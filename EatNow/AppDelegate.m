//
// AppDelegate.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "AppDelegate.h"
#import "ENMainViewController.h"
#import "ENServerManager.h"
#import "ENUtil.h"
#import "ENLocationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "ATConnect.h"
#import "UIImageView+AFNetworking.h"
#import "WatchKitAction.h"
#import "CrashlyticsLogger.h"
#import <Fabric/Fabric.h>
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import <Crashlytics/crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initilizeLogging];

    [ATConnect sharedConnection].apiKey = @"43aadd17c4e966f98753bcb1250e78d00c68731398a9b60dc7c456d2682415fc";
    [Fabric with:@[CrashlyticsKit]];
    [Fabric sharedSDK].debug = YES;
    //[Crashlytics startWithAPIKey:@"6ec9eab6ca26fcd18d51d0322752b861c63bc348"];
    
    [ENLocationManager registerLocationDeniedHandler:^{
        [UIAlertView bk_showAlertViewWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
    }];
    
    [ENLocationManager registerLocationDeniedHandler:^{
        [UIAlertView bk_showAlertViewWithTitle:@"Location disabled" message:@"Location service is needed to provide you the best restaurants around you. Click [Setting] to update the authorization." cancelButtonTitle:nil otherButtonTitles:@[@"Setting"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
    }];
    
    if ([ENLocationManager locationServicesState] == INTULocationServicesStateAvailable) {
        ENMainViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENMainViewController"];
        [UIWindow mainWindow].rootViewController = vc;
    }
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([ENLocationManager locationServicesState] != INTULocationServicesStateAvailable) {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENGetLocationViewController"];
        [UIWindow mainWindow].rootViewController = vc;
    }
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
//    NSLog(@"got watchkit request: %@", userInfo);
    NSError *error;
    WatchKitAction *action = [[WatchKitAction alloc] initWithDictionary:userInfo error:&error];
    if (error) {
        NSLog(@"parse action error:%@", error);
    }
    
    __block UIBackgroundTaskIdentifier identifier;
    identifier = [application beginBackgroundTaskWithName:[NSString stringWithFormat:@"watchkit-location-request-%@",action.url] expirationHandler:^{
        NSLog(@"expired");
        reply(nil);
        [application endBackgroundTask:identifier];
        identifier = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [action performActionForApplication:application withCompletionHandler:^(WatchKitResponse *response) {
            reply(response.toDictionary);
            //wait 2 secs to make sure reply to compelete
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [application endBackgroundTask:identifier];
                identifier = UIBackgroundTaskInvalid;
            });

        }];
    });
}

- (void)initilizeLogging {
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
@end
