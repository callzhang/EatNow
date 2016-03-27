//
//  ENProxy.h
//  EatNow
//
//  Created by GaoYongqing on 11/8/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDSingleton.h"

@interface ENProxy : NSObject

@property (nonatomic, assign) BOOL shouldRedirect;

GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENProxy);

/**
 * Check whether or not we should redirect the url
 */
- (void)checkShouldRedirect;

- (NSString *)redirectedUrlWithOriginalUrl:(NSString *)url;

@end
