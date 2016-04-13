//
//  TMSectionItemFetchedResultsRowDataSource.h
//  Pods
//
//  Created by Zitao Xiong on 6/2/15.
//
//

#import <Foundation/Foundation.h>
#import "TMSectionItemRowDataSource.h"
#import "TMSectionItemArrayRowItemDataSource.h"
@import CoreData;

@class TMSectionItem;
@interface TMSectionItemFetchedResultsRowItemDataSource : TMSectionItemArrayRowItemDataSource<TMSectionItemRowDataSource>
- (void)fillRowItemWillNullValue;
- (BOOL)performFetch:(NSError **)error;
@end
