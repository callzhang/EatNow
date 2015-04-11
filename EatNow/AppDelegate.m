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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Crashlytics startWithAPIKey:@"6ec9eab6ca26fcd18d51d0322752b861c63bc348"];
	[ENUtil initLogging];
//	ENServerManager *manager = [ENServerManager sharedInstance];
//    [manager getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
//		[[ENServerManager sharedInstance] getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
//			if (!success){
//				NSString *str = [NSString stringWithFormat:@"Failed to get restaurant with error: %@", error];
//				ENAlert(str);
//				
//				DDLogError(@"%@", str);
//			}
//		}];
//    }];
    [ENLocationManager registerLocationDeniedHandler:^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Not Enabled" message:@"The app can’t access your current location.\n\nTo enable, please turn on location access in the Settings app under Location Services." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    
    [ENLocationManager registerLocationDisabledHanlder:^{
        [[[UIAlertView alloc] initWithTitle:@"Location disabled" message:@"Location service is needed to provide you the best restaurants around you. Click [Setting] to update the authorization." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Setting", nil] show];
    }];
    
    return YES;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    UIBackgroundTaskIdentifier identifier = [application beginBackgroundTaskWithName:@"watchkit-location-request" expirationHandler:^{
        NSLog(@"expired");
        reply(nil);
        [application endBackgroundTask:identifier];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        reply(@{@"xxxx":@"xxfdsf"});
//        [application endBackgroundTask:identifier];
    ENLocationManager *locationManager = [[ENLocationManager alloc] init];
    [locationManager getLocationWithCompletion:^(CLLocation *location) {
        reply(@{@"location": location});
        [application endBackgroundTask:identifier];
    } forece:YES];
    });
}
@end
