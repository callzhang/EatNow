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

@interface ENHistoryViewController ()
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *history;
@property (nonatomic, strong) NSArray *orderedDates;
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
	
    self.tableView.contentInset = UIEdgeInsetsMake(90, 0, 0, 0);
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
    [self.tableView applyAlphaGradientWithEndPoints:@[@.1, @.95]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender{
	if (self.presentingViewController) {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

@end
