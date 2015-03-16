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

@interface ENProfileViewController ()

@end

@implementation ENProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[ENUtil showWatingHUB];
    //fetch user info
    [[ENServerManager sharedInstance] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        if (user) {
			[ENUtil dismissHUD];
            self.user = user;
            [self.tableView reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUser:(NSDictionary *)user{
    self.history = [user valueForKeyPath:@"user.history"];
    [self updatePreference:[user valueForKey:@"preference"]];
}

- (void)updatePreference:(id)data{
    if ([data isKindOfClass:[NSArray class]]) {
        NSMutableArray *scoreDic = [NSMutableArray new];
        NSArray *scoreArray = (NSArray *)data;
        for (NSInteger i = 0; i<scoreArray.count; i++) {
            NSString *name = [ENServerManager sharedInstance].cuisines[i];
            NSNumber *score = scoreArray[i];
			scoreDic[i] = @{@"name":name, @"score": score};
        }
		NSSortDescriptor *sortByScore = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
		self.preference = [scoreDic sortedArrayUsingDescriptors:@[sortByScore]];
		//sort
        return;
    }
    DDLogError(@"Unexpected preference data %@", [data class]);
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
            return @"Histroy";
        case 1:
            return @"Preference (Internal testing)";
        default:
            break;
    }
    return @"??";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 22;
    }
    return 60;
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
