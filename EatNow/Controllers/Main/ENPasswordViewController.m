//
//  ENPasswordViewController.m
//  EatNow
//
//  Created by Veracruz on 16/4/30.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENPasswordViewController.h"

@interface ENPasswordViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray <NSArray *> *cellInformations;

@end

@implementation ENPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _cellInformations = @[@[@"Current Password"], @[@"New Password", @"Repeat New Password"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellInformations.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellInformations[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UITextField *textField = [cell.contentView viewWithTag:1000];
    
    textField.placeholder = _cellInformations[indexPath.section][indexPath.row];
    
    return cell;
}

- (IBAction)cancelButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
