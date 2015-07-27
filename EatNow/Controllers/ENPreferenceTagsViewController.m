//
//  ENPreferenceTagsViewController.m
//  EatNow
//
//  Created by Lee on 7/19/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENPreferenceTagsViewController.h"
#import "JCTagListView.h"
#import "ENServerManager.h"

@interface ENPreferenceTagsViewController ()
@property (weak, nonatomic) IBOutlet JCTagListView *tagView;

@end

@implementation ENPreferenceTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(close:)];
    self.tagView.canSeletedTags = YES;
    [self.tagView.tags addObjectsFromArray:kBasePreferences];
    self.tagView.collectionView.backgroundColor = [UIColor clearColor];
    [self.tagView setCompletionBlockWithSeleted:^(NSInteger index) {
        DDLogDebug(@"%ld", (long)index);
    }];
    
    //add selection
    NSDictionary *base = [ENServerManager shared].basePreference;
    [base enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *score, BOOL *stop) {
        if (score.floatValue == 0) return;
        NSUInteger idx = [kBasePreferences indexOfObject:key];
        if (idx != NSIntegerMax) {
            DDLogVerbose(@"Pre-select %@(%lu)", key, (unsigned long)idx);
            [self.tagView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    DDLogVerbose(@"Selected: %@", self.tagView.seletedTags);
    NSMutableDictionary *pref = [NSMutableDictionary dictionary];
    for (NSString *cuisine in self.tagView.seletedTags) {
        pref[cuisine] = @1;
    }
    [[ENServerManager shared] updateBasePreference:pref completion:^(NSError *error) {
        //DDLogVerbose(@"Base preference updated: %@", pref);
        if (error) {
            [self.view showFailureNotification:@"Failed to update base preference"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
- (IBAction)close:(id)sender{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
