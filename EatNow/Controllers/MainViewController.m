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
#import "ENProfileViewController.h"
#import "ENMapViewController.h"
#import "ENLocationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "extobjc.h"

//static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
//static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface MainViewController ()
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;
@property (weak, nonatomic) IBOutlet UIImageView *background;
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
                    [self showRestaurantCard];
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kRestaurantViewImageChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        if (note.object == self.frontCardView) {
            [self setBackgroundImage:note.userInfo[@"image"]];
        }
    }];
    
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        @strongify(self);
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            if (success) {
                _restaurants = response.mutableCopy;
                [self showRestaurantCard];
            }
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cardFrame.backgroundColor = [UIColor clearColor];
    self.detailFrame.backgroundColor = [UIColor clearColor];
}

- (void)showRestaurantCard{
    
    self.loadingInfo.text = @"";
    //stop loading
    [self.loading stopAnimating];
    //read list
    //    [self getRestaurants];
    
    if (self.frontCardView) {
        DDLogWarn(@"=== Front view already exists, skip showing restaurant");
        return;
    }
    // Display the front card
    if (self.backCardView) {
        self.frontCardView = self.backCardView;
        self.backCardView = nil;
    }else {
        self.frontCardView = [self popResuturantViewWithFrame:[self initialCardFrame]];
        [self.view addSubview:self.frontCardView];
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frontCardView.frame = [self cardViewFrame];
        } completion:^(BOOL finished) {
            //load back card
            self.backCardView = [self popResuturantViewWithFrame:[self initialCardFrame]];
            [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
            [UIView animateWithDuration:0.5 delay:0.2 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backCardView.frame = [self cardViewFrame];
            } completion:^(BOOL finished) {
                //
            }];
        }];
    }

}



- (void)dismissFrontCardwithVelocity:(CGPoint)velocity completion:(void (^)(void))block{
    UIView *card = self.frontCardView;
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = card.frame;
        frame.origin.y += [UIScreen mainScreen].bounds.size.height/2 + card.frame.size.height/2;
        card.frame = frame;
    } completion:^(BOOL finished) {
        DDLogVerbose(@"Dismissed card animation finished");
        [card removeFromSuperview];
        self.frontCardView = nil;
        if (block) {
            block();
        }
    }];
}

- (void)showDetail:(BOOL)show{
    
    if (show) {
        //transform
        //disable gesture
    } else {
        //transform
        //enable gesture
    }
}

#pragma mark - Guesture actions

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.frontCardView.restaurant.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view didSwipeWithDirection:(UIPanGestureRecognizer *)direction {
    CGPoint velocity = [direction velocityInView:self.view];
    if (velocity.x <0) {
        NSLog(@"You swipt left %@.", self.frontCardView.restaurant.name);
    } else {
        NSLog(@"You swipt right %@.", self.frontCardView.restaurant.name);
    }
    
    //dismiss the front view
    [self dismissFrontCardwithVelocity:velocity completion:^{
        //show card
        [self showRestaurantCard];
    }];
    
}

#pragma mark - Internal Methods
- (RestaurantView *)popResuturantViewWithFrame:(CGRect)frame {
    if ([self.restaurants count] == 0) {
        DDLogWarn(@"No restaurant to pop");
        return nil;
    }
    RestaurantView* card = [RestaurantView loadView];
    card.frame = frame;
    card.restaurant = self.restaurants.firstObject;
	[self.restaurants removeObjectAtIndex:0];
    
    //set background iamge
	return card;
}

- (void)setBackgroundImage:(UIImage *)image{
    UIImage *blured = image.bluredImage;
    
    //duplicate view
    UIView *imageViewCopy = [self.background snapshotViewAfterScreenUpdates:NO];
    [self.view insertSubview:imageViewCopy aboveSubview:self.background];
    
    [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.background.image = blured;
        imageViewCopy.alpha = 0;
    } completion:^(BOOL finished) {
        DDLogVerbose(@"Changed background image");
        [imageViewCopy removeFromSuperview];
    }];
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Card frame
- (CGRect)initialCardFrame{
    CGRect frame = self.cardFrame.frame;
    frame.origin.y -= [UIScreen mainScreen].bounds.size.height/2 + frame.size.height/2;
    return frame;
}

- (CGRect)cardViewFrame {
    CGRect frame = self.cardFrame.frame;
    return frame;
}

- (CGRect)dismissedCardFrame{
    CGRect frame = self.cardFrame.frame;
    frame.origin.y += [UIScreen mainScreen].bounds.size.height/2 + frame.size.height/2;
    return frame;
}

- (CGRect)detailViewFrame{
    CGRect frame = self.detailFrame.frame;
    return frame;
}



#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (IBAction)nope:(id)sender {
    if (self.frontCardView.restaurant) {
        [UIAlertView bk_showAlertViewWithTitle:@"Confirm" message:@"Don't like this restaurant? We will never show similar ones again." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Confirm"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
            if ([title isEqualToString:@"Confirm"]) {
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
        }];
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
    [self dismissFrontCardwithVelocity:CGPointMake(0, 0) completion:^{
        self.frontCardView = self.backCardView;
        self.backCardView = nil;
        [self dismissFrontCardwithVelocity:CGPointMake(0, 0) completion:^{
            //if animation finished before server return, the restaurants is nil, no new card will be loaded
            //if animation finished after, the earlier call to showRestaurantCard will fail, and this call will work
            [self showRestaurantCard];
        }];
    }];
    [self.loading startAnimating];
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            _restaurants = response.mutableCopy;
            if (!success){
                NSString *str = [NSString stringWithFormat:@"Failed to get restaurant with error: %@", error];
                ENAlert(str);
                NSLog(@"%@", str);
            } else {
                //KVO will refresh automatically
                //[self showRestaurantCard];
            }
        }];
    } forece:YES];
}

- (IBAction)showHistory:(id)sender{
    ENProfileViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ENProfileViewController class])];
    [self.navigationController pushViewController:vc animated:YES];
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
