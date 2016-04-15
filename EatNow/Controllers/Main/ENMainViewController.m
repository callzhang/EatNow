//
//  ENMainViewController.m
//  EatNow
//
//  Created by Veracruz on 16/4/15.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENMainViewController.h"
#import "ENMainCollectionViewModel.h"

@interface ENMainViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) ENMainCollectionViewModel *collectionViewModel;

@end

@implementation ENMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _collectionViewModel = [[ENMainCollectionViewModel alloc] init];
    _collectionViewModel.hostController = self;
    _collectionViewModel.collectionView = _collectionView;
    
}

@end
