//
//  TMTableViewBuilderViewController.m
//  Pods
//
//  Created by Zitao Xiong on 7/12/15.
//
//

#import "TMTableViewBuilderViewController.h"
#import "PureLayout.h"
#import "TMTableViewBuilder.h"

@interface TMTableViewBuilderViewController ()
@property (nonatomic, strong) void (^tm_rightNavigationBarButtonItemHandler)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem);
@property (nonatomic, strong) void (^tm_leftNavigationBarButtonItemHandler)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem);
@end

@implementation TMTableViewBuilderViewController
@synthesize tableView = _tableView;
@synthesize tableViewBuilder = _tableViewBuilder;
@synthesize viewDidLoadCompletionHandler = _viewDidLoadCompletionHandler;
@synthesize viewWillDisappearCompletionHandler = _viewWillDisappearCompletionHandler;
@synthesize tm_rightNavigationBarButtonItemHandler = _tm_rightNavigationBarButtonItemHandler;
@synthesize tm_leftNavigationBarButtonItemHandler = _tm_leftNavigationBarButtonItemHandler;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self tm_commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self tm_commonInit];
    }
    return self;
}

- (void)tm_commonInit {
    self.tableViewBuilder = [[TMTableViewBuilder alloc] initWithTableView:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        [self.view addSubview:tableView];
        self.tableView = tableView;
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.tableView autoPinToBottomLayoutGuideOfViewController:self withInset:0];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    }
    self.tableViewBuilder.tableView = self.tableView;
    
    if (self.viewDidLoadCompletionHandler) {
        self.viewDidLoadCompletionHandler(self);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.viewWillDisappearCompletionHandler) {
        self.viewWillDisappearCompletionHandler(self, animated);
    }
}

- (void)tm_handleLeftBarButtonItem:(UIBarButtonItem *)barButtonItem {
    if (self.tm_leftNavigationBarButtonItemHandler) {
        self.tm_leftNavigationBarButtonItemHandler(self, barButtonItem);
    }
}

- (void)tm_handleRightBarButtonItem:(UIBarButtonItem *)barButtonItem {
    if (self.tm_rightNavigationBarButtonItemHandler) {
        self.tm_rightNavigationBarButtonItemHandler(self, barButtonItem);
    }
}

- (void)tm_setRightBarButtonItem:(UIBarButtonItem *)barButtonItem handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *, UIBarButtonItem *))handler {
    barButtonItem.target = self;
    barButtonItem.action = @selector(tm_handleRightBarButtonItem:);
    self.tm_rightNavigationBarButtonItemHandler = handler;
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)tm_setRightBarButtonItemWithTitle:(NSString *)barButtonItemTitle handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *, UIBarButtonItem *))handler {
    [self tm_setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:barButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:NULL] handler:handler];
}

- (void)tm_setLeftBarButtonItem:(UIBarButtonItem *)barButtonItem handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *, UIBarButtonItem *))handler {
    barButtonItem.target = self;
    barButtonItem.action = @selector(tm_handleLeftBarButtonItem:);
    self.tm_leftNavigationBarButtonItemHandler = handler;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)tm_setLeftBarButtonItemWithTitle:(NSString *)barButtonItemTitle handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *, UIBarButtonItem *))handler {
    [self tm_setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:barButtonItemTitle style:UIBarButtonItemStylePlain target:nil action:NULL] handler:handler];
}
@end
