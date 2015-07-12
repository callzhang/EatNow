//
//  ENBasePreferenceRowItem.h
//  EatNow
//
//  Created by Lei Zhang on 7/12/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "TMRowItem.h"

@interface ENBasePreferenceRowItem : TMRowItem
@property (nonatomic, strong) NSString *cuisine;
@property (nonatomic, strong) NSNumber *score;
@end
