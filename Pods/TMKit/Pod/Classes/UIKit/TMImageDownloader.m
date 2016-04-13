//
//  TMImageDownloader.m
//  Pods
//
//  Created by Zitao Xiong on 7/12/15.
//
//

#import "TMImageDownloader.h"
#import "AFHTTPRequestOperation.h"
#import <objc/runtime.h>

@interface TMImageDownloaderImageCache : NSCache <TMImageDownloaderImageCache>
@end

@interface TMImageDownloader (_TMImage_AFNetworking)
@property (readwrite, nonatomic, strong, setter = tm_setImageRequestOperation:) AFHTTPRequestOperation *tm_imageRequestOperation;
@end

@implementation TMImageDownloader (_TMImage_AFNetworking)
+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return _af_sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)tm_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(tm_imageRequestOperation));
}

- (void)tm_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(tm_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end


@implementation TMImageDownloader

@dynamic tm_imageResponseSerializer;

+ (id <TMImageDownloaderImageCache>)tm_sharedImageCache {
    static TMImageDownloaderImageCache *_tm_defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _tm_defaultImageCache = [[TMImageDownloaderImageCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_tm_defaultImageCache removeAllObjects];
        }];
    });
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(tm_sharedImageCache)) ?: _tm_defaultImageCache;
#pragma clang diagnostic pop
}

+ (void)tm_setSharedImageCache:(id <TMImageDownloaderImageCache>)imageCache {
    objc_setAssociatedObject(self, @selector(tm_sharedImageCache), imageCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <AFURLResponseSerialization>)tm_imageResponseSerializer {
    static id <AFURLResponseSerialization> _tm_defaultImageResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tm_defaultImageResponseSerializer = [AFImageResponseSerializer serializer];
    });
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(tm_imageResponseSerializer)) ?: _tm_defaultImageResponseSerializer;
#pragma clang diagnostic pop
}

- (void)tm_setImageResponseSerializer:(id <AFURLResponseSerialization>)serializer {
    objc_setAssociatedObject(self, @selector(tm_imageResponseSerializer), serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BFTask *)tm_getImageWithURLString:(NSString *)urlString {
    return [self tm_getImageWithURL:[NSURL URLWithString:urlString]];
}

- (BFTask *)tm_getImageWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    return [self tm_getImageWithURLRequest:request];
}

- (BFTask *)tm_getImageWithURLRequest:(NSURLRequest *)urlRequest {
    [self tm_cancelImageRequestOperation];
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    UIImage *cachedImage = [[[self class] tm_sharedImageCache] tm_cachedImageForRequest:urlRequest];
    if (cachedImage) {
        [taskSource setResult:cachedImage];
        
        self.tm_imageRequestOperation = nil;
    } else {
        __weak __typeof(self)weakSelf = self;
        self.tm_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.tm_imageRequestOperation.responseSerializer = self.tm_imageResponseSerializer;
        [self.tm_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.tm_imageRequestOperation.request URL]]) {
                [taskSource setResult:responseObject];
                
                if (operation == strongSelf.tm_imageRequestOperation){
                    strongSelf.tm_imageRequestOperation = nil;
                }
            }
            
            [[[strongSelf class] tm_sharedImageCache] tm_cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [taskSource setError:error];
            if ([[urlRequest URL] isEqual:[strongSelf.tm_imageRequestOperation.request URL]]) {
                
                if (operation == strongSelf.tm_imageRequestOperation){
                    strongSelf.tm_imageRequestOperation = nil;
                }
            }
        }];
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.tm_imageRequestOperation];
    }
    
    return taskSource.task;
}

- (void)tm_cancelImageRequestOperation {
    [self.tm_imageRequestOperation cancel];
    self.tm_imageRequestOperation = nil;
}

@end


#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation TMImageDownloaderImageCache

- (UIImage *)tm_cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }
    
    return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)tm_cacheImage:(UIImage *)image
           forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

@end