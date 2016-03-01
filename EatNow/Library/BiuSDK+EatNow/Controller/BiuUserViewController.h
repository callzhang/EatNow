//
//  BiuUserViewController.h
//  EatNow
//
//  Created by Zitao Xiong on 3/1/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BiuUser.h"

@interface BiuUserViewController : UIViewController
@property (nonatomic, strong) BiuUser *user;
- (void)dismiss;
@end
