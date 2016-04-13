//
//  TMRadioOptionsTableViewController.m
//  Pods
//
//  Created by Zitao Xiong on 5/4/15.
//
//

#import "TMTableViewBuilderTableViewController.h"
#import "TMTableViewBuilder.h"

@interface TMTableViewBuilderTableViewController ()
@property (nonatomic, strong) void (^tm_rightNavigationBarButtonItemHandler)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem);
@property (nonatomic, strong) void (^tm_leftNavigationBarButtonItemHandler)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem);
@end

@implementation TMTableViewBuilderTableViewController
@synthesize tableView = _tableView;
@synthesize tableViewBuilder = _tableViewBuilder;
@synthesize viewDidLoadCompletionHandler = _viewDidLoadCompletionHandler;
@synthesize viewWillDisappearCompletionHandler = _viewWillDisappearCompletionHandler;
@synthesize tm_rightNavigationBarButtonItemHandler = _tm_rightNavigationBarButtonItemHandler;
@synthesize tm_leftNavigationBarButtonItemHandler = _tm_leftNavigationBarButtonItemHandler;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableViewBuilder = [[TMTableViewBuilder alloc] initWithTableView:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewBuilder.tableView = self.tableView;
    [self.tableViewBuilder configure];
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
