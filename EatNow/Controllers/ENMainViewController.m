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
#import "ENRestaurant.h"
#import "ENServerManager.h"
#import "FBKVOController.h"
#import "ENProfileViewController.h"
#import "ENLocationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "extobjc.h"
#import "NSTimer+BlocksKit.h"
#import "ENHistoryViewController.h"
#import "ENUtil.h"
#import "UIView+Extend.h"
#import "ATConnect.h"
#import "ENRatingView.h"
#import "ENProfileViewController.h"


@interface ENMainViewController ()
//data
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;
//UIDynamics
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItem;
//gesture
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
//UI
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (nonatomic, strong) ENHistoryViewController *historyViewController;
//autolayout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailCardTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailCardLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyChildViewControllerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyChildViewControllerLeadingConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *mainViewButton;
@property (weak, nonatomic) IBOutlet UIButton *histodyDetailToHistoryButton;
@property (nonatomic, strong) NSTimer *showRestaurantCardTimer;
@end

@implementation ENMainViewController

#pragma mark - Accsessor
- (ENRestaurantViewController *)firstRestaurantViewController{
    return self.restaurantCards.firstObject;
}

- (void)setRestaurants:(NSMutableArray *)restaurants{
    if (restaurants.count > kMaxRestaurants) {
        DDLogInfo(@"Trunked restaurant list from %@ to %d", @(restaurants.count), kMaxRestaurants);
        restaurants = [restaurants objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,kMaxRestaurants)]].mutableCopy;
	}
	DDLogVerbose(@"%@", [restaurants valueForKey:@"name"]);
    _restaurants = restaurants;
}

