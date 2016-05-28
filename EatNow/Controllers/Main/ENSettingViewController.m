//
//  ENSettingViewController.m
//  EatNow
//
//  Created by Veracruz on 16/4/23.
//  Copyright © 2016年 modocache. All rights reserved.
//

#import "ENSettingViewController.h"

#define SettingItem(title, type, value, entry) [[SettingItem alloc] initWithArray:@[title, type, value, entry]]
#define SettingItemNullValue @""

NSString *const SettingItemTypeBasic = @"basic";
NSString *const SettingItemTypeIndicator = @"indicator";
NSString *const SettingItemTypeDetail = @"detail";
NSString *const SettingItemTypeSwitch = @"switch";

@interface SettingItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) id value; // NSString for detail, NSNumber(BOOL) for switch
@property (nonatomic, strong) NSString *entryIdentifier;

- (instancetype)initWithArray:(NSArray *)array;

@end

@interface ENSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray <NSArray <SettingItem *> *> *settingItems;

@end

@implementation ENSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _settingItems = @[
                    @[SettingItem(@"Edit Profile", SettingItemTypeIndicator, SettingItemNullValue, @"edit_profile"),
                      SettingItem(@"Linked Account", SettingItemTypeDetail, @"Facebook", @""),
                      SettingItem(@"Change Password", SettingItemTypeIndicator, SettingItemNullValue, @"edit_password")],
                    
                    @[SettingItem(@"Location", SettingItemTypeSwitch, @(YES), @""),
                      SettingItem(@"Notification", SettingItemTypeSwitch, @(NO), @"")],
                    
                    @[SettingItem(@"Feed Back", SettingItemTypeIndicator, SettingItemNullValue, @""),
                      SettingItem(@"Survey", SettingItemTypeIndicator, SettingItemNullValue, @""),
                      SettingItem(@"Rate Eat Now", SettingItemTypeIndicator, SettingItemNullValue, @"")],
                    
                    @[SettingItem(@"Log Out", SettingItemTypeBasic, SettingItemNullValue, @"")],
                    ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingItem *item = _settingItems[indexPath.section][indexPath.row];
    if (item.entryIdentifier) {
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:item.entryIdentifier] animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _settingItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _settingItems[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[@"ACCOUNT", @"SETTINGS", @"ABOUT", @""][section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingItem *item = _settingItems[indexPath.section][indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.type];
    
    if ([item.type isEqualToString:SettingItemTypeDetail]) {
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.value;
    }
    else if ([item.type isEqualToString:SettingItemTypeSwitch]) {
        ((UILabel *)[cell.contentView viewWithTag:1000]).text = item.title;
        ((UISwitch *)[cell.contentView viewWithTag:1001]).on = ((NSNumber *)item.value).boolValue;
    }
    else {
        cell.textLabel.text = item.title;
    }
    
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

@implementation SettingItem

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        _title = array[0];
        _type = array[1];
        if ([_type isEqualToString:SettingItemTypeDetail] || [_type isEqualToString:SettingItemTypeSwitch]) {
            _value = array[2];
        }
        if (((NSString *)array[3]).length > 0) {
            _entryIdentifier = array[3];
        }
    }
    return self;
}

@end