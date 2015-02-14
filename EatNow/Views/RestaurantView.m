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

//static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;

@implementation ViewOwner
@end

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

+ (instancetype)initViewWithOptions:(MDCSwipeOptions *)options{
//    DDLogInfo(@"Trying to load restaurant view from xib");
//    TIC
//    ViewOwner *owner = [ViewOwner new];
//    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:owner options:nil];
//    TOC
//    DDLogInfo(@"Trying to load restaurant view from storyboard");
    ENRestaurantViewContainer *container = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENRestaurantViewContainer"];
    RestaurantView *view = (RestaurantView *)container.view;
	NSAssert(view, @"Failed to load restaurant view");
	
    //customize view
    view.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
    view.layer.borderWidth = 2;
    view.layer.cornerRadius = 5;
    //view.backgroundColor = [UIColor clearColor];
    
    //label
    view.yesLabel.alpha = 0;
    view.nopeLabel.alpha = 0;
    view.yesLabel.layer.borderColor = view.yesLabel.textColor.CGColor;
    view.nopeLabel.layer.borderColor = view.nopeLabel.textColor.CGColor;
    view.yesLabel.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -15/180*M_PI);
    view.nopeLabel.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 15/180*M_PI);
    
    //wrap onPan block
    __block UILabel *weakLikedLabel = view.yesLabel;
    __block UILabel *weakNopeLabel = view.nopeLabel;
    MDCSwipeToChooseOnPanBlock block = options.onPan;
    options.onPan = ^(MDCPanState *state){
        if (state.direction == MDCSwipeDirectionNone) {
            weakLikedLabel.alpha = 0.f;
            weakNopeLabel.alpha = 0.f;
        } else if (state.direction == MDCSwipeDirectionLeft) {
            weakLikedLabel.alpha = 0.f;
            weakNopeLabel.alpha = state.thresholdRatio;
        } else if (state.direction == MDCSwipeDirectionRight) {
            weakLikedLabel.alpha = state.thresholdRatio;
            weakNopeLabel.alpha = 0.f;
        }
        
        if (block) {
            block(state);
        }
    };
    
    //setup options
    [view mdc_swipeToChooseSetup:options];
    return view;
}

- (void)setRestaurant:(Restaurant *)restaurant{
	_restaurant = restaurant;
	
	_currentIdx = -1;
	[self loadNextImage];
    
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisineStr;
    self.price.text = restaurant.pricesStr;
    self.rating.text = [NSString stringWithFormat:@"%.1f", restaurant.rating];
    self.reviews.text = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.reviews];
    self.distance.text = [NSString stringWithFormat:@"%.1fkm", restaurant.distance];
}

- (void)loadNextImage{
	if (_isLoadingImage) {
		NSLog(@"Loading image, skip");
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
									   NSLog(@"*** Failed to download image with error: %@", error);
									   ENAlert(error.description);
								   }];
}

- (void)showImage:(UIImage *)image{
	
	[UIView animateWithDuration:0.2 animations:^{
		self.imageView.alpha = 0;
	} completion:^(BOOL finished) {
		self.imageView.image = image;
		[UIView animateWithDuration:0.2 animations:^{
			self.imageView.alpha = 1;
		}];
	}];
	
	//start next
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self loadNextImage];
	});
}

@end
