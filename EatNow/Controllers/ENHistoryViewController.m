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
	} else {
		UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 30)];
		[closeBtn setTitle:@"Close" forState:UIControlStateNormal];
		[closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:closeBtn];
	}
	
	//data
    self.history = [NSMutableDictionary new];
	self.user = [ENServerManager shared].me;
	[[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
		self.user = user;
		[self.tableView reloadData];
	}];
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

- (void)setUser:(NSDictionary *)user{
	[self setHistoryWithData: [user valueForKeyPath:@"user.history"]];
	_user = user;
}

- (void)setHistoryWithData:(NSArray *)data{
	//generate restaurant
    for (NSDictionary *json in data) {
        //json: {restaurant, like, _id, date}
        NSString *dateStr = json[@"date"];
        NSDate *date = [NSDate dateFromISO1861:dateStr];
        NSMutableArray *restaurantsDataForThatDay = self.history[[date mt_endOfCurrentDay]];
        if (!restaurantsDataForThatDay) {
            restaurantsDataForThatDay = [NSMutableArray array];
        }
        NSDictionary *data = json[@"restaurant"];
        ENRestaurant *restaurant = [ENRestaurant restaurantWithData:data];
        if (!restaurant) continue;
        [restaurantsDataForThatDay addObject:@{@"restaurant": restaurant, @"like": json[@"like"], @"_id": json[@"_id"]}];
        self.history[[date mt_endOfCurrentDay]] = restaurantsDataForThatDay;
    }
    self.orderedDates = [_history.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        return -[obj1 compare:obj2];
    }];
    DDLogVerbose(@"Updated history: %@", _history);
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
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


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    NSDate *date = self.orderedDates[section];
//    return date.string;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDate *date = self.orderedDates[section];
    NSArray *restaurants = self.history[date.mt_endOfCurrentDay];
    return restaurants.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ENHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    NSDate *date = self.orderedDates[indexPath.section];
    NSArray *restaurantsData = self.history[date.mt_endOfCurrentDay];
    NSDictionary *dataPoint = restaurantsData[indexPath.row];
    ENRestaurant *restaurant = dataPoint[@"restaurant"];
    cell.restaurant = restaurant;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

@end
