//
//  TMRadioRowItem.m
//  Pods
//
//  Created by Zitao Xiong on 5/4/15.
//
//

@import UIKit;
#import "TMRadioRowItem.h"
#import "TMRadioTableViewCell.h"
#import "TMTableViewBuilderTableViewController.h"
#import "TMRadioOptionRowItem.h"
#import "TMKit.h"
#import "TMRadioOptionsTableViewController.h"
#import "TMRowItem+Protected.h"

@interface TMRadioOptionsTableViewController ()
@property (nonatomic, strong) _TMKitClassLookup *classLookup;
@end

@implementation TMRadioRowItem
@synthesize detailText = _detailText;

+ (NSString *)reuseIdentifier {
    return @"TMRadioTableViewCell";
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithRowItemsForSelectionWithText:(NSArray * __nullable )texts selectedIndex:(NSNumber * __nullable)index {
    NSMutableArray *list = [NSMutableArray array];
    Class klass = [self classForType:TMTableViewBuilderClassTypeOptionRowItem];
    [texts enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
        TMRowItem *model = [[klass alloc] init];
        model.text = text;
        [list addObject:model];
        if (index && [index integerValue] == idx) {
            model.selected = YES;
        }
    }];
    return [self initWithRowItemsForSelection:list];
}

- (instancetype)initWithRowItemsForSelection:(NSArray * __nullable )models {
    self = [super init];
    if (self) {
        self.rowItemsForSelection = models;
    }
    return self;
}

- (id)cellForRow {
    UITableViewCell<TMRadioRowTableViewCellProtocol> *cell = [super cellForRow];
    
    if ([cell conformsToProtocol:@protocol(TMRadioRowTableViewCellProtocol)]) {
        cell.cellTitleLabel.text = self.text;
        cell.selectionTextLabel.text = self.detailText;
    }
    
    return cell;
}

- (void)didSelectRow {
    self.viewControllerPresentationOption.presentationStyle = TMViewControllerPresentationOptionStylePush;
    [super didSelectRow];
}

- (void)updateDetailTextForTableViewCell {
    UITableViewCell<TMRadioRowTableViewCellProtocol> *cell = (id)self.cell;
    if (cell && [cell conformsToProtocol:@protocol(TMRadioRowTableViewCellProtocol)]) {
        cell.selectionTextLabel.text = self.detailText;
    }
}

- (NSString *)detailText {
    if (_detailText) {
        return _detailText;
    }
    if ([self.optionTableViewController.optionsTableViewControllerDelegate respondsToSelector:@selector(detailTextForOptionsTableViewController:)]) {
        NSString *text = [self.optionTableViewController.optionsTableViewControllerDelegate detailTextForOptionsTableViewController:self.optionTableViewController];
        return text;
    }
    
    NSMutableArray *selectedModels = [NSMutableArray array];
    NSUInteger count = [self.optionTableViewController.optionsTableViewControllerDataSource numberOfOptionRowsInOptionsTableViewController:self.optionTableViewController];
    for (NSUInteger i = 0; i < count; i ++) {
        TMRowItem *model = [self.optionTableViewController.optionsTableViewControllerDataSource optionsTableViewController:self.optionTableViewController optionRowAtIndex:i];
        if (model.selected) {
            [selectedModels addObject:model];
        }
    }
    
    if (selectedModels.count == 0) {
        if (!self.optionTableViewController.tableView.indexPathForSelectedRow) {
            return self.detailTextPlaceHolder;
        }
    }
    
    NSString *text = self.detailTextTransformBlcok(selectedModels);
    return text;
}

- (NSString * __nonnull (^ __nonnull)(NSArray * __nonnull))detailTextTransformBlcok {
    if (!_detailTextTransformBlcok) {
        _detailTextTransformBlcok = ^NSString* (NSArray *modelList) {
            if (modelList.count == 1) {
                TMRowItem *model = [modelList firstObject];
                return model.text;
            }
            else {
                NSArray *textList = [modelList valueForKeyPath:@"text"];
                return [textList componentsJoinedByString:@", "];
            }
        };
    }
    
    return _detailTextTransformBlcok;
}


#pragma mark - TMRadioRowDataSource
- (NSInteger)numberOfOptionRowsInOptionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController {
    return [self.rowItemsForSelection count];
}

- (TMRowItem *)optionsTableViewController:(TMRadioOptionsTableViewController *)optionsTableViewController optionRowAtIndex:(NSUInteger)index {
    return [self.rowItemsForSelection objectAtIndex:index];
}
#pragma mark - OptionsTableViewCntroller

- (UIViewController<TMTableViewBuilderViewController> * __nonnull)presentedTableViewBuilderViewController {
    return self.optionTableViewController;
}

- (TMRadioOptionsTableViewController *)optionTableViewController {
    if (!_optionTableViewController) {
        Class klass = [self classForType:TMTableViewBuilderClassTypeRadioOptionsTableViewController];
        TMRadioOptionsTableViewController *vc = [[klass alloc] init];
        vc.classLookup = self.classLookup;
        vc.radioRowItem = self;
        vc.optionsTableViewControllerDataSource = self;
        vc.title = self.text;
        
        @weakify(self);
        [vc setViewWillLoadHandler:^(TMRadioOptionsTableViewController *vc) {
            @strongify(self);
            if (self.viewWillLoadForOptionViewController) {
                self.viewWillLoadForOptionViewController(vc, self);
            }
        }];
        
        [vc setViewDidLoadForOptionViewController:^(id vc) {
            @strongify(self);
            if (self.viewDidLoadForOptionViewController) {
                self.viewDidLoadForOptionViewController(vc, self);
            }
        }];
        
        _optionTableViewController = vc;
        
    }
    return _optionTableViewController;
}

#pragma mark -
- (id)copyWithZone:(NSZone *)zone {
    TMRadioRowItem *rowItem = [super copyWithZone:zone];
    
    [rowItem setRowItemsForSelection:self.rowItemsForSelection];
    [rowItem setViewDidLoadForOptionViewController:self.viewDidLoadForOptionViewController];
    
    return rowItem;
}
@end


//@implementation TMRadioRowItemSelectionModel
//
//- (instancetype)initWithText:(NSString *)text context:(id)context {
//    self = [super init];
//    if (self) {
//        self.text = text;
//        self.context = context;
//    }
//    
//    return self;
//}
//
//- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText context:(id)context {
//    self = [super init];
//    if (self) {
//        self.attributedText = attributedText;
//        self.context = context;
//    }
//    
//    return self;
//}
//
//+ (instancetype)modelWithText:(NSString *)text {
//    return [[self alloc] initWithText:text context:nil];
//}
//
//- (void)setAttributedText:(NSAttributedString * __nullable)attributedText {
//    _attributedText = [attributedText copy];
//    self.text = [attributedText string];
//}
////
////- (id)copyWithZone:(NSZone *)zone {
////    TMRadioRowItemSelectionModel *model = [self.class alloc];
////    model.text = self.text;
////    if ([self.context conformsToProtocol:@protocol(NSCopying)]) {
////        model.context = [self.context copy];
////    }
////    
////    return model;
////}
//
//@end