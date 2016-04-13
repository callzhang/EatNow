//
//  TMSecondaryViewControllerOption.m
//  Pods
//
//  Created by Zitao Xiong on 5/28/15.
//
//

#import "TMViewControllerPresentationOption.h"

@implementation TMViewControllerPresentationOption
@synthesize viewDidLoadCompletionHandler = _viewDidLoadCompletionHandler;
@synthesize viewWillDisappearCompletionHandler = _viewWillDisappearCompletionHandler;
- (id)copyWithZone:(NSZone *)zone {
    TMViewControllerPresentationOption *theCopy = [[TMViewControllerPresentationOption alloc] init];
    theCopy.presentationStyle = self.presentationStyle;
    theCopy.viewDidLoadCompletionHandler = self.viewDidLoadCompletionHandler;
    theCopy.viewWillDisappearCompletionHandler = self.viewWillDisappearCompletionHandler;
    return theCopy;
}
@end
