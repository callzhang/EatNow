//
//  TMRowItem+Protected.h
//  TMKit
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMRowItem.h"

@interface TMRowItem ()
@property (nonatomic, readwrite, weak) TMSectionItem *sectionItem;
@property (nonatomic, strong) _TMKitClassLookup *classLookup;
@property (nonatomic, weak) TMRowItem *originalRowItem;
@property (nonatomic, copy) NSString *reuseIdentifier;

- (id)cellForReuseIdentifierOrRegister:(NSString *)reuseIdentifier;
@end
