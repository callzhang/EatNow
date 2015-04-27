//
//  ENProfileViewController.m
//  EatNow
//
//  Created by Lee on 2/14/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENProfileViewController.h"
#import "ENUtil.h"
#import "ENServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Extension.h"
#import "extobjc.h"

@interface ENProfileViewController ()
@property (nonatomic, strong) ENServerManager *serverManager;
@end

@implementation ENProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    self.serverManager = [ENServerManager shared];
    
    if (![ENServerManager shared].me) {
        [ENUtil showWatingHUB];
        [self.serverManager getUserWithCompletion:^(NSDictionary *user, NSError *error) {
            [ENUtil dismissHUD];
            @strongify(self);
            if (user) {
				[self loadData];
            }
        }];
    }
	else {
		[self loadData];
    }
	
	[[NSNotificationCenter defaultCenter] addObserverForName:kHistroyUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
		DDLogVerbose(@"Profile view observed history update and updated it's view");
		[self loadData];
	}];
}

- (void)loadData{
	self.user = self.serverManager.me;
	self.preference = self.serverManager.preference;
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.presentingViewController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(close:)];
    }
}

- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
        case 1:
            return self.preference.count;
        default:
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Profile";
            break;
        case 1:
            return @"Preference";
            break;
        default:
            break;
    }
    return @"??";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 22;
    }
    return tableView.rowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"subtitle"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subtitle"];
        }
        //username
        switch (indexPath.row) {
            case 0:{
                cell.textLabel.text = @"Username";
                cell.detailTextLabel.text = self.user[@"username"];
                break;
            }
            case 1:{
                cell.textLabel.text = @"Average Price";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.user[@"avgUserPrice"]];
                break;
            }
            case 2:{
                cell.textLabel.text = @"Average Rating";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.user[@"avgUserRating"]];
                break;
            }
            default:
                break;
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"preference"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"preference"];
        }
        //preference
		NSString *name = self.preference.allKeys[indexPath.row];
        NSNumber *score = self.preference[name];
        cell.textLabel.text = name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f%%", score.floatValue*100];
    }
    
    return cell;
}

@end
