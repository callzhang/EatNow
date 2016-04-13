//
//  NSObject+TMImageDownloader.m
//  Pods
//
//  Created by Zitao Xiong on 7/13/15.
//
//

#import "NSObject+TMImageDownloader.h"
#import <objc/message.h>

static void *NSObjectTMImageDownloaderKey = &NSObjectTMImageDownloaderKey;

@implementation NSObject (TMImageDownloader)
- (TMImageDownloader *)tm_imageDownloader {
    id controller = objc_getAssociatedObject(self, NSObjectTMImageDownloaderKey);
    
    // lazily create the tm_imageDownloader
    if (nil == controller) {
        controller = [[TMImageDownloader alloc] init];
        self.tm_imageDownloader = controller;
    }
    
    return controller;
}

- (void)setTm_imageDownloader:(TMImageDownloader *)tm_imageDownloader {
    objc_setAssociatedObject(self, NSObjectTMImageDownloaderKey, tm_imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
