//
//  ENShare.h
//  EatNow
//
//  Created by GaoYongqing on 10/13/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENShare : NSObject

+ (void)shareText:(NSString *)text image:(UIImage *)img andLink:(NSURL *)link withdeepLink:(NSURL*)deepLink inViewController:(UIViewController *)vc;

@end
