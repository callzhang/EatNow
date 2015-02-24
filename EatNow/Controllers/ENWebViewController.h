//
//  ENWebViewController.h
//  EatNow
//
//  Created by Lei Zhang on 1/23/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENWebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;
@end
