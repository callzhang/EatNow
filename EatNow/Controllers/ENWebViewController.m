//
//  ENWebViewController.m
//  EatNow
//
//  Created by Lei Zhang on 1/23/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENWebViewController.h"

@interface ENWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ENWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
