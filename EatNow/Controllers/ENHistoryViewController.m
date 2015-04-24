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
#import "ENRestaurantView.h"
#import "ENMainViewController.h"

static const NSString *kHistoryDetailCardDidShow = @"history_detail_view_did_show";
static const NSString *kHistoryTableViewDidShow = @"history_table_view_did_show";

@interface ENHistoryViewController ()
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *history;
@property (nonatomic, strong) NSArray *orderedDates;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@end

@implementation ENHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // button in the navigation bar for this view controller.
	if (self.navigationController) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
	}
	
    //self.tableView.contentInset = UIEdgeInsetsMake(90, 0, 0, 0);
}

- (void)loadData{
    
    //data
    self.history = [ENServerManager shared].history;
    //self.user = [ENServerManager shared].me;
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        self.history = [ENServerManager shared].history;
        [self.tableView reloadData];
    }];
}

- (void)setHistory:(NSMutableDictionary *)history{
    _history = history;
    self.orderedDates = [_history.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        return -[obj1 compare:obj2];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    //appearance
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    //[self.tableView applyAlphaGradientWithEndPoints:@[@.05, @.95]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)close:(id)sender{
	if (self.presentingViewController) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)showRestaurantCard:(ENRestaurant *)restaurant fromFrame:(CGRect)frame {
    self.restaurantView = [ENRestaurantView loadView];
    _restaurantView.restaurant = restaurant;
    [_restaurantView switchToStatus:ENRestaurantViewStatusMinimum withFrame:frame animated:NO completion:nil];
    [self.view.superview addSubview:_restaurantView];
    [_restaurantView switchToStatus:ENRestaurantViewStatusHistoryDetail withFrame:self.view.frame animated:YES completion:nil];
    [_restaurantView.imageView applyGredient];
    ENMainViewController *mainVC = (ENMainViewController *)self.parentViewController;
    mainVC.isHistoryDetailShown = YES;
}

- (void)closeRestaurantView{
    if (self.restaurantView){
        ENHistoryViewCell *cell = (ENHistoryViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedPath];
        CGRect frame = [cell.contentView convertRect:cell.background.frame toView:self.view.superview];
        [self.restaurantView switchToStatus:ENRestaurantViewStatusMinimum withFrame:frame animated:YES completion:^{
            [self.restaurantView removeFromSuperview];
            self.restaurantView = nil;
        }];
        
        ENMainViewController *mainVC = (ENMainViewController *)self.parentViewController;
        mainVC.isHistoryDetailShown = NO;
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.history.allKeys.count;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.restaurantView) {
        return;
    }
    self.selectedPath = indexPath;
    ENHistoryViewCell *cell = (ENHistoryViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSDate *date = self.orderedDates[indexPath.section];
    NSArray *restaurantsData = self.history[date.mt_endOfCurrentDay];
    NSDictionary *dataPoint = restaurantsData[indexPath.row];
    ENRestaurant *restaurant = dataPoint[@"restaurant"];
    CGRect frame = [self.view.superview convertRect:cell.background.frame fromView:cell.contentView];
    [self showRestaurantCard:restaurant fromFrame:frame];
}
@end
