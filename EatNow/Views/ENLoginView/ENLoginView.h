//
//  ENLoginView.h
//  EatNow
//
//  Created by Veracruz on 16/4/23.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ENLoginView : UIView

@property (nonatomic) BOOL basicType;

+ (instancetype)loginView;
+ (instancetype)basicLoginView;

- (void)show;
- (void)hide;

@end
