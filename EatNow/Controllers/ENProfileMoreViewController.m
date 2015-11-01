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
            
            if (error) {
                DDLogError(@"Social login error = %@",error);
                return;
            }
            
            DDLogDebug(@"Social login success");
            [self updateMeWithResponse:resp];
            
        }];
        
    }
}

#pragma mark - Setup

- (void)setup
{
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    _items = [[NSMutableArray alloc] initWithCapacity:6];
    
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Linked Account" value:@"Link"]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Email" value:@"Enter"]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Feedback" value:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Survey" value:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Rate Eat Now" value:@""]];
    [_items addObject:[[ENProfileItem alloc] initWithTitle:@"Logout" value:@""]];
}

#pragma mark - Private

- (void)updateMeWithResponse:(ENSocialLoginResponse *)resp
{
    
    if (![ENServerManager shared].me) {
        DDLogError(@"No local user info in social login");
    }
    
    NSMutableDictionary *user = [[NSMutableDictionary alloc] initWithDictionary:[ENServerManager shared].me];
    // Update token
    NSDictionary *vendor = @{
                             @"provider": resp.providerName,
                             @"token": resp.token.token,
                             @"expiration" : [resp.token.expirationDate ISO8601],
                             @"refresh_token" : resp.token.refreshToken?:@"",
                             @"open_id" : resp.user.userId
                             };
    
    NSArray *vendorList = [user objectForKey:@"vendors"];
    if (!vendorList) {
        [user setObject:@[vendor] forKey:@"vendors"];
    }
    else{
        
        NSMutableArray *mutableVendorList = [[NSMutableArray alloc] initWithArray:vendorList];
        
        NSInteger idx = -1;
        for (NSInteger i = 0; i < mutableVendorList.count; i++) {
            NSDictionary *v = mutableVendorList[i];
            if ([v[@"provider"] isEqualToString:vendor[@"provider"]]) {
                idx = i;
                break;
            }
        }
        
        if (idx >= 0) {
            mutableVendorList[idx] = vendor;
        }
        else{
            [mutableVendorList addObject:vendor];
        }
        
        vendorList = mutableVendorList;
    }
    [user setObject:vendorList forKey:@"vendors"];
    
    //Update user info
    [user setObject:resp.user.name forKey:@"username"];
    [user setObject:resp.user.avatarUrl forKey:@"profile_url"];
    [user setObject:resp.user.location?:@"" forKey:@"address"];
    if (resp.user.age) {
        NSInteger age = [resp.user.age integerValue];
        [user setObject:@(age) forKey:@"age"];
    }
    
    [ENServerManager shared].me = user;
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserUpdated object:nil];
   
}

@end
