//
//  ENShare.m
//  EatNow
//
//  Created by GaoYongqing on 10/13/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENShare.h"
#import <WeixinActivity.h>

@implementation ENShare

+ (void)shareText:(NSString *)text withTitle:(NSString *)title image:(UIImage *)img andLink:(NSURL *)link inViewController:(UIViewController *)vc
{
    NSMutableArray *shareItems = [[NSMutableArray alloc] initWithArray:@[img,link]];
    if (title) {
        NSString *description = [NSString stringWithFormat:@"DESC:%@",text];
        [shareItems addObject:description];
        [shareItems addObject:title];
    }else{
        [shareItems addObject:text];
    }
    
    NSArray *activities = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
    // UIActivityViewController would convert the image to jpeg format, therefore it would loose transparent background.
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[text, img, link] applicationActivities:activities];
    
    shareVC.excludedActivityTypes = @[UIActivityTypePrint,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypeAssignToContact];
    
    [vc presentViewController:shareVC animated:YES completion:nil];
}

+ (void)shareText:(NSString *)text image:(UIImage *)img andLink:(NSURL *)link inViewController:(UIViewController *)vc
{
    [ENShare shareText:text withTitle:nil image:img andLink:link inViewController:vc];
}

@end
