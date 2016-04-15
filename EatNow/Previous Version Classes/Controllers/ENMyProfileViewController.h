//
//  ENMyProfileViewController.h
//  EatNow
//
//  Created by GaoYongqing on 9/5/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENContainerViewControllerProtocol.h"

@interface ENMyProfileViewController : UIViewController <ENContainerViewControllerProtocol>

@property (nonatomic, weak) IBOutlet UIView *cardContainer;
@property (nonatomic, weak) IBOutlet UIView *cardView;
@property (nonatomic, assign) ENMainViewControllerMode currentMode;

@property (nonatomic, assign) BOOL showScore;
@property (nonatomic, assign) BOOL isHistoryDetailShown;

@end
