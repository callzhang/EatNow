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

NSString * const kHistoryDetailCardDidShow = @"history_detail_view_did_show";
NSString * const kHistoryTableViewDidShow = @"history_table_view_did_show";

@interface ENHistoryViewController ()
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *history;
@property (nonatomic, strong) NSArray *orderedDates;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@end

@implementation ENHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if (self.navigationController) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
	}
}

- (void)loadData{
    //data
    self.history = [ENServerManager shared].history;
    
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        self.history = [ENServerManager shared].history;
        [self.tableView reloadData];
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

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.orderedDates.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewCell *secionHeader = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];
    UILabel *title = (UILabel *)[secionHeader viewWithTag:89];
    NSDate *date = self.orderedDates[section];
    title.text = date.string;
    return secionHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDate *date = self.orderedDates[section];
    NSArray *restaurants = self.history[date.mt_endOfCurrentDay];
    return restaurants.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ENHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    NSDate *date = self.orderedDates[indexPath.section];
    NSArray *restaurantsData = self.history[date.mt_endOfCurrentDay];
    NSDictionary *dataPoint = restaurantsData[indexPath.row];
    ENRestaurant *restaurant = dataPoint[@"restaurant"];
    cell.restaurant = restaurant;
    cell.rate = [(NSNumber *)dataPoint[@"like"] integerValue];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.restaurantViewController) {
        return;
    }
    self.selectedPath = indexPath;
    ENHistoryViewCell *cell = (ENHistoryViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDate *date = self.orderedDates[indexPath.section];
    NSArray *restaurantsData = self.history[date.mt_endOfCurrentDay];
    NSDictionary *dataPoint = restaurantsData[indexPath.row];
    ENRestaurant *restaurant = dataPoint[@"restaurant"];
    CGRect frame = [self.mainView convertRect:cell.background.frame fromView:cell.contentView];
    [self showRestaurantCard:restaurant fromFrame:frame];
}

@end
