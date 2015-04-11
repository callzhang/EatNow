//
//  ENRestaurantViewController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/7/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENRestaurantViewController.h"

@interface ENRestaurantViewController ()
/** normalCardInsideContainerTopLayoutConstraint and normalCardInsideContainerHeightConstraints
 *  decide view's height and top margin, animate those properites with param for each devices for fine control
 **/
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expandCardInsideContainerTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *expandCardInsideContainerHeightConstraints;

/**
 *  set uibutton's content mode: http://stackoverflow.com/questions/2950613/uibutton-doesnt-listen-to-content-mode-setting
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConstraint;
@end

/**
 *  checkout WJCustomizeView, set it in interfacebuilder to set radius corner
 * missing font and images for new design.
 * I did not add bottom buttons, since we are missing assets and they are fairly easy to add.
 */

@implementation ENRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //http://stackoverflow.com/questions/1369831/eliminate-extra-separators-below-uitableview-in-iphone-sdk
}

@end
