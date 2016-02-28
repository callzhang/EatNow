//
//  ENShare.h
//  EatNow
//
//  Created by GaoYongqing on 10/13/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENShare : NSObject

<<<<<<< HEAD
/**
 *  Share text to SNS. Usually we don't specify a title, the default title is [AppName] Share in Wechat. If we do want to specify a title, call this method.
 *
 *  @param text  The text detail to share.
 *  @param title The sharing title
 *  @param img   The share thumbnail
 *  @param link  The link
 *  @param vc    The parent view controller to show in.
 */
+ (void)shareText:(NSString *)text withTitle:(NSString *)title image:(UIImage *)img andLink:(NSURL *)link inViewController:(UIViewController *)vc;

+ (void)shareText:(NSString *)text image:(UIImage *)img andLink:(NSURL *)link inViewController:(UIViewController *)vc;
=======
+ (void)shareText:(NSString *)text image:(UIImage *)img andLink:(NSURL *)link withdeepLink:(NSURL*)deepLink inViewController:(UIViewController *)vc;
>>>>>>> master

@end
