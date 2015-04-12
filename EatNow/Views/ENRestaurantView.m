//
//  ENRestaurantView.m
//  EatNow
//
//  Created by Lei Zhang on 4/10/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENRestaurantView.h"
#import "TFHpple.h"
#import "UIImageView+AFNetworking.h"
#import "ENServerManager.h"
#import "FBKVOController.h"

@interface ENRestaurantView()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *cuisine;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

//autolayout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHightRatio;//normal 0.45

//internal
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) BOOL isLoadingImage;
@end

@implementation ENRestaurantView
+ (instancetype)loadView{
    UIViewController *container = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENCardContainer"];
    ENRestaurantView *view = (ENRestaurantView *)container.view;
    NSParameterAssert([view isKindOfClass:[ENRestaurantView class]]);
    [view removeFromSuperview];
    
    //customize view
    view.layer.cornerRadius = 15;
    
    [view.KVOController observe:view keyPath:@"status" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [view updateLayoutConstraintValue];
    }];
    
    return view;
}


- (void)setRestaurant:(Restaurant *)restaurant{
    _restaurant = restaurant;
    _currentImageIndex = -1;
    self.status = ENRestaurantViewStatusCard;
    [self updateLayoutConstraintValue];
    
    [self loadNextImage];
    NSString *tempUrl = [NSString stringWithFormat:@"http://foursquare.com/v/%@", restaurant.ID];
    [self parseFoursquareWebsiteForImagesWithUrl:tempUrl completion:^(NSArray *imageUrls, NSError *error) {
        if (!imageUrls) {
            DDLogError(@"Failed to parse foursquare %@", restaurant.url);
            return;
        }
        //save urls -> replace exisiting image
        //		NSMutableArray *images = restaurant.imageUrls.mutableCopy;
        //		[images addObjectsFromArray:imageUrls];
        restaurant.imageUrls = imageUrls;
    }];
    
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisineStr;
    self.price.text = restaurant.pricesStr;
    self.rating.text = [NSString stringWithFormat:@"%ld", (long)restaurant.rating.integerValue];
    //self.reviews.text = [NSString stringWithFormat:@"%lu", (long)restaurant.reviews.integerValue];
    //self.distance.text = [NSString stringWithFormat:@"%.1fkm", restaurant.distance];
}

- (void)updateLayoutConstraintValue{
    //radio
    float multiplier = self.status == ENRestaurantViewStatusCard ? 1:0.45;
    NSLayoutConstraint *newRatio = [NSLayoutConstraint constraintWithItem:_infoHightRatio.firstItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_infoHightRatio.secondItem attribute:NSLayoutAttributeHeight multiplier:multiplier constant:0];
    self.infoHightRatio.active = NO;
    self.infoHightRatio = newRatio;
    self.infoHightRatio.active = YES;
    [self layoutIfNeeded];
}

- (void)parseFoursquareWebsiteForImagesWithUrl:(NSString *)urlString completion:(void (^)(NSArray *imageUrls, NSError *error))block{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = responseObject;
        TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
        NSArray * elements  = [doc searchWithXPathQuery:@"//div[@class='photosSection']/ul/li/img"];
        NSMutableArray *images = [NSMutableArray array];
        for (TFHppleElement *element in elements) {
            NSString *imgUrl = [element objectForKey:@"data-retina-url"];
            if (imgUrl) {
                NSMutableArray *urlComponents = [imgUrl componentsSeparatedByString:@"/"].mutableCopy;
                NSString *sizeStr = urlComponents[urlComponents.count-2];
                if (sizeStr.length == 7 && [sizeStr characterAtIndex:3] == 'x') {
                    urlComponents[urlComponents.count-2] = @"original";
                    imgUrl = [urlComponents componentsJoinedByString:@"/"];
                }
                [images addObject:imgUrl];
            }
        }
        //DDLogVerbose(@"Parsed img urls: %@", images);
        block(images, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Failed to download website %@", urlString);
        block(nil, error);
    }];;
    [op start];
}

- (void)loadNextImage{
    if (_isLoadingImage) {
        DDLogVerbose(@"Loading image, skip");
        return;
    }
    if (_restaurant.imageUrls.count == 1 && self.imageView.image) {
        DDLogVerbose(@"Only one image, skip");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadNextImage];
        });
        return;
    }
    
    NSInteger nextIdx = (_currentImageIndex + 1) % self.restaurant.imageUrls.count;
    
    //display if downloaded
    if (self.restaurant.images.count > nextIdx) {
        if (self.restaurant.images[nextIdx] != [NSNull null]) {
            _currentImageIndex = nextIdx;
            [self showImage:self.restaurant.images[nextIdx]];
            return;
        }
    }
    
    //download
    self.isLoadingImage = YES;
    [self.loading startAnimating];
    NSURL *url = [NSURL URLWithString:self.restaurant.imageUrls[nextIdx]];
    //download first
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                          placeholderImage:self.imageView.image
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       _currentImageIndex = nextIdx;
                                       _isLoadingImage = NO;
                                       [self.loading stopAnimating];
                                       NSMutableArray *images = _restaurant.images.mutableCopy ?: [NSMutableArray arrayWithCapacity:_restaurant.imageUrls.count];
                                       while (images.count <= _currentImageIndex) {
                                           [images addObject:[NSNull null]];
                                       }
                                       images[_currentImageIndex] = image;
                                       _restaurant.images = images.copy;
                                       
                                       [self showImage:image];
                                       
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       NSString *str = [NSString stringWithFormat:@"Failed to download image with error %@ code %ld", error.domain, (long)error.code];
                                       DDLogError(@"*** Failed to download image with error: %@", error);
                                       ENAlert(str);
                                   }];
}

- (void)showImage:(UIImage *)image{
    if (self.loading.isAnimating) {
        [self.loading stopAnimating];
    }
    self.imageView.image = image;
    //duplicate view
    if (self.superview) {
        UIView *imageViewCopy = [self.imageView snapshotViewAfterScreenUpdates:NO];
        [self insertSubview:imageViewCopy aboveSubview:self.imageView];
        [UIView animateWithDuration:0.5 animations:^{
            imageViewCopy.alpha = 0;
        } completion:^(BOOL finished) {
            [imageViewCopy removeFromSuperview];
        }];
    }
        
    //send image change notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image":image}];
    
    //start next
    if (self.status == ENRestaurantViewStatusDetail) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadNextImage];
        });
    }
    
}

@end