- (void)setCurrentMode:(ENMainViewControllerMode)currentMode {
    _currentMode = currentMode;
    
    switch (_currentMode) {
        case ENMainViewControllerModeMain: {
            self.historyButton.hidden = NO;
            self.reloadButton.hidden = NO;
            self.closeButton.hidden = YES;
            self.mainViewButton.hidden = YES;
            self.histodyDetailToHistoryButton.hidden = YES;
            break;
        }
        case ENMainViewControllerModeDetail: {
            self.historyButton.hidden = YES;
            self.reloadButton.hidden = YES;
            self.closeButton.hidden = NO;
            self.mainViewButton.hidden = YES;
            self.histodyDetailToHistoryButton.hidden = YES;
            break;
        }
        case ENMainViewControllerModeHistory: {
            self.historyButton.hidden = YES;
            self.reloadButton.hidden = YES;
            self.closeButton.hidden = YES;
            self.mainViewButton.hidden = NO;
            self.histodyDetailToHistoryButton.hidden = YES;
            break;
        }
        case ENMainViewControllerModeHistoryDetail :{
            self.historyButton.hidden = YES;
            self.reloadButton.hidden = YES;
            self.closeButton.hidden = YES;
            self.mainViewButton.hidden = YES;
            self.histodyDetailToHistoryButton.hidden = NO;
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - UIViewController Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [ENLocationManager shared];
    self.serverManager = [ENServerManager shared];
    self.restaurantCards = [NSMutableArray array];
    self.currentMode = ENMainViewControllerModeMain;
    
    //fetch user first
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        if (user) {
            NSParameterAssert([ENServerManager shared].userRating);
            NSParameterAssert([ENServerManager shared].history);
            DDLogVerbose(@"Got user history and rating data");
        }
    }];
    
    //Dynamics
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.detailCardContainer];
    self.gravity = [[UIGravityBehavior alloc] init];
    self.gravity.gravityDirection = CGVectorMake(0, 10);
    [self.animator addBehavior:_gravity];
    self.dynamicItem = [[UIDynamicItemBehavior alloc] init];
    self.dynamicItem.density = 1.0;
    [self.animator addBehavior:_dynamicItem];
    
    [self.KVOController observe:self.locationManager keyPath:@keypath(self.locationManager, locationStatus) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, ENLocationManager *manager, NSDictionary *change) {
        if (self.restaurantCards.count)  return;
        if (manager != NULL) {
            ENLocationStatus locationStatus = manager.locationStatus;
            switch (locationStatus) {
                case ENLocationStatusGettingLocation:
                    self.loadingInfo.text = @"";
                    break;
                case ENLocationStatusGotLocation:
                    self.loadingInfo.text = @"";
                    break;
				case ENLocationStatusError:
					self.loadingInfo.text = @"Failed to get location";
                default:
                    break;
            }
        }
    }];
    
    //server status
    [self.KVOController observe:self.serverManager keyPath:@keypath(self.serverManager, fetchStatus) options:NSKeyValueObservingOptionNew block:^(id observer, ENServerManager *manager, NSDictionary *change) {
        if (self.restaurantCards.count)  return;
        if (manager != NULL) {
            ENResturantDataStatus dataStatus = manager.fetchStatus;
            switch (dataStatus) {
                case ENResturantDataStatusFetchingRestaurant:
                    self.loadingInfo.text = @"";
                    break;
                case ENResturantDataStatusFetchedRestaurant:
                    self.loadingInfo.text = @"";
                    break;
                case ENResturantDataStatusError:
					self.loadingInfo.text = @"Failed to get restaurant list";
					ENLogError(@"Server error");
                    break;
                default:
                    break;
            }
        }
    }];
    
	//Internet connection
	[[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		switch (status) {
			case AFNetworkReachabilityStatusUnknown:
				self.loadingInfo.text = @"";
				break;
			case AFNetworkReachabilityStatusNotReachable:
				self.loadingInfo.text = @"No internet connection";
				ENLogError(@"No internet connection");
				break;
			case AFNetworkReachabilityStatusReachableViaWWAN:
			case AFNetworkReachabilityStatusReachableViaWiFi:
				self.loadingInfo.text = @"";
				break;
				
			default://
				break;
		}
	}];
	[[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self.KVOController observe:self keyPaths:@[@keypath(self.isReloading), @keypath(self.isDismissingCard), @keypath(self.isShowingCards)] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if (!self.isReloading && !self.isShowingCards && !self.isDismissingCard) {
            self.reloadButton.enabled = YES;
            self.loadingIndicator.alpha = 0;
            DDLogInfo(@"show loding indicator :%@ %@ %@", @(self.isReloading), @(self.isShowingCards), @(self.isDismissingCard));
        }
        else {
            self.reloadButton.enabled = NO;
            self.loadingIndicator.alpha = 1;
            DDLogInfo(@"hide loding indicator :%@ %@ %@", @(self.isReloading), @(self.isShowingCards), @(self.isDismissingCard));
        }
    }];
    
    self.showRestaurantCardTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onShowRestaurantTimer:) userInfo:nil repeats:YES];
    
    //review if needed
    [[NSNotificationCenter defaultCenter] addObserverForName:kHistroyUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
        DDLogVerbose(@"History did update");
        //TODO: start displaying review card
    }];
    
    //load restaurants from server
    [self searchNewRestaurantsForced:NO completion:^(NSArray *response, NSError *error) {
        self.needShowRestaurant = YES;
    }];
    
    self.cardView.backgroundColor = [UIColor clearColor];
    self.detailCardContainer.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	//loading gif
	NSArray *images = @[[UIImage imageNamed:@"eat-now-loading-indicator-1"],
						[UIImage imageNamed:@"eat-now-loading-indicator-2"],
						[UIImage imageNamed:@"eat-now-loading-indicator-3"],
						[UIImage imageNamed:@"eat-now-loading-indicator-4"],
						[UIImage imageNamed:@"eat-now-loading-indicator-5"],
						[UIImage imageNamed:@"eat-now-loading-indicator-6"]];
	self.loadingIndicator.animationImages = images;
	self.loadingIndicator.animationDuration = 1.2;
    [self.loadingIndicator startAnimating];
	
	//background
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	[bluredEffectView setFrame:self.view.frame];
	[self.view insertSubview:bluredEffectView aboveSubview:self.background];
    
	[[NSNotificationCenter defaultCenter] addObserverForName:kRestaurantViewImageChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
		if (note.object == self.firstRestaurantViewController) {
			[self setBackgroundImage:note.userInfo[@"image"]];
		}
	}];
    
}

