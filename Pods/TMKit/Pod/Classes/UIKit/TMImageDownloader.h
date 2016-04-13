//
//  TMImageDownloader.h
//  Pods
//
//  Created by Zitao Xiong on 7/12/15.
//
//

#import <Foundation/Foundation.h>
#import "Bolts.h"
@protocol AFURLResponseSerialization, TMImageDownloaderImageCache;

@interface TMImageDownloader : NSObject
@property (nonatomic, strong) id <AFURLResponseSerialization> tm_imageResponseSerializer;
+ (id <TMImageDownloaderImageCache>)tm_sharedImageCache;
+ (void)tm_setSharedImageCache:(id <TMImageDownloaderImageCache>)imageCache;
- (void)tm_cancelImageRequestOperation;

- (BFTask *)tm_getImageWithURLString:(NSString *)urlString;

- (BFTask *)tm_getImageWithURL:(NSURL *)url;

- (BFTask *)tm_getImageWithURLRequest:(NSURLRequest *)urlRequest;
@end

@protocol TMImageDownloaderImageCache <NSObject>
- (UIImage *)tm_cachedImageForRequest:(NSURLRequest *)request;
- (void)tm_cacheImage:(UIImage *)image
           forRequest:(NSURLRequest *)request;
@end