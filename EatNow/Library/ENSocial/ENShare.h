//
//  ENShare.h
//  EatNow
//
//  Created by GaoYongqing on 10/13/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENShare : NSObject

+ (instancetype)sharedInstance;

- (void)shareText:(NSString *)text image:(UIImage *)img andLink:(NSURL *)link inViewController:(UIViewController *)vc;

@end
