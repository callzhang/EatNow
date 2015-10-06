//
//  ENContainerViewControllerProtocol.h
//  EatNow
//
//  Created by GaoYongqing on 10/6/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

typedef NS_ENUM(NSUInteger, ENMainViewControllerMode) {
    ENMainViewControllerModeStart,
    ENMainViewControllerModeMain,
    ENMainViewControllerModeDetail,
    ENMainViewControllerModeMap,
    ENMainViewControllerModeHistory,
    ENMainViewControllerModeHistoryDetail
};

@protocol ENContainerViewControllerProtocol <NSObject>

@property (nonatomic,weak) UIView *cardView;
@property (nonatomic,weak) UIView *detailView;

@property (nonatomic, assign) ENMainViewControllerMode currentMode;

@end

