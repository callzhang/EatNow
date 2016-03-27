//
//  ENProxy.m
//  EatNow
//
//  Created by GaoYongqing on 11/8/15.
//  Copyright © 2015 modocache. All rights reserved.
//

#import "ENProxy.h"
#import "AFNetworking.h"
#import "NSString+Extend.h"

static NSString* const kIPServerAPI = @"http://api.wipmania.com/";
static NSString* const kProxyUrl = @"http://api.eatnow.cc/image?url=";

static NSString* const kEatNowShouldRedirect = @"com.eatnow.setting.shouldredirect";

@implementation ENProxy
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENProxy);

- (NSString *)redirectedUrlWithOriginalUrl:(NSString *)url
{
    if (!url || !self.shouldRedirect) {
        return url;
    }
    
    return [NSString stringWithFormat:@"%@%@", kProxyUrl, [url URLEncodedString]];
}

- (void)checkShouldRedirect
{
    [self checkIsIpInChina];
}

#pragma mark - Private

- (void)checkIsIpInChina
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:kIPServerAPI parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseText = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        self.shouldRedirect = ([responseText rangeOfString:@"CN"].location != NSNotFound);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DDLogError(@"Check is in china error: %@", error);
    }];
}

@end
