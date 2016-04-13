//
//  TMSecondaryViewControllerOption.h
//  Pods
//
//  Created by Zitao Xiong on 5/28/15.
//
//

#import <Foundation/Foundation.h>
#import "TMTableViewBuilderTableViewController.h"

typedef NS_ENUM(NSUInteger, TMViewControllerPresentationOptionPresentationStyle) {
    TMViewControllerPresentationOptionStyleNone, // -> not show
    TMViewControllerPresentationOptionnStyleShow, // -> showViewController
    //    TMSecondaryViewControllerPresentationStyleShowDetail, // -> showDetailViewController
    TMViewControllerPresentationOptionStylePresent, // -> presentViewController
    TMViewControllerPresentationOptionStylePush, // -> .navigationController:push:
};

@interface TMViewControllerPresentationOption : NSObject <NSCopying>
@property (nonatomic, assign) TMViewControllerPresentationOptionPresentationStyle presentationStyle;
/**
 *  called after view did load
 */
@property (nonatomic, copy) void (^viewDidLoadCompletionHandler) (id rowItem, UIViewController<TMTableViewBuilderViewController> *tableViewController);
/**
 *  called before view will disappear
 */
@property (nonatomic, copy) void (^viewWillDisappearCompletionHandler) (id rowItem, UIViewController<TMTableViewBuilderViewController> *tableViewController, BOOL animated);
@end
