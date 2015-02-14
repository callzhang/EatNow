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
#import "FBKVOController.h"
//#import "DZNWebViewController.h"
#import "JBWebViewController.h"

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
	[self.KVOController observe:[ENServerManager sharedInstance] keyPath:@"status" options:NSKeyValueObservingOptionNew block:^(id observer, ENServerManager *manager, NSDictionary *change) {
		if (manager.status & DeterminReachability) {
			self.loadingInfo.text = @"Determining connecting";
		} else{
			if (manager.status & IsReachable){
				self.loadingInfo.text = @"Connected";
			}else{
				self.loadingInfo.text = @"No internet connection";
                return;
			}
		}
		if (manager.status & GettingLocation) {
			self.loadingInfo.text = @"Determining location";
		} else{
			if (manager.status & GotLocation){
				self.loadingInfo.text = @"Got location";
			}else{
				self.loadingInfo.text = @"Failed to get location";
                return;
			}
		}
		if (manager.status & FetchingRestaurant) {
			self.loadingInfo.text = @"Finding the best restaurant";
		} else{
			if (manager.status & FetchedRestaurant){
				[self showRestaurants];
			}else{
				self.loadingInfo.text = @"Failed to get restaurant list";
                return;
			}
		}
	}];
	
	[[ENServerManager sharedInstance] getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
		if (success) {
			[self showRestaurants];
		}
	}];
}

- (void)showRestaurants{
	
	self.loadingInfo.text = @"";
	//stop loading
	[self.loading stopAnimating];
	//read list
	[self getRestaurants];
	
	if (self.frontCardView) {
		DDLogWarn(@"=== Front view already exists, skip showing restaurant");
		return;
	}
	// Display the first ChoosePersonView in front. Users can swipe to indicate
	// whether they like or dislike the person displayed.
	self.frontCardView = [self popResuturantViewWithFrame:[self frontCardViewFrame]];
	[self.view addSubview:self.frontCardView];
	
	// Display the second ChoosePersonView in back. This view controller uses
	// the MDCSwipeToChooseDelegate protocol methods to update the front and
	// back views after each user swipe.
	self.backCardView = [self popResuturantViewWithFrame:[self backCardViewFrame]];
	[self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
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
    }

    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    self.backCardView = [self popResuturantViewWithFrame:[self backCardViewFrame]];
    if (self.backCardView) {
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
	
	options.onTap = ^(UITapGestureRecognizer *guesture){
		NSLog(@"Tapped");
		RestaurantView *rv = (RestaurantView *)guesture.view;
        NSURL *url = [NSURL URLWithString:rv.restaurant.url];
        JBWebViewController *webVC = [[JBWebViewController alloc] initWithUrl:url];
		//webVC.supportedWebNavigationTools = DZNWebNavigationToolAll;
        //[self.navigationController pushViewController:WVC animated:YES];
        
        //present
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
        webVC.navigationItem.rightBarButtonItem = close;
		[self.navigationController presentViewController:nav animated:YES completion:nil];
	};

    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    //RestaurantView *card = [[RestaurantView alloc] initWithFrame:frame restaurant:self.restaurants.firstObject options:options];
    
    RestaurantView* card = [RestaurantView initViewWithOptions:options];
    card.frame = frame;
    card.restaurant = self.restaurants.firstObject;
    [self.restaurants addObject:self.restaurants.firstObject];
    [self.restaurants removeObjectAtIndex:0];
    return card;
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)refresh:(id)sender {
    [ENServerManager sharedInstance].currentLocation = nil;
    [ENServerManager sharedInstance].status = IsReachable;
    self.restaurants = nil;
    [self nope:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nope:nil];
    });
    [self.loading startAnimating];
    [[ENServerManager sharedInstance] getRestaurantListWithCompletion:^(BOOL success, NSError *error) {
		if (!success){
			NSString *str = [NSString stringWithFormat:@"Failed to get restaurant with error: %@", error];
			ENAlert(str);
			NSLog(@"%@", str);
		} else {
			[self showRestaurants];
		}
    }];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//	if ([segue.destinationViewController isKindOfClass:[DZNWebViewController class]]) {
//		DZNWebViewController *controller = (DZNWebViewController *)segue.destinationViewController;
//		controller.URL = [NSURL URLWithString:self.frontCardView.restaurant.url];
//	}
//}

@end
