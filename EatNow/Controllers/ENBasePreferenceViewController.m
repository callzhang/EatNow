//
//  ENBasePreferenceViewController.m
//  
//
//  Created by Lei Zhang on 7/12/15.
//
//

#import "ENBasePreferenceViewController.h"
#import "ENServerManager.h"
#import "ENBasePreferenceViewCell.h"
//#import "TMTableViewBuilder.h"

@implementation ENBasePreferenceViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    //[self.tableView registerClass:[ENBasePreferenceViewCell class] forCellReuseIdentifier:@"basePreferenceCell"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(close:)];
    self.tableView.tintColor = [UIColor whiteColor];
    //self.tableView.backgroundColor = [UIColor blackColor];
}

- (IBAction)close:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kBasePreferences.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ENBasePreferenceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basePreferenceCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSString *cuisine = kBasePreferences[indexPath.row];
    //cell.textLabel.text = title;
    cell.cuisine = cuisine;
    //cell.backgroundImage.image = [UIImage imageNamed:cuisine];
    cell.score = @1;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
}


@end
