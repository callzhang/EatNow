//
//  ENBasePreferenceViewController.m
//  
//
//  Created by Lei Zhang on 7/12/15.
//
//

#import "ENBasePreferenceViewController.h"
#import "TMTableViewBuilder.h"

@implementation ENBasePreferenceViewController
- (void)viewDidLoad{
    
    self.builder = [[TMTableViewBuilder alloc] initWithTableView:self.tableView];
    @weakify(self);
    self.builder.reloadBlock = ^(TMTableViewBuilder *builder) {
        @strongify(self);
        [self setDataWithHistory:[ENServerManager shared].history];
        [builder removeAllSectionItems];
        TMSectionItem *sectionItem = [TMSectionItem new];
        [builder addSectionItem:sectionItem];
        for (NSDate *date  in self.orderedDates) {
            ENHistoryHeaderRowItem *rowItem = [ENHistoryHeaderRowItem new];
            rowItem.date = date;
            [sectionItem addRowItem:rowItem];
            
            NSArray *restaurants = self.history[date.mt_endOfCurrentDay];
            for (NSDictionary *dict in restaurants) {
                ENRestaurant *restaurant = dict[@"restaurant"];
                NSNumber *like = dict[@"like"];
                ENHistoryRowItem *hRow = [ENHistoryRowItem new];
                hRow.restaurant = restaurant;
                hRow.rate = like;
                [sectionItem addRowItem:hRow];
                [hRow setDidSelectRowHandler:^(ENHistoryRowItem *rowItem) {
                    @strongify(self);
                    self.selectedPath = rowItem.indexPath;
                    ENHistoryViewCell *cell = (ENHistoryViewCell *)rowItem.cell;
                    CGRect frame = [self.mainView convertRect:cell.background.frame fromView:cell.contentView];
                    [self showRestaurantCard:restaurant fromFrame:frame];
                }];
            }
        }
        [self.tableView reloadData];
    };
    
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.builder configure];
}
@end