#pragma mark - IBActioning
- (IBAction)onDebugButton:(id)sender {
#ifdef DEBUG
    ENProfileViewController *profileVC = [[ENProfileViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
    [self presentViewController:navVC animated:YES completion:nil];
#else
    [[ATConnect sharedConnection] presentMessageCenterFromViewController:self withCustomData:@{@"ID":[ENServerManager shared].myID}];
#endif
}

- (IBAction)onHistoryButton:(id)sender {
    self.currentMode = ENMainViewControllerModeHistory;
    
    [self toggleHistoryView];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (IBAction)onCloseButton:(id)sender {
    [self toggleCardDetails];
}

- (IBAction)onReloadButton:(id)sender {
    if (self.isShowingCards) {
        DDLogInfo(@"showing cards, ignore reload button");
        return;
    }
    NSLog(@"reload button clicked");
    NSParameterAssert(!self.isReloading);
    NSParameterAssert(!self.isShowingCards);
    NSParameterAssert(!self.isDismissingCard);
    self.isReloading = YES;
    self.isDismissingCard = YES;
    self.needShowRestaurant = YES;
    
    self.restaurants = nil;
    
    if (self.restaurantCards.count == 0) {
        self.isDismissingCard = NO;
    }
    
    //dismissing with animation
    for (int i = 0; i < self.restaurantCards.count && i <= kMaxCardsToAnimate; i++) {
        float delay = i * 0.1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint v = CGPointMake(50.0f - arc4random_uniform(100), 0);
            [self dismissFrontCardWithVelocity:v completion:^(NSArray *leftcards) {
            }];
            
            if (i == kMaxCardsToAnimate || self.restaurantCards.count - 1) {
                self.isDismissingCard = NO;
                
                //dismiss the rest of the cards,
                // note that dismissFrontCardWithVelocity mutated self.restaurantCards
                for (int i = 0; i < self.restaurantCards.count; i++) {
                    ENRestaurantViewController *card = self.restaurantCards[i];
                    DDLogInfo(@"Dismissing card %@", card.restaurant.name);
                    [self.restaurantCards removeObjectAtIndex:i];
                    [card.view removeFromSuperview];
                    [card removeFromParentViewController];
                }
            }
        });
    }

    //search for new
    [self searchNewRestaurantsForced:YES completion:^(NSArray *response, NSError *error) {
        self.isReloading = NO;
    }];

}

- (IBAction)onHistoryToMainViewButton:(id)sender {
    self.currentMode = ENMainViewControllerModeMain;
    [self toggleHistoryView];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (IBAction)onHistoryDetailToHistoryButton:(id)sender {
    self.currentMode = ENMainViewControllerModeHistoryDetail;
    
    [self.historyViewController closeRestaurantView];
}
#pragma mark - Main methods

- (void)searchNewRestaurantsForced:(BOOL)force completion:(void (^)(NSArray *response, NSError *error))block {
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        @strongify(self);
        if (location) {
            [self.serverManager searchRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
                @strongify(self);
                if (success) {
                    self.restaurants = response.mutableCopy;
                }
                
                block(response, error);
            }];
        }
    } forece:force];
}

- (void)onShowRestaurantTimer:(id)sender {
    /**
     *  Only show all cards when need show restaurant flag is set
     *  and reloading finished
     *  and cards are all dismissed.
     */
    if (self.needShowRestaurant && !self.isReloading && !self.isDismissingCard && !self.isShowingCards) {
        self.needShowRestaurant = NO;
        [self showAllRestaurantCards];
    }
}

