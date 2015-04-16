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

@interface ENHistoryViewController ()
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSArray *history;
@property (nonatomic, strong) NSArray *restaurants;
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
	self.history = [user valueForKeyPath:@"user.history"];
	_user = user;
}

- (void)setHistory:(NSArray *)history{
	_history = history;
	//generate restaurant
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.history.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.history.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ENHistoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    
    return cell;
}

@end
