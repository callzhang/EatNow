//
//  ENLocationReporter.h
//  EatNow
//
//  Created by GaoYongqing on 1/17/16.
//  Copyright © 2016 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDSingleton.h"

@interface ENLocationReporter : NSObject

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENLocationReporter)

- (void)startMonitor;

- (void)stopMonitor;

@end
