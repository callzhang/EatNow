//
// ChoosePersonViewController.h
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

#import <UIKit/UIKit.h>
#import "ENRestaurantView.h"

#define kMaxRestaurants     12
#define kMaxCardsToAnimate  4

@interface ENMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *cardFrame;
@property (weak, nonatomic) IBOutlet UIView *detailFrame;
@property (weak, nonatomic) IBOutlet UIImageView *loading;
@property (weak, nonatomic) IBOutlet UILabel *loadingInfo;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
//frame
@property (nonatomic, readonly) ENRestaurantView *frontCardView;
@property (nonatomic, strong) NSMutableArray *restaurantCards;
//states
@property (nonatomic, assign) BOOL isDismissingCard;
@property (nonatomic, assign) BOOL isShowingCards;
//data
@property (nonatomic, strong) NSMutableDictionary *userRating;
@end
