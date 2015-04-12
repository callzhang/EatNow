//
// ChoosePersonView.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RestaurantView.h"
#import "ImageLabelView.h"
#import "Restaurant.h"
#import "UIImageView+AFNetworking.h"
#import "ENServerManager.h"
#import "ENRestaurantViewContainer.h"
#import "TFHpple.h"

//static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;


@interface RestaurantView()
@property (nonatomic) BOOL isLoadingImage;
@property (nonatomic) NSInteger currentIdx;
@end

@implementation RestaurantView

#pragma mark - Object Lifecycle

//- (instancetype)initWithFrame:(CGRect)frame
//				   restaurant:(Restaurant *)restaurant
//                      options:(MDCSwipeToChooseViewOptions *)options {
//    self = [super initWithFrame:frame options:options];
//    if (self) {
//        _restaurant = restaurant;
//        self.imageView.image = _restaurant.image;
//
//        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
//                                UIViewAutoresizingFlexibleWidth |
//                                UIViewAutoresizingFlexibleBottomMargin;
//        self.imageView.autoresizingMask = self.autoresizingMask;
//
//        [self constructInformationView];
//    }
//    return self;
//}

+ (instancetype)loadView{
    ENRestaurantViewContainer *container = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENRestaurantViewContainer"];
    RestaurantView *view = (RestaurantView *)container.view;
    [view removeFromSuperview];
	NSAssert(view, @"Failed to load restaurant view");
	
    //customize view
    view.layer.cornerRadius = 15;
    
    return view;
}

- (void)setRestaurant:(Restaurant *)restaurant{
	_restaurant = restaurant;
	
	_currentIdx = -1;
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
    self.rating.text = [NSString stringWithFormat:@"%.1f", restaurant.rating.floatValue];
    self.reviews.text = [NSString stringWithFormat:@"%lu", (long)restaurant.reviews.integerValue];
    self.distance.text = [NSString stringWithFormat:@"%.1fkm", restaurant.distance];
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
	
	NSInteger nextIdx = (_currentIdx + 1) % self.restaurant.imageUrls.count;
	
	//display if downloaded
	if (self.restaurant.images.count > nextIdx) {
        if (self.restaurant.images[nextIdx] != [NSNull null]) {
            _currentIdx = nextIdx;
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
                                       _currentIdx = nextIdx;
                                       _isLoadingImage = NO;
									   [self.loading stopAnimating];
									   NSMutableArray *images = _restaurant.images.mutableCopy ?: [NSMutableArray arrayWithCapacity:_restaurant.imageUrls.count];
                                       while (images.count <= _currentIdx) {
                                           [images addObject:[NSNull null]];
                                       }
									   images[_currentIdx] = image;
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
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//		[self loadNextImage];
//	});
}

@end
