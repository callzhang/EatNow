//
//  TMCollectionViewDelegate.m
//  Pods
//
//  Created by Zitao Xiong on 5/5/15.
//
//

#import "TMCollectionViewDelegate.h"
#import "TMCollectionViewBuilder.h"
#import "TMCollectionItem.h"

@implementation TMCollectionViewDelegate
- (instancetype)init {
    self = [self initWithCollectionViewBuilder:nil];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCollectionViewBuilder:(TMCollectionViewBuilder *)builder {
    self = [super init];
    if (self) {
        self.collectionViewBuilder = builder;
    }
    return self;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    return [item shouldHighlightItem];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
   [item didHighlightItem];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item didUnhighlightItem];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    return [item shouldSelectItem];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    return [item shouldDeselectItem];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item didSelectItem];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item didDeselectItem];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item willDisplayCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item willDisplaySupplementaryView:view forElementKind:elementKind];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item didEndDisplayingCell:cell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item didEndDisplayingSupplementaryView:view forElementOfKind:elementKind];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    return [item shouldShowMenu];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    return [item canPerformAction:action withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    TMCollectionItem *item = [self.collectionViewBuilder itemAtIndexPath:indexPath];
    [item performAction:action withSender:sender];
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout {
    UICollectionViewTransitionLayout *transitionLayout = [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.forwardDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [self.forwardDelegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        return flowLayout.itemSize;
    }
    
    //TODO:
    return CGSizeZero;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    
//}
@end
