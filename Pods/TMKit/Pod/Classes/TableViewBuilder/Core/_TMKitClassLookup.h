//
//  TMKitClassLookup.h
//  Pods
//
//  Created by Zitao Xiong on 8/7/15.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, TMTableViewBuilderClassType) {
    TMTableViewBuilderClassTypeRadioOptionsTableViewController, //protocol TMRadioOptionsTableViewController
    TMTableViewBuilderClassTypeOptionRowItem, //protocol TMRadioOptionRow
    TMTableViewBuilderClassTypeSearchResultsController,
    TMTableViewBuilderClassTypeSearchController,
    TMTableViewBuilderClassTypeSectionItemClassForFetchedResultsController,
    TMTableViewBuilderClassTypeTableViewBuilderViewController,
};
@protocol TMKitClassLookup <NSObject>
@required
- (void)registerClass:(Class)klass forType:(TMTableViewBuilderClassType)type;
- (Class)classForType:(TMTableViewBuilderClassType)type;
@end

/**
 *  Sometime, TableViewBuilder needs to know what class to initialize when some *ACTIONS* are triggered
 *  These classes are designed to have specific logic in it. 
 *  In order to be able to subclass to provide more in detail customization.
 *  TMKitClassLookup provides a way to let each Row/Section/Builder to speficify whatever class they need. 
 *  If it does not speficify any, a default setting is provided.
 *  If it does speficify, it has the priority of Row > Section > TableViewBuiler
 *  In the case of Row/Section is not added into TableViewBuilder, and it does not have class specified, Default lookup will be used.
 */
@interface _TMKitClassLookup : NSObject

+ (instancetype)defaultLookup;

- (void)registerClass:(Class)kclass forType:(TMTableViewBuilderClassType)type;
- (Class)classForType:(TMTableViewBuilderClassType)type;
@end

