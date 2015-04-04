//
//  InterfaceController.m
//  EatNow WatchKit Extension
//
//  Created by Zitao Xiong on 4/1/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSURL *requestURL = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *reuqest = [NSURLRequest requestWithURL:requestURL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:reuqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"got: %@", data);
    }];
    
    [task resume];
    
    [[self class] openParentApplication:@{} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSLog(@"response:%@", replyInfo);
        
        NSMutableArray *restaurants = [NSMutableArray array];
        NSMutableArray *objests = [NSMutableArray array];
        for (NSUInteger i = 0; i < 12; i++) {
            [restaurants addObject:@"ResturantInterfaceController"];
            [objests addObject:@(i)];
        }
        [WKInterfaceController reloadRootControllersWithNames:restaurants contexts:objests];
    }];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



