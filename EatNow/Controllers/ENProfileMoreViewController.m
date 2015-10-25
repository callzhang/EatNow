//
//  ENProfileMoreViewController.m
//  EatNow
//
//  Created by GaoYongqing on 10/6/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENProfileMoreViewController.h"
#import "ENPreferenceMoreTableViewCell.h"
#import "ENSocialLoginManager.h"

@interface ENProfileMoreViewController () <UITableViewDataSource,UITabBarControllerDelegate,
UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation ENProfileMoreViewController
{
    NSMutableArray *_items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ENPreferenceMoreTableViewCell";
    ENPreferenceMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.item = _items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        [[ENSocialLoginManager sharedInstance] presentLoginActionSheetInViewController:self withCompletionHandler:^(ENSocialLoginResponse *resp, NSError *error) {
            
            
            
        }];
        
    }
}

#pragma mark - Setup

- (void)setup
{
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _items = [[NSMutableArray alloc] initWithCapacity:6];
    
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Linked Account" andValue:@"Link"]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Email" andValue:@"Enter"]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Feedback" andValue:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Survey" andValue:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Rate Eat Now" andValue:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Logout" andValue:@""]];
}

#pragma mark - Private

@end
