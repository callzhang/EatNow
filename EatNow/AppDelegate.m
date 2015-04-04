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
#import "MainViewController.h"
#import "ENServerManager.h"
#import "ENUtil.h"
#import "Crashlytics.h"
@interface AppDelegate()<NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSMutableDictionary *responsesData;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.responsesData = [[NSMutableDictionary alloc] init];
    
    [Crashlytics startWithAPIKey:@"6ec9eab6ca26fcd18d51d0322752b861c63bc348"];
	[ENUtil initLogging];
	ENServerManager *manager = [ENServerManager sharedInstance];
    [manager getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
		[[ENServerManager sharedInstance] getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
			if (!success){
				NSString *str = [NSString stringWithFormat:@"Failed to get restaurant with error: %@", error];
				ENAlert(str);
				
				DDLogError(@"%@", str);
			}
		}];
    }];
    
    
//    NSURL *requestURL = [NSURL URLWithString:@"http://www.google.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"watch-kit-test-google"] delegate:self delegateQueue:nil];
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
//    
//    [task resume];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"%@ remain", @([UIApplication sharedApplication].backgroundTimeRemaining));
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    
    // Temporary fix, I hope.
    // --------------------
//    NSLog(@"%@ remain", @([UIApplication sharedApplication].backgroundTimeRemaining));
//    __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
//    bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
//    });
    // --------------------
    
    __block UIBackgroundTaskIdentifier realBackgroundTask;
    realBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        reply(nil);
//        NSURL *requestURL = [NSURL URLWithString:@"http://www.google.com"];
//        NSURLRequest *reuqest = [NSURLRequest requestWithURL:requestURL];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"watch-kit-test-google"]];
//        NSURLSessionDataTask *task = [session dataTaskWithRequest:reuqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//            reply(@{@"restaurants": data});
//            [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
//        }];
//        
//        [task resume];
        NSURL *requestURL = [NSURL URLWithString:@"http://www.google.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"watch-kit-test-google"] delegate:self delegateQueue:nil];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        
        [task resume];
        
//        [[ENServerManager sharedInstance] watchKitRequestDownloadContentWithCompletion:^(NSData *content) {
//            reply(@{@"restaurants": content});
//            [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
//        }];
        
//        [[ENServerManager sharedInstance] getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
//            NSMutableArray *restaurants = [[ENServerManager sharedInstance] restaurants];
//            reply(@{@"restaurants": restaurants});
//            [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
//        }];
        
    }];
    
    // Kick off a network request, heavy processing work, etc.
    
//    [[ENServerManager sharedInstance] getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
//        NSMutableArray *restaurants = [[ENServerManager sharedInstance] restaurants];
//        reply(@{@"restaurants": restaurants});
//    }];
    
    // Return any data you need to, obviously.
//    reply(nil);
//    [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
}

#pragma mark - 

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"did finished events backgorund :%@", session);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSMutableData *responseData = self.responsesData[@(dataTask.taskIdentifier)];
    if (!responseData) {
        responseData = [NSMutableData dataWithData:data];
        self.responsesData[@(dataTask.taskIdentifier)] = responseData;
    } else {
        [responseData appendData:data];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@ failed: %@", task.originalRequest.URL, error);
    }
    
    NSMutableData *responseData = self.responsesData[@(task.taskIdentifier)];
    
    // my response is JSON; I don't know what yours is, though this handles both
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    if (response) {
        NSLog(@"response = %@", response);
    } else {
        NSLog(@"responseData = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    }
    
    [self.responsesData removeObjectForKey:@(task.taskIdentifier)];
}
@end