- (void)showAllRestaurantCards{
    NSParameterAssert(!self.isReloading);
    self.loadingInfo.text = @"";
    
    if (self.restaurantCards.count > 0) {
        DDLogWarn(@"=== Already have cards, skip showing restaurant");
        return;
    }
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to show, skip showing restaurants");
        return;
    }
    
    self.isShowingCards = YES;
    // Display cards animated
    NSUInteger restaurantCount = _restaurants.count;
    for (NSInteger i = 1; i <= restaurantCount; i++) {
        //insert card
        ENRestaurantViewController *restaurantViewController = [self popResuturantViewWithFrame:[self initialCardFrame]];
        restaurantViewController.view.hidden = YES;
        if (i==1) {
            DDLogVerbose(@"Poping %@th card: %@", @(i), restaurantViewController.restaurant.name);
            [self addChildViewController:restaurantViewController];
            [self.detailCardContainer addSubview:restaurantViewController.view];
            [restaurantViewController.view addGestureRecognizer:self.panGesture];
            [restaurantViewController.info addGestureRecognizer:self.tapGesture];
            [restaurantViewController didChangedToFrontCard];
        }
        else{
            DDLogVerbose(@"Poping %@th card: %@", @(i), restaurantViewController.restaurant.name);
            //insert behind previous card
            ENRestaurantViewController *previousCard = self.restaurantCards[i-2];
            NSParameterAssert(previousCard.view.superview);
            [self.detailCardContainer insertSubview:restaurantViewController.view belowSubview:previousCard.view];
        }
        
        //animate
        if (i <= kMaxCardsToAnimate){
            //animate
            float delay = (kMaxCardsToAnimate - i) * 0.3;
            DDLogVerbose(@"Delay %f sec for %ldth card", delay, (long)i);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                restaurantViewController.view.hidden = NO;
                [self snapCardToCenter:restaurantViewController];
                if (i == kMaxCardsToAnimate || i == restaurantCount) {
                    //stop loading
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kMaxCardsToAnimate) * 0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.isShowingCards = NO;
                        [self setNeedShowRestaurant:NO];
                    });
                }
            });
        }
        else {
            float delay = kMaxCardsToAnimate * 0.2;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                restaurantViewController.view.frame = [self cardViewFrame];
                restaurantViewController.view.hidden = NO;
            });
        }
    }
}

- (void)dismissFrontCardWithVelocity:(CGPoint)velocity completion:(void (^)(NSArray *leftcards))completion {
    if (self.firstRestaurantViewController) {
        ENRestaurantViewController *firstRestaurantViewController = self.firstRestaurantViewController;
        //DDLogInfo(@"Dismiss card %@", frontCard.restaurant.name);
        //add dynamics
        [self.animator removeBehavior:firstRestaurantViewController.snap];
        [self.gravity addItem:firstRestaurantViewController.view];
        [self.dynamicItem addItem:firstRestaurantViewController.view];
        if (velocity.x) {
            [self.dynamicItem addLinearVelocity:velocity forItem:firstRestaurantViewController.view];
        }
        
        //remove front card from cards
        [self.restaurantCards removeObjectAtIndex:0];
        
        //add pan gesture to next
        [firstRestaurantViewController.view removeGestureRecognizer:self.panGesture];
        [firstRestaurantViewController.info removeGestureRecognizer:self.tapGesture];
        [self.firstRestaurantViewController.view addGestureRecognizer:self.panGesture];
        [self.firstRestaurantViewController.info addGestureRecognizer:self.tapGesture];
        
        //notify next card
        [self.firstRestaurantViewController didChangedToFrontCard];
        
        //delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                firstRestaurantViewController.view.alpha = 0;
            } completion:^(BOOL finished) {
                [_gravity removeItem:firstRestaurantViewController.view];
                [_dynamicItem removeItem:firstRestaurantViewController.view];
                [firstRestaurantViewController.view removeFromSuperview];
                completion(self.restaurantCards);
            }];
        });
    }
}

- (void)toggleCardDetails{
    [_animator removeBehavior:self.firstRestaurantViewController.snap];
    //open first card
    //TODO? might use current mode for switcing
    if (self.firstRestaurantViewController.status == ENRestaurantViewStatusCard) {
        [self.firstRestaurantViewController switchToStatus:ENRestaurantViewStatusDetail withFrame:self.detailCardContainer.bounds animated:YES completion:nil];
        [self.firstRestaurantViewController.view removeGestureRecognizer:self.panGesture];
        
        self.currentMode = ENMainViewControllerModeDetail;
    }
    //close first card
    else {
        [self.firstRestaurantViewController switchToStatus:ENRestaurantViewStatusCard withFrame:self.cardViewFrame animated:YES completion:nil];
        [self.firstRestaurantViewController.view addGestureRecognizer:self.panGesture];
        
        self.currentMode = ENMainViewControllerModeMain;
    }
}

