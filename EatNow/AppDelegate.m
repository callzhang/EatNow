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
#import "Crashlytics.h"
#import "ENLocationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "ATConnect.h"
#import "UIImageView+AFNetworking.h"
#import "WatchKitAction.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ATConnect sharedConnection].apiKey = @"43aadd17c4e966f98753bcb1250e78d00c68731398a9b60dc7c456d2682415fc";
    [Crashlytics startWithAPIKey:@"6ec9eab6ca26fcd18d51d0322752b861c63bc348"];
    [ENUtil initLogging];
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
    return YES;
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
@end
