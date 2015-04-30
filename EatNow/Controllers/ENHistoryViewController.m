//
//  ENHistoryViewController.m
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryViewController.h"
#import "ENServerManager.h"
#import "ENHistoryViewCell.h"
#import "NSDate+MTDates.h"
#import "NSDate+Extension.h"
#import "UIView+Extend.h"
#import "ENRestaurantViewController.h"
#import "ENMainViewController.h"
#import "TMTableViewBuilder.h"
#import "extobjc.h"
#import "ENHistoryHeaderRowItem.h"
#import "ENHistoryRowItem.h"

NSString * const kHistoryDetailCardDidShow = @"history_detail_view_did_show";
NSString * const kHistoryTableViewDidShow = @"history_table_view_did_show";

@interface ENHistoryViewController ()
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *history;
@property (nonatomic, strong) NSArray *orderedDates;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@property (nonatomic, strong) TMTableViewBuilder *builder;
@end

@implementation ENHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if (self.navigationController) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
	}
    
    self.builder = [[TMTableViewBuilder alloc] initWithTableView:self.tableView];
    @weakify(self);
    self.builder.reloadBlock = ^(TMTableViewBuilder *builder) {
        @strongify(self);
        self.history = [ENServerManager shared].history;
        [builder removeAllSectionItems];
        TMSectionItem *sectionItem = [TMSectionItem new];
        [builder addSectionItem:sectionItem];
        for (NSDate *date  in self.orderedDates) {
            ENHistoryHeaderRowItem *rowItem = [ENHistoryHeaderRowItem new];
            rowItem.date = date;
            [sectionItem addRowItem:rowItem];
            
            NSArray *restaurants = self.history[date.mt_endOfCurrentDay];
            for (NSDictionary *dict in restaurants) {
                ENRestaurant *restaurant = dict[@"restaurant"];
                NSNumber *like = dict[@"like"];
                ENHistoryRowItem *hRow = [ENHistoryRowItem new];
                hRow.restaurant = restaurant;
                hRow.rate = like;
                [sectionItem addRowItem:hRow];
                [hRow setDidSelectRowHandler:^(ENHistoryRowItem *rowItem) {
                    self.selectedPath = rowItem.indexPath;
                    ENHistoryViewCell *cell = (ENHistoryViewCell *)rowItem.cell;
                    CGRect frame = [self.mainView convertRect:cell.background.frame fromView:cell.contentView];
                    [self showRestaurantCard:restaurant fromFrame:frame];
                }];
            }
        }
        [self.tableView reloadData];
    };
    
    [self.builder configure];
}

- (void)loadData{
    //data
    self.history = [ENServerManager shared].history;
    [self.builder reloadData];
    
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        self.history = [ENServerManager shared].history;
        [self.builder reloadData];
    }];
}

- (void)setHistory:(NSMutableDictionary *)history{
    _history = history;
    self.orderedDates = [_history.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        switch ([obj1 compare:obj2]) {
            case NSOrderedAscending:
                return NSOrderedDescending;
            case NSOrderedDescending:
                return NSOrderedAscending;
            case NSOrderedSame:
                return NSOrderedSame;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView applyAlphaGradientWithEndPoints:@[@.05, @.95]];
}

#pragma mark - Actions
- (IBAction)close:(id)sender{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onInfoTapGesture:(UITapGestureRecognizer *)sender {
    [self.restaurantViewController.info removeGestureRecognizer:sender];
    [self closeRestaurantView];
}

- (void)showRestaurantCard:(ENRestaurant *)restaurant fromFrame:(CGRect)frame {
    self.restaurantViewController = [ENRestaurantViewController viewController];
    //[_restaurantViewController switchToStatus:ENRestaurantViewStatusMinimum withFrame:frame animated:NO completion:nil];
    _restaurantViewController.view.frame = frame;
    _restaurantViewController.restaurant = restaurant;
    [self.mainView addSubview:_restaurantViewController.view];
    CGRect toFrame = [self.mainView convertRect:self.view.frame fromView:self.view];
    [_restaurantViewController switchToStatus:ENRestaurantViewStatusHistoryDetail withFrame:toFrame animated:YES completion:nil];
    ENMainViewController *mainVC = (ENMainViewController *)self.parentViewController;
    mainVC.isHistoryDetailShown = YES;
    self.mainViewController.currentMode = ENMainViewControllerModeHistoryDetail;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInfoTapGesture:)];
    [self.restaurantViewController.info addGestureRecognizer:tap];
}

- (void)closeRestaurantView{
    self.mainViewController.currentMode = ENMainViewControllerModeHistory;
    if (self.restaurantViewController){
        ENHistoryViewCell *cell = (ENHistoryViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedPath];
        CGRect frame = [cell.contentView convertRect:cell.background.frame toView:self.mainView];
        [self.restaurantViewController switchToStatus:ENRestaurantViewStatusMinimum withFrame:frame animated:YES completion:^{
            [self.restaurantViewController.view removeFromSuperview];
            self.restaurantViewController = nil;
        }];
        
        ENMainViewController *mainVC = (ENMainViewController *)self.parentViewController;
        mainVC.isHistoryDetailShown = NO;
    }
}
@end
