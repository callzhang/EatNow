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
#import "ENServerManager.h"
#import "ENWebViewController.h"
#import "FBKVOController.h"
//#import "DZNWebViewController.h"
//#import "JBWebViewController.h"
#import "ENProfileViewController.h"
#import "ENMapViewController.h"
#import "ENLocationManager.h"
#import "extobjc.h"

//static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
//static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface MainViewController () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;
@end

@implementation MainViewController

#pragma mark - Object Lifecycle


#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [ENLocationManager new];
    self.serverManager = [ENServerManager new];
    
    [self.KVOController observe:self.locationManager keyPath:@keypath(self.locationManager, locationStatus) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, ENLocationManager *manager, NSDictionary *change) {
        if (manager != NULL) {
            ENLocationStatus locationStatus = manager.locationStatus;
            switch (locationStatus) {
                case ENLocationStatusGettingLocation:
                    self.loadingInfo.text = @"Determining location";
                    break;
                case ENLocationStatusGotLocation:
                    self.loadingInfo.text = @"Got location";
                    break;
                default:
                    break;
            }
        }
    }];
    
    [self.KVOController observe:self.serverManager keyPath:@keypath(self.serverManager, fetchStatus) options:NSKeyValueObservingOptionNew block:^(id observer, ENServerManager *manager, NSDictionary *change) {
        if (manager != NULL) {
            ENResturantDataStatus dataStatus = manager.fetchStatus;
            switch (dataStatus) {
                case ENResturantDataStatusFetchingRestaurant:
                    self.loadingInfo.text = @"Finding the best restaurant";
                    break;
                case ENResturantDataStatusFetchedRestaurant:
                    [self showRestaurants];
                    break;
                case ENResturantDataStatusError:
                    self.loadingInfo.text = @"Failed to get restaurant list";
                    break;
                    
                default:
                    break;
            }
        }
    }];
    
    [self.KVOController observe:[AFNetworkReachabilityManager sharedManager] keyPath:@keypath([AFNetworkReachabilityManager sharedManager], networkReachabilityStatus) options:NSKeyValueObservingOptionNew block:^(id observer, AFNetworkReachabilityManager *manager, NSDictionary *change) {
        if (manager != NULL) {
            AFNetworkReachabilityStatus status = manager.networkReachabilityStatus;
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    self.loadingInfo.text = @"Determining connecting";
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    self.loadingInfo.text = @"No internet connection";
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    self.loadingInfo.text = @"Connected";
                    break;
                    
                default:
                    break;
            }
        }
    }];
    
    
    if ([[ENUtil myUUID] isEqualToString:@"44D08937-F5F8-4688-A198-B4F57196B1A6"]) {
        //change to red
        DDLogInfo(@"Set special color");
        [self.likeButton setTitleColor:[UIColor colorWithRed:0.988 green:0.643 blue:0.647 alpha:1.000] forState:UIControlStateNormal];
    }
    
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        @strongify(self);
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            if (success) {
                _restaurants = response.mutableCopy;
                [self showRestaurants];
            }
        }];
    }];
}

- (void)showRestaurants{
    
    self.loadingInfo.text = @"";
    //stop loading
    [self.loading stopAnimating];
    //read list
    //    [self getRestaurants];
    
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

#pragma mark - Guesture actions

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentRestaurant.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(UIPanGestureRecognizer *)direction {
    CGPoint velocity = [direction velocityInView:self.view];
    if (velocity.x <0) {
        NSLog(@"You swipt left %@.", self.currentRestaurant.name);
    } else {
        NSLog(@"You swipt right %@.", self.currentRestaurant.name);
    }
    
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

//- (NSMutableArray *)getRestaurants {
// It would be trivial to download these from a web service
// as needed, but for the purposes of this sample app we'll
// simply store them in memory.
//    _restaurants = [ENServerManager sharedInstance].restaurants;

//    return _restaurants;
//}

- (RestaurantView *)popResuturantViewWithFrame:(CGRect)frame {
    if ([self.restaurants count] == 0) {
        return nil;
    }
    RestaurantView* card = [RestaurantView loadView];
    card.frame = frame;
    card.restaurant = self.restaurants.firstObject;
    //    [self.restaurants addObject:self.restaurants.firstObject];
	[self.restaurants removeObjectAtIndex:0];
	return card;
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - View Contruction

- (CGRect)frontCardViewFrame {
    CGRect frame = self.cardFrame.frame;
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
    if (self.frontCardView.restaurant) {
        
        [[[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Don't like this restaurant? We will never show similar ones again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Dislike", nil] show];
    }
}

// Programmatically "likes" the front card view.
- (IBAction)like:(id)sender{
    [ENUtil showWatingHUB];
    Restaurant *restaurant = self.frontCardView.restaurant;
    [[self serverManager] selectRestaurant:restaurant like:1 completion:^(NSError *error) {
        if (!error) {
            [ENUtil showSuccessHUBWithString:@"Liked"];
            DDLogInfo(@"Sucessfully liked restaurant: %@", restaurant.name);
        }
        else {
            [ENUtil showFailureHUBWithString:@"Server error, try again later."];
        }
    }];
}

- (IBAction)refresh:(id)sender {
    //    [ENServerManager sharedInstance].currentLocation = nil;
    //    [ENServerManager sharedInstance].status = IsReachable;
    //    [self.restaurants removeAllObjects];
    self.restaurants = nil;
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    });
    [self.loading startAnimating];
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            _restaurants = response.mutableCopy;
            if (!success){
                NSString *str = [NSString stringWithFormat:@"Failed to get restaurant with error: %@", error];
                ENAlert(str);
                NSLog(@"%@", str);
            } else {
                [self showRestaurants];
            }
        }];
    } forece:YES];
}

- (IBAction)more:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Refresh", @"Profile", @"About", nil];
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}


#pragma mark - UIDynamics
- (void)showCard:(UIView *)card fromTopTo:(CGRect)frame{
    //just get shit done
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
        card.frame = frame;
    } completion:^(BOOL finished) {
        DDLogVerbose(@"Show card animation finished");
    }];
}

- (void)dismissCard:(UIView *)card withVelocity:(CGPoint)velocity{
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = card.frame;
        frame.origin.y -= 1000;
        card.frame = frame;
    } completion:^(BOOL finished) {
        DDLogVerbose(@"Dismissed card animation finished");
    }];
}

#pragma mark - Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Refresh"]) {
        [self refresh:nil];
    } else if ([title isEqualToString:@"Profile"]){
        //push to preference
        ENProfileViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ENProfileViewController class])];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"About"]){
        [[[UIAlertView alloc] initWithTitle:@"About" message:@"EatNow v0.5" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Dislike"]) {
        Restaurant *restaurant = self.frontCardView.restaurant;
        [ENUtil showWatingHUB];
        [[self serverManager] selectRestaurant:restaurant like:-1 completion:^(NSError *error) {
            if (!error) {
                [ENUtil showSuccessHUBWithString:@"Disliked"];
                DDLogInfo(@"Sucessfully liked restaurant: %@", restaurant.name);
            }
            else {
                [ENUtil showFailureHUBWithString:@"Server error, try again later."];
            }
        }];
        
    }
}


#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[ENMapViewController class]]) {
        ENMapViewController *mapVC = (ENMapViewController *)segue.destinationViewController;
        mapVC.restaurant = self.frontCardView.restaurant;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (!self.frontCardView.restaurant) {
        return NO;
    }
    return YES;
}

@end
