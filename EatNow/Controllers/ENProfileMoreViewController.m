//
//  ENProfileMoreViewController.m
//  EatNow
//
//  Created by GaoYongqing on 10/6/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENProfileMoreViewController.h"
#import "ENPreferenceMoreTableViewCell.h"

@interface ENProfileMoreViewController () <UITableViewDataSource,UITabBarControllerDelegate>

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

#pragma mark - Setup

- (void)setup
{
    _items = [[NSMutableArray alloc] initWithCapacity:6];
    
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Linked Account" andValue:@"Facebook"]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Email" andValue:@"leizhang@gmail.com"]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Feedback" andValue:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Survey" andValue:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Rate Eat Now" andValue:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Logout" andValue:@""]];
}

@end
