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

#import "ENMainViewController.h"
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
#import "NSTimer+BlocksKit.h"

//static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
//static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ENMainViewController ()
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, assign) BOOL isDismissingCard;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItem;
@end

@implementation ENMainViewController

#pragma mark - Object Lifecycle

#pragma mark - Accsessor
- (ENRestaurantView *)frontCardView{
    return self.restaurantCards.firstObject;
}

- (void)setRestaurants:(NSMutableArray *)restaurants{
    if (restaurants.count > kMaxRestaurants) {
        DDLogInfo(@"Trunked restaurant list from %@ to %d", @(restaurants.count), kMaxRestaurants);
        restaurants = [restaurants objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,kMaxRestaurants)]].mutableCopy;
    }
    _restaurants = restaurants;
}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [ENLocationManager new];
    self.serverManager = [ENServerManager new];
    self.restaurantCards = [NSMutableArray array];
    
    //Dynamics
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc] init];
    self.gravity.gravityDirection = CGVectorMake(0, 10);
    [self.animator addBehavior:_gravity];
    self.dynamicItem = [[UIDynamicItemBehavior alloc] init];
    self.dynamicItem.density = 1.0;
    [self.animator addBehavior:_dynamicItem];
    
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
                    //[self showAllRestaurantCards];
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
    
    [self searchNewRestaurantsForced:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cardFrame.backgroundColor = [UIColor clearColor];
    self.detailFrame.backgroundColor = [UIColor clearColor];
}

#pragma mark - Main methods
- (void)searchNewRestaurantsForced:(BOOL)force{
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        @strongify(self);
        [self.serverManager getRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
            if (success) {
                self.restaurants = response.mutableCopy;
                [self showAllRestaurantCards];
            }
        }];
    } forece:force];
}

- (void)showAllRestaurantCards{
    
    self.loadingInfo.text = @"";
    //stop loading
    [self.loading stopAnimating];
    //read list
    //    [self getRestaurants];
    
    if (self.restaurantCards.count > 0) {
        DDLogWarn(@"=== Already have cards, skip showing restaurant");
        return;
    }
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to show, skip show all restaurants");
        return;
    }
    if (_isDismissingCard) {
        DDLogWarn(@"Dismissing in progress, skip show restaurant!");
        return;
    }
    // Display cards animated
    for (NSInteger i = _restaurants.count; i > 0; i--) {
        ENRestaurantView *card;
        if (i > kMaxCardsToAnimate){
            card = [self popResuturantViewWithFrame:self.cardViewFrame];
        } else {
            card = [self popResuturantViewWithFrame:self.initialCardFrame];
        }
        //add pan gesture
        if (i == 1) {
            [card addGestureRecognizer:self.panGesture];
            [card didChangedToFrontCard];
        }
        float delay = i * 0.1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"Poping %@th card", @(i));
            NSParameterAssert(card);
            if (i>=2) {
                UIView *lastCard = self.restaurantCards[i-2];
                NSParameterAssert(lastCard.superview);
                [self.view insertSubview:card belowSubview:lastCard];
            }else{
                [self.view addSubview:card];
            }
            if (i <= kMaxCardsToAnimate) {
                //snap to center
                [self snapCardToCenter:card];
            }
        });
    }
}



- (void)dismissFrontCard{
    if (self.frontCardView) {
        ENRestaurantView *frontCard = self.frontCardView;
        DDLogInfo(@"Dismiss card %@", frontCard.restaurant.name);
        //remove snap
        if (frontCard.snap) {
            [_animator removeBehavior:frontCard.snap];
        }
        //add gravity
        [_gravity addItem:frontCard];
        
        //remove front card from cards
        [self.restaurantCards removeObjectAtIndex:0];
        
        //add pan gesture to next
        [frontCard removeGestureRecognizer:self.panGesture];
        [self.frontCardView addGestureRecognizer:self.panGesture];
        
        //notify next card
        [self.frontCardView didChangedToFrontCard];
        
        //delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                frontCard.alpha = 0;
            } completion:^(BOOL finished) {
                [_gravity removeItem:frontCard];
                [_dynamicItem removeItem:frontCard];
                [frontCard removeFromSuperview];
            }];
        });
    }
}

- (void)toggleCardDetails{
    
    if (self.frontCardView.status == ENRestaurantViewStatusCard) {
        [self.frontCardView switchToStatus:ENRestaurantViewStatusDetail withFrame:self.detailViewFrame];
        [self.frontCardView removeGestureRecognizer:self.panGesture];
    } else {
        [self.frontCardView switchToStatus:ENRestaurantViewStatusCard withFrame:self.cardViewFrame];
        [self.frontCardView addGestureRecognizer:self.panGesture];
    }
    
}

