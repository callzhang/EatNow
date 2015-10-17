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

+ (instancetype)sharedInstance
{
    static ENShare *instance;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [ENShare new];
    });
    
    return instance;
}

- (void)shareText:(NSString *)text image:(UIImage *)img andLink:(NSURL *)link inViewController:(UIViewController *)vc
{
    NSArray *activities = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
    // UIActivityViewController would convert the image to jpeg format, therefore it would loose transparent background.
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[text, img, link] applicationActivities:activities];
    
    shareVC.excludedActivityTypes = @[UIActivityTypePrint,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypeAssignToContact];
    
    [vc presentViewController:shareVC animated:YES completion:nil];

}

@end
