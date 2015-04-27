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
    self.serverManager = [[ENServerManager alloc] init];
    
	[ENUtil showWatingHUB];
    [self.serverManager getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        [ENUtil dismissHUD];
        @strongify(self);
        if (user) {
            self.user = user;
            [self.tableView reloadData];
        }
    }];
    
}

//ZITAO: not setting _user??
- (void)setUser:(NSDictionary *)user{
    self.history = [user valueForKeyPath:@"all_history"];
    [self updatePreference:[user valueForKey:@"preference"]];
}

//ZITAO: renmae to setPreference??
- (void)updatePreference:(NSDictionary *)data{
    NSParameterAssert([data isKindOfClass:[NSDictionary class]]);
    NSMutableArray *scoreArray = [NSMutableArray new];
    [data enumerateKeysAndObjectsUsingBlock:^(NSString *cuisine, NSNumber *score, BOOL *stop) {
        [scoreArray addObject:@{@"cuisine":cuisine, @"score":score}];
    }];
		
    NSSortDescriptor *sortByScore = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    self.preference = [scoreArray sortedArrayUsingDescriptors:@[sortByScore]];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.history.count;
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
            return @"Statistics";
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
        //history
        NSDictionary *info = _history[indexPath.row];
        NSDictionary *restaurant = info[@"restaurant"];
        cell.textLabel.text = [restaurant valueForKey:@"name"];
        cell.detailTextLabel.text = [(NSArray *)[restaurant valueForKey:@"categories"] string];
        
        //date
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        NSDate *date = [ENUtil string2date:[info valueForKey:@"date"]];
        dateLabel.text = date.string;
        dateLabel.font = [UIFont systemFontOfSize:12];
        dateLabel.textColor = [UIColor colorWithWhite:0 alpha:0.8];
        cell.accessoryView = dateLabel;
        
        //image
        NSArray *imageUrls = [restaurant valueForKey:@"food_image_url"];
        NSString *imageUrlString = imageUrls.firstObject;
        if (!imageUrlString) {
            imageUrlString = [restaurant valueForKey:@"image_url"];
            imageUrlString = [imageUrlString stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
        }
        UIImage *img = [UIImage imageNamed:@"restaurant_default"];
        [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:img];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"preference"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"preference"];
        }
        //preference
		NSDictionary *info = self.preference[indexPath.row];
        NSString *name = info[@"name"];
        NSNumber *score = info[@"score"];
        if ((id)score == [NSNull null]) score = @0;
        cell.textLabel.text = name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f%%", score.floatValue*100];
    }
    
    return cell;
}

@end
