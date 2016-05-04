//
//  ENRestaurantViewController.m
//  EatNow
//
//  Created by Veracruz on 16/5/4.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENRestaurantViewController.h"
#import "ENRestaurantMainCell.h"
#import "ENRestaurantBasicCell.h"
#import "ENRestaurantMenuCell.h"
#import "ENRestaurantScrollCell.h"

@interface ENRestaurantViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ENRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [_tableView registerNib:[UINib nibWithNibName:@"ENRestaurantMainCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"main"];
    [_tableView registerNib:[UINib nibWithNibName:@"ENRestaurantBasicCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"basic"];
    [_tableView registerNib:[UINib nibWithNibName:@"ENRestaurantMenuCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"menu"];
    [_tableView registerNib:[UINib nibWithNibName:@"ENRestaurantScrollCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"scroll"];
    _tableView.tableFooterView = [[UIView alloc] init];
    
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.layoutMargins = UIEdgeInsetsZero;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return [ENRestaurantMainCell cellHeight];
    }
    
    if (indexPath.row == 1 ||
        indexPath.row == 2 ||
        indexPath.row == 5 ||
        indexPath.row == 6) {
        return [ENRestaurantBasicCell cellHeight];
    }
    
    if (indexPath.row == 3) {
        return [ENRestaurantMenuCell cellHeight];
    }
    
    if (indexPath.row == 4) {
        return [ENRestaurantScrollCell cellHeight];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        ENRestaurantMainCell *mainCell = [tableView dequeueReusableCellWithIdentifier:@"main"];
        cell = mainCell;
    }
    
    if (indexPath.row == 1 ||
        indexPath.row == 2 ||
        indexPath.row == 5 ||
        indexPath.row == 6) {
        ENRestaurantBasicCell *basicCell = [tableView dequeueReusableCellWithIdentifier:@"basic"];
        cell = basicCell;
    }
    
    if (indexPath.row == 3) {
        ENRestaurantMenuCell *menuCell = [tableView dequeueReusableCellWithIdentifier:@"menu"];
        cell = menuCell;
    }
    
    if (indexPath.row == 4) {
        ENRestaurantScrollCell *scrollCell = [tableView dequeueReusableCellWithIdentifier:@"scroll"];
        cell = scrollCell;
    }
    
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    
    
    return cell;
}

- (IBAction)dismissButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