- (void)toggleHistoryView {
    if (self.currentMode == ENMainViewControllerModeHistory) {
        //show
        self.historyChildViewControllerLeadingConstraint.constant = 0;
        self.historyChildViewControllerTrailingConstraint.constant = 0;
        self.detailCardLeadingConstraint.constant = self.view.frame.size.width;
        self.detailCardTrailingConstraint.constant = -self.view.frame.size.width;
        [self.historyViewController loadData];
        self.historyViewController.mainView = self.view;
    }
    else {
        //close
        self.historyChildViewControllerLeadingConstraint.constant = -self.view.frame.size.width;
        self.historyChildViewControllerTrailingConstraint.constant = self.view.frame.size.width;
        self.detailCardLeadingConstraint.constant = 0;
        self.detailCardTrailingConstraint.constant = 0;
        self.historyViewController.mainView = nil;
        if (self.historyViewController.restaurantViewController) {
            [self.historyViewController closeRestaurantView];
        }
    }
    
    [super updateViewConstraints];
}

#pragma mark - Guesture actions
- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture {
    [self toggleCardDetails];
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint locInView = [gesture locationInView:self.detailCardContainer];
    CGPoint locInCard = [gesture locationInView:self.firstRestaurantViewController.view];
    ENRestaurantViewController *firstRestauantViewController= self.firstRestaurantViewController;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //attachment behavior
        [_animator removeBehavior:_attachment];
        UIOffset offset = UIOffsetMake(locInCard.x - firstRestauantViewController.view.bounds.size.width/2, locInCard.y - firstRestauantViewController.view.bounds.size.height/2);
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:firstRestauantViewController.view offsetFromCenter:offset attachedToAnchor:locInView];
        [_animator addBehavior:_attachment];
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
            [self dismissFrontCardWithVelocity:velocity completion:^(NSArray *leftcards) {
                if (leftcards.count == 0) {
                    //show loading info
                    self.loadingInfo.text = @"You have dismissed all cards.";
                }
            }];
        }
        else {
            [self snapCardToCenter:firstRestauantViewController];
        }
    }
}

// This is called when a user didn't fully swipe left or right.
- (void)snapCardToCenter:(ENRestaurantViewController *)card {
    NSParameterAssert(card);
    if (card.snap) {
        [self.animator removeBehavior:card.snap];
    }
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:card.view snapToPoint:self.cardView.center];
    
    snap.damping = 0.98;
    [self.animator addBehavior:snap];
    card.snap = snap;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.animator removeBehavior:card.snap];
    });
}

#pragma mark - Internal Methods
//data methods, should not add view related codes
//Pop start from the first one
- (ENRestaurantViewController *)popResuturantViewWithFrame:(CGRect)frame {
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to pop");
        return nil;
    }
    ENRestaurantViewController* card = [ENRestaurantViewController viewController];
    card.status = ENRestaurantViewStatusCard;
    card.view.frame = frame;
    card.restaurant = self.restaurants.firstObject;
    [card updateLayout];
	[self.restaurants removeObjectAtIndex:0];
    [self.restaurantCards addObject:card];
    
    return card;
}

- (void)setBackgroundImage:(UIImage *)image{
    static NSTimer *BGTimer;
    [BGTimer invalidate];
    BGTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        //duplicate view
        UIView *imageViewCopy = [self.background snapshotViewAfterScreenUpdates:NO];
        self.background.image = image;
        [self.view insertSubview:imageViewCopy aboveSubview:self.background];
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageViewCopy.alpha = 0;
        } completion:^(BOOL finished) {
            [imageViewCopy removeFromSuperview];
        }];
    } repeats:NO];
}

#pragma mark - Card frame
- (CGRect)initialCardFrame{
    CGRect frame = self.cardView.frame;
    frame.origin.x = arc4random_uniform(400) - 200.0f;
    frame.origin.y -= [UIScreen mainScreen].bounds.size.height/2 + frame.size.height;
    return frame;
}

- (CGRect)cardViewFrame {
    CGRect frame = self.cardView.frame;
    return frame;
}

- (CGRect)detailViewFrame{
    CGRect frame = self.detailCardContainer.frame;
    return frame;
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"embedHistorySegue"]) {
        self.historyViewController = segue.destinationViewController;
        self.historyViewController.mainViewController = self;
    }
}
@end
