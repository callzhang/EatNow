//
//  ENMainCollectionViewModel.h
//  EatNow
//
//  Created by Veracruz on 16/4/15.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ENMainCollectionViewModel : NSObject <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UIViewController *hostController;
@property (nonatomic, weak) UICollectionView *collectionView;

@end
