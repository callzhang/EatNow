//
//  TMTableViewBuilderViewController.h
//  Pods
//
//  Created by Zitao Xiong on 7/12/15.
//
//

#import <UIKit/UIKit.h>
#import "TMTableViewBuilder.h"

@protocol TMTableViewBuilderViewController <NSObject>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TMTableViewBuilder *tableViewBuilder;
/**
 *  called after view did load
 */
@property (nonatomic, copy) void (^viewDidLoadCompletionHandler) (UIViewController<TMTableViewBuilderViewController> *tableViewController);
/**
 *  called before view will disappear
 */
@property (nonatomic, copy) void (^viewWillDisappearCompletionHandler) (UIViewController<TMTableViewBuilderViewController> *tableViewController, BOOL animated);

//@property (nonatomic, copy) BOOL (^shouldDismissViewControllerHandler) (UIViewController<TMTableViewBuilderViewController> *viewController);
//@property (nonatomic, copy) BOOL (^shouldPopViewControllerHandler) (UIViewController<TMTableViewBuilderViewController> *viewController);

- (void)tm_setRightBarButtonItem:(UIBarButtonItem *)barButtonItem handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem))handler;

- (void)tm_setRightBarButtonItemWithTitle:(NSString *)barButtonItemTitle handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem))handler;

- (void)tm_setLeftBarButtonItem:(UIBarButtonItem *)barButtonItem handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem))handler;

- (void)tm_setLeftBarButtonItemWithTitle:(NSString *)barButtonItemTitle handler:(void (^)(UIViewController<TMTableViewBuilderViewController> *vc, UIBarButtonItem *barButtonItem))handler;
@end

@interface TMTableViewBuilderViewController : UIViewController <TMTableViewBuilderViewController>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) TMTableViewBuilder *tableViewBuilder;
@end
