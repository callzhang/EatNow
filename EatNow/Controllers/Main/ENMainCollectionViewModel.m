//
//  ENMainCollectionViewModel.m
//  EatNow
//
//  Created by Veracruz on 16/4/15.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENMainCollectionViewModel.h"


#define ITEM_WIDTH ([UIScreen mainScreen].bounds.size.width - 50)
#define ITEM_HEIGHT ([UIScreen mainScreen].bounds.size.height * 0.725)
#define LINE_SPACING 15.0
#define SECTION_INSET 25.0

@interface PageFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *attributes;

@end


@implementation ENMainCollectionViewModel 

- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    PageFlowLayout *flowLayout = [[PageFlowLayout alloc] init];
    _collectionView.collectionViewLayout = flowLayout;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"ENMainCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    
    
    return cell;
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    float pageWidth = ITEM_WIDTH + LINE_SPACING;
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset)
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
    else
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
    
    if (newTargetOffset < 0)
        newTargetOffset = 0;
    else if (newTargetOffset > scrollView.contentSize.width)
        newTargetOffset = scrollView.contentSize.width;
    
    targetContentOffset->x = currentOffset;
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
}

@end



@implementation PageFlowLayout

- (instancetype)init {
    
    if (self = [super init]) {
        self.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = LINE_SPACING;
        self.sectionInset = UIEdgeInsetsMake(0, SECTION_INSET, 0, SECTION_INSET);
    }
    return self;
    
}

@end