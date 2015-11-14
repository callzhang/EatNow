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
#import "NSDate+Extension.h"
#import "ENServerManager.h"
#import "BlocksKit+UIKit.h"
#import "ATConnect.h"

@interface ENProfileMoreViewController () <UITableViewDataSource,UITabBarControllerDelegate,
UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ENProfileMoreViewController

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
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ENPreferenceMoreTableViewCell";
    ENPreferenceMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.item = self.items[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ENPreferenceMoreTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.item.actionBlock) {
        cell.item.actionBlock(cell);
    }

}

#pragma mark - Setup

- (void)setup
{
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.items = [[NSMutableArray alloc] initWithCapacity:6];
    
    NSDictionary *user = [ENServerManager shared].me;
    
    // Link item
    @weakify(self);
    ENProfileItem *linkItem = [[ENProfileItem alloc] initWithTitle:@"Linked Account" value:@"Link"];
    linkItem.actionBlock = ^(ENPreferenceMoreTableViewCell *cell){
        
        @strongify(self);
        [[ENSocialLoginManager sharedInstance] presentLoginActionSheetInViewController:self withCompletionHandler:^(ENSocialLoginResponse *resp, NSError *error) {
            
            if (error) {
                DDLogError(@"Social login error = %@",error);
                return;
            }
            
            cell.item.value = resp.providerName;
            cell.valueLabel.text = resp.providerName;
            
            DDLogDebug(@"Social login success");
            [[ENServerManager shared] insertOrUpdateUserVendorWithResponse:resp completion:nil];
            
        }];

    };
    [self.items addObject:linkItem];
    
    NSString *email = user[@"emai"]?:@"Enter";
    // Email item
    ENProfileItem *emailItem = [[ENProfileItem alloc] initWithTitle:@"Email" value:email];
    emailItem.actionBlock = ^(ENPreferenceMoreTableViewCell *cell){
        
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Email" message:nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
        [alertView bk_addButtonWithTitle:@"Ok" handler:^{
            UITextField *textField = [alertView textFieldAtIndex:0];
            if (textField.text) {
                cell.item.value = textField.text;
                cell.valueLabel.text = cell.item.value;
            }
        }];
        [alertView show];
        
    };
    [self.items addObject:emailItem];
    
    //Feedback
    ENProfileItem *feedbackItem = [[ENProfileItem alloc] initWithTitle:@"Feedback" value:@""];
    feedbackItem.actionBlock = ^(ENPreferenceMoreTableViewCell *cell){
        [[ATConnect sharedConnection] presentMessageCenterFromViewController:self];
    };
    [self.items addObject:feedbackItem];
    
    ENProfileItem *surveyItem = [[ENProfileItem alloc] initWithTitle:@"Survey" value:@""];
    surveyItem.actionBlock = ^(ENPreferenceMoreTableViewCell *cell){
        [[ATConnect sharedConnection] engage:@"completed_in_app_purchase" fromViewController:self];
    };
    [self.items addObject:surveyItem];
    
    ENProfileItem *rateItem = [[ENProfileItem alloc] initWithTitle:@"Rate Eat Now" value:@""];
    rateItem.actionBlock = ^(ENPreferenceMoreTableViewCell *cell){
        [[ATConnect sharedConnection] openAppStore];
    };
    [self.items addObject:rateItem];
    
    ENProfileItem *logoutItem = [[ENProfileItem alloc] initWithTitle:@"Logout" value:@""];
    logoutItem.actionBlock = ^(ENPreferenceMoreTableViewCell *cell){
        //TODO: Add logout
    };
    [self.items addObject:logoutItem];
    
}

@end
