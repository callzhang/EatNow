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


@interface ENMainCollectionViewModel () <UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) UIView *deleteView;
@property (nonatomic) BOOL operationLock;
@property (nonatomic, strong) NSIndexPath *currentOperationIndexPath;

@end

@implementation ENMainCollectionViewModel 

- (void)setCollectionView:(UICollectionView *)collectionView {
    _operationLock = NO;
    
    _collectionView = collectionView;
    PageFlowLayout *flowLayout = [[PageFlowLayout alloc] init];
    _collectionView.collectionViewLayout = flowLayout;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"ENMainCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cell"];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    [_collectionView addGestureRecognizer:pan];
    
    _restaurants = [@[@"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder",
                      @"placeholder"] mutableCopy];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _restaurants.count;
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

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if (_operationLock) {
        return NO;
    }
    if ([gestureRecognizer translationInView:_collectionView].y < 0) {
        return YES;
    }
    return NO;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender {
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:[sender locationInView:_collectionView]];
    CGPoint translation = [sender translationInView:_collectionView];
    UICollectionViewCell *cell;
    
    if (_currentOperationIndexPath) {
        cell = [_collectionView cellForItemAtIndexPath:_currentOperationIndexPath];
    }
    
    if (!indexPath) {
        if (cell) {
            [UIView animateWithDuration:0.3 delay:0 options:7 << 16 animations:^{
                cell.transform = CGAffineTransformIdentity;
            } completion:nil];
            [self dismissDeleteTopView];
            _currentOperationIndexPath = nil;
        }
        
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _currentOperationIndexPath = indexPath;
        [self drawDeleteTopView];
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        if (translation.y < -50 && _currentOperationIndexPath) {
            [_restaurants removeObjectAtIndex:_currentOperationIndexPath.row];
            [_collectionView performBatchUpdates:^{
                [_collectionView deleteItemsAtIndexPaths:@[_currentOperationIndexPath]];
            } completion:nil];
        } else {
            [UIView animateWithDuration:0.3 delay:0 options:7 << 16 animations:^{
                cell.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
        [self dismissDeleteTopView];
        _currentOperationIndexPath = nil;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        cell.transform = CGAffineTransformMakeTranslation(0, translation.y < 0 ? translation.y : 0);
    }
    
}

- (void)drawDeleteTopView {
    if (!_deleteView) {
        _deleteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80)];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-top-trash-background"]];
        UIImageView *trashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-top-trash"]];
        
        backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        backgroundImageView.frame = _deleteView.bounds;
        
        [_deleteView addSubview:backgroundImageView];
        
        [trashImageView sizeToFit];
        trashImageView.center = _deleteView.centerPoint;
        
        [_deleteView addSubview:trashImageView];
        
        _deleteView.transform = CGAffineTransformMakeTranslation(0, -_deleteView.height);
    }
    
    _operationLock = YES;
    
    [_hostController.view insertSubview:_deleteView belowSubview:_collectionView];
    
    [UIView animateWithDuration:0.3 delay:0 options:7 << 16 animations:^{
        _deleteView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismissDeleteTopView {
    
    [UIView animateWithDuration:0.3 delay:0 options:7 << 16 animations:^{
        _deleteView.transform = CGAffineTransformMakeTranslation(0, -_deleteView.height);
    } completion:^(BOOL finished) {
        [_deleteView removeFromSuperview];
        _operationLock = NO;
    }];

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

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    UICollectionViewLayoutAttributes *attributes = [[super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath] copy];
    if (attributes.alpha <= 0) {
        attributes.transform = CGAffineTransformMakeTranslation(0, -ITEM_HEIGHT);
    }
    return attributes;
}

@end