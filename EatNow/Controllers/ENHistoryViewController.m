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
#import "NSDate+Extension.h"

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
        //restaurant
        //like
        //_id
        //date
        NSString *dateStr = json[@"date"];
        NSDate *date = [NSDate dateFromISO1861:dateStr];
        NSMutableArray *restaurantsDataForThatDay = self.history[date] ?: [NSMutableArray new];
        ENRestaurant *restaurant = [ENRestaurant restaurantWithData:json[@"restaurant"]];
        if (!restaurant) continue;
        [restaurantsDataForThatDay addObject:@{@"restaurant": restaurant, @"like": json[@"like"], @"_id": json[@"_id"]}];
        self.history[date] = restaurantsDataForThatDay;
    }
    self.orderedDates = [self.history.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        return -[obj1 compare:obj2];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.history.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSDate *date = self.orderedDates[section];
    NSArray *restaurants = self.history[date];
    return restaurants.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ENHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    NSDate *date = self.orderedDates[indexPath.section];
    NSArray *restaurantsData = self.history[date];
    NSDictionary *dataPoint = restaurantsData[indexPath.row];
    ENRestaurant *restaurant = dataPoint[@"restaurant"];
    cell.restaurant = restaurant;
    return cell;
}

@end
