//
//  ENPreferenceMoodPickerDataSource.m
//  EatNow
//
//  Created by GaoYongqing on 9/20/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENPreferenceMoodPickerDataSource.h"
#import "ENServerManager.h"

@implementation ENPreferenceMoodPickerDataSource

- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView
{
    return kMoodList.count;
}

- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item
{
    return kMoodList[item];
}


@end
