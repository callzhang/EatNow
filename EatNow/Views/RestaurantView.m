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
    return view;
}

- (void)setRestaurant:(Restaurant *)restaurant{
    
    self.imageView.image = restaurant.image;
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisine;
    self.price.text = [self pricesSignFromNumber:restaurant.price];
    self.rating.text = [NSString stringWithFormat:@"%.1f", restaurant.rating];
    self.reviews.text = [NSString stringWithFormat:@"%lu", (unsigned long)restaurant.reviews];
    self.distance.text = [NSString stringWithFormat:@"%.1fmi", restaurant.distance];
    
}


- (NSString *)pricesSignFromNumber:(float)p{
    NSMutableString *dollarSign = [@"" mutableCopy];
    for (NSUInteger i=0; i<p; i++) {
        [dollarSign appendString:@"$"];
    }
    return dollarSign.copy;
}

#pragma mark - Internal Methods

//- (void)constructInformationView {
//    CGFloat bottomHeight = 60.f;
//    CGRect bottomFrame = CGRectMake(0,
//                                    CGRectGetHeight(self.bounds) - bottomHeight,
//                                    CGRectGetWidth(self.bounds),
//                                    bottomHeight);
//    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
//    _informationView.backgroundColor = [UIColor whiteColor];
//    _informationView.clipsToBounds = YES;
//    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
//                                        UIViewAutoresizingFlexibleTopMargin;
//    [self addSubview:_informationView];
//
//    [self constructNameLabel];
//    [self constructCameraImageLabelView];
//    [self constructInterestsImageLabelView];
//    [self constructFriendsImageLabelView];
//}
//
//- (void)constructNameLabel {
//    CGFloat leftPadding = 12.f;
//    CGFloat topPadding = 17.f;
//    CGRect frame = CGRectMake(leftPadding,
//                              topPadding,
//                              floorf(CGRectGetWidth(_informationView.frame)/2),
//                              CGRectGetHeight(_informationView.frame) - topPadding);
//    _nameLabel = [[UILabel alloc] initWithFrame:frame];
//    _nameLabel.text = [NSString stringWithFormat:@"%@, %@", _restaurant.name, _restaurant.cuisine];
//    [_informationView addSubview:_nameLabel];
//}
//
//- (void)constructCameraImageLabelView {
//    CGFloat rightPadding = 10.f;
//    UIImage *image = [UIImage imageNamed:@"camera"];
//    _cameraImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding
//                                                      image:image
//                                                       text:[@(_restaurant.distance) stringValue]];
//    [_informationView addSubview:_cameraImageLabelView];
//}
//
//- (void)constructInterestsImageLabelView {
//    UIImage *image = [UIImage imageNamed:@"book"];
//    _interestsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_cameraImageLabelView.frame)
//                                                         image:image
//                                                          text:[@(_restaurant.distance) stringValue]];
//    [_informationView addSubview:_interestsImageLabelView];
//}
//
//- (void)constructFriendsImageLabelView {
//    UIImage *image = [UIImage imageNamed:@"group"];
//    _friendsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_interestsImageLabelView.frame)
//                                                      image:image
//                                                       text:[@(_restaurant.rating) stringValue]];
//    [_informationView addSubview:_friendsImageLabelView];
//}
//
//- (ImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
//    CGRect frame = CGRectMake(x - ChoosePersonViewImageLabelWidth,
//                              0,
//                              ChoosePersonViewImageLabelWidth,
//                              CGRectGetHeight(_informationView.bounds));
//    ImageLabelView *view = [[ImageLabelView alloc] initWithFrame:frame
//                                                           image:image
//                                                            text:text];
//    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    return view;
//}

@end
