//
// ChoosePersonViewController.m
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

#import "MainViewController.h"
#import "Restaurant.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "ENServerManager.h"
#import "ENWebViewController.h"

//static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
//static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface MainViewController ()
@property (nonatomic, strong) NSMutableArray *restaurants;
@end

@implementation MainViewController

#pragma mark - Object Lifecycle


#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //register notification
    [[NSNotificationCenter defaultCenter] addObserverForName:kFetchedRestaurantList object:nil queue:nil usingBlock:^(NSNotification *note) {
        //stop loading
        [self.loading stopAnimating];
        
        //read list
        [self getRestaurants];
        
        // Display the first ChoosePersonView in front. Users can swipe to indicate
        // whether they like or dislike the person displayed.
        self.frontCardView = [self popResuturantViewWithFrame:[self frontCardViewFrame]];
        [self.view addSubview:self.frontCardView];
        
        // Display the second ChoosePersonView in back. This view controller uses
        // the MDCSwipeToChooseDelegate protocol methods to update the front and
        // back views after each user swipe.
        self.backCardView = [self popResuturantViewWithFrame:[self backCardViewFrame]];
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
    }];

}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentRestaurant.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentRestaurant.name);
    } else {
        NSLog(@"You liked %@.", self.currentRestaurant.name);
        RestaurantView *rv = (RestaurantView *)view;
        NSString *url = rv.restaurant.url;
        ENWebViewController *webView = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENWebViewController"];
        webView.url = [NSURL URLWithString:url];
        [self.navigationController pushViewController:webView animated:YES];
    }

    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popResuturantViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(RestaurantView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentRestaurant = frontCardView.restaurant;
}

- (NSMutableArray *)getRestaurants {
    // It would be trivial to download these from a web service
    // as needed, but for the purposes of this sample app we'll
    // simply store them in memory.
    _restaurants = [ENServerManager sharedInstance].restaurants;
    
    return _restaurants;
}

- (RestaurantView *)popResuturantViewWithFrame:(CGRect)frame {
    if ([self.restaurants count] == 0) {
        return nil;
    }

    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    //MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        CGRect frame2 = CGRectMake(frame.origin.x,
                                 frame.origin.y - (state.thresholdRatio * 10.f),
                                 CGRectGetWidth(frame),
                                 CGRectGetHeight(frame));
        self.backCardView.frame = frame2;
    };

    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    //RestaurantView *card = [[RestaurantView alloc] initWithFrame:frame restaurant:self.restaurants.firstObject options:options];
    
    RestaurantView* card = [RestaurantView initViewWithOptions:options];
    card.restaurant = self.restaurants.firstObject;
    [self.restaurants addObject:self.restaurants.firstObject];
    [self.restaurants removeObjectAtIndex:0];
    return card;
}

#pragma mark - View Contruction

- (CGRect)frontCardViewFrame {
    CGRect frame = self.restaurantFrame.frame;
    return frame;
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}



#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (IBAction)nope:(id)sender {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (IBAction)like:(id)sender{
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}
@end
