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

//static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;

@implementation ViewOwner
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
    ViewOwner *owner = [ViewOwner new];
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:owner options:nil];
    RestaurantView *view = owner.subclassedView;
    [view mdc_swipeToChooseSetup:options];
    
    //customize view
    view.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
    
    return view;
}

- (void)setRestaurant:(Restaurant *)restaurant{
    _restaurant = restaurant;
    if (restaurant.image) {
        self.imageView.image = restaurant.image;
    }else{
        //download first
        [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:restaurant.imageUrl]]
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           self.imageView.image = image;
                                           _restaurant.image = image;
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"*** Failed to download image with url: %@", restaurant.imageUrl);
                                       }];
    }
    
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisineStr;
    self.price.text = restaurant.pricesStr;
    self.rating.text = [NSString stringWithFormat:@"%.1f", restaurant.rating];
    self.reviews.text = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.reviews];
    self.distance.text = [NSString stringWithFormat:@"%.1fkm", restaurant.distance];
}



@end