#pragma mark - Guesture actions
- (IBAction)gestureHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint locInView = [gesture locationInView:self.view];
    CGPoint locInCard = [gesture locationInView:self.frontCardView];
    ENRestaurantView *card = self.frontCardView;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (card.snap) {
            [_animator removeBehavior:card.snap];
        }
        //attachment behavior
        [_animator removeBehavior:_attachment];
        UIOffset offset = UIOffsetMake(locInCard.x - card.bounds.size.width/2, locInCard.y - card.bounds.size.height/2);
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:card offsetFromCenter:offset attachedToAnchor:locInView];
        [_animator addBehavior:_attachment];
        //attachment.frequency = 0;
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        _attachment.anchorPoint = locInView;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
        [_animator removeBehavior:_attachment];
        CGPoint translation = [gesture translationInView:self.view];
        if (sqrtf(pow(translation.x, 2) + pow(translation.y, 2)) > 50) {
            //add dynamic item behavior
            CGPoint velocity = [gesture velocityInView:self.view];
            [_dynamicItem addItem:card];
            [_dynamicItem addLinearVelocity:velocity forItem:card];
            
            [self dismissFrontCard];
            //assign pan gesture to next card
            [self.frontCardView addGestureRecognizer:self.panGesture];
        }
        else {
            [self snapCardToCenter:card];
        }
    }
}

// This is called when a user didn't fully swipe left or right.
- (void)snapCardToCenter:(ENRestaurantView *)card {
    NSParameterAssert(card);
    //DDLogInfo(@"You couldn't decide on %@.", self.frontCardView.restaurant.name);
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:card snapToPoint:self.cardFrame.center];
    [_animator addBehavior:snap];
    card.snap = snap;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_animator removeBehavior:snap];
    });
}

#pragma mark - Internal Methods
//data methods, should not add UI codes
//Pop start from the first one
- (ENRestaurantView *)popResuturantViewWithFrame:(CGRect)frame {
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to pop");
        return nil;
    }
    ENRestaurantView* card = [ENRestaurantView loadView];
    NSParameterAssert(card);
    card.frame = frame;
    card.restaurant = self.restaurants.firstObject;
	[self.restaurants removeObjectAtIndex:0];
    [self.restaurantCards insertObject:card atIndex:0];
    //set background iamge
	return card;
}

- (void)setBackgroundImage:(UIImage *)image{
    if (_animator.isRunning) {
        //delay
        DDLogInfo(@"Animator is running, delay background image setting");
        static NSTimer* backgroundFadeDelayTimer;
        [backgroundFadeDelayTimer invalidate];
        backgroundFadeDelayTimer = [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
            [self setBackgroundImage:image];
        } repeats:NO];
    }else {
        UIImage *blured = image.bluredImage;
        
        //duplicate view
        UIView *imageViewCopy = [self.background snapshotViewAfterScreenUpdates:NO];
        [self.view insertSubview:imageViewCopy aboveSubview:self.background];
        
        [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.background.image = blured;
            imageViewCopy.alpha = 0;
        } completion:^(BOOL finished) {
            [imageViewCopy removeFromSuperview];
        }];
    }
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Card frame
- (CGRect)initialCardFrame{
    CGRect frame = self.cardFrame.frame;
    frame.origin.x = arc4random_uniform(400) - 200.0f;
    frame.origin.y -= [UIScreen mainScreen].bounds.size.height/2 + frame.size.height/2 - arc4random_uniform(200);
    DDLogDebug(@"Frame x: %@", @(frame.origin.x));
    return frame;
}

- (CGRect)cardViewFrame {
    CGRect frame = self.cardFrame.frame;
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
    if (_isDismissingCard) {
        DDLogWarn(@"Already dismissing card!");
        return;
    }
    _isDismissingCard = YES;
    //    [ENServerManager sharedInstance].currentLocation = nil;
    //    [ENServerManager sharedInstance].status = IsReachable;
    //    [self.restaurants removeAllObjects];
    self.restaurants = nil;
    for (NSUInteger i=self.restaurantCards.count; i > 0; i--) {
        if (i>kMaxCardsToAnimate) {
            ENRestaurantView *card = self.restaurantCards[i-1];
            DDLogInfo(@"Dismissing card %@", card.restaurant.name);
            [self.restaurantCards removeObjectAtIndex:i-1];
            [card removeFromSuperview];
        }else {
            float delay = i * 0.1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissFrontCard];
                if (i == kMaxCardsToAnimate) {
                    [self showAllRestaurantCards];
                }
            });
        }
    }
    float dismissDuration = MIN(_restaurantCards.count, kMaxRestaurants)*0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isDismissingCard = NO;
    });
    [self.loading startAnimating];
    [self searchNewRestaurantsForced:YES];
}

- (IBAction)showHistory:(id)sender{
    ENProfileViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ENProfileViewController class])];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)dismissAll:(id)sender {
    [self toggleCardDetails];
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
