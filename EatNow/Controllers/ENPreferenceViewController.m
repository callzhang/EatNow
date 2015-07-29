//
//  ENPreferenceViewController.m
//  EatNow
//
//  Created by Lee on 7/25/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENPreferenceViewController.h"
#import "ENServerManager.h"
#import "ENPreferenceCollectionViewCell.h"

@interface ENPreferenceViewController ()

@end

@implementation ENPreferenceViewController

static NSString * const reuseIdentifier = @"preferenceCollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(close:)];
    self.collectionView.tintColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.allowsMultipleSelection = YES;
    
    //add selection
    NSDictionary *base = [ENServerManager shared].basePreference;
    [base enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *score, BOOL *stop) {
        if (score.floatValue == 0) return;
        NSUInteger idx = [kBasePreferences indexOfObject:key];
        if (idx != NSIntegerMax) {
            DDLogVerbose(@"Pre-select %@(%lu)", key, (unsigned long)idx);
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kBasePreferences.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ENPreferenceCollectionViewCell *cell = (ENPreferenceCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSString *cuisine = kBasePreferences[indexPath.row];
    UIImageView *cuisineImage = (UIImageView *)cell.backgroundView;
    cuisineImage.image = [UIImage imageNamed:cuisine];
    cell.cuisineName.text = cuisine;
    UIView *hl = [[UIView alloc] initWithFrame:cell.contentView.frame];
    hl.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    cell.selectedBackgroundView = hl;
    cell.contentView.layer.borderWidth = 1;
    cell.contentView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float cellWidth = (self.view.frame.size.width / 2) - 60;
    float cellHeight = cellWidth;
    return CGSizeMake(cellWidth, cellHeight);
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
