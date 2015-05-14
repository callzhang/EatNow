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
#import "ENFeedbackViewController.h"
#import "NSDate+Extension.h"
#import "EnShapeView.h"
#import "NSError+EatNow.h"
#import "FBTweak.h"
#import "FBTweakStore.h"
#import "FBTweakInline.h"
#import "BlocksKit.h"


@interface ENMainViewController ()
//data
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) NSMutableArray *historyToReview;
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
@property (weak, nonatomic) IBOutlet UILabel *noRestaurantsLabel;
//control
@property (weak, nonatomic) IBOutlet UIImageView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *mainViewButton;
@property (weak, nonatomic) IBOutlet UIButton *histodyDetailToHistoryButton;
@property (weak, nonatomic) IBOutlet UIButton *consoleButton;
@property (weak, nonatomic) IBOutlet UIButton *closeMapButton;
@property (nonatomic, strong) NSTimer *showRestaurantCardTimer;
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) EnShapeView *dotFrameView;
@property (nonatomic, assign) BOOL showLocationRequestTime;
@end

@implementation ENMainViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accsessor
- (ENRestaurantViewController *)firstRestaurantViewController{
    return self.cardViews.firstObject;
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
            [self showControllers:@[self.historyButton, self.reloadButton]];
            break;
        }
        case ENMainViewControllerModeDetail: {
            [self showControllers:@[self.closeButton]];
            break;
        }
        case ENMainViewControllerModeHistory: {
            [self showControllers:@[self.mainViewButton]];
            break;
        }
        case ENMainViewControllerModeHistoryDetail :{
            [self showControllers:@[self.histodyDetailToHistoryButton]];
            break;
        }
        case ENMainViewControllerModeMap: {
            [self showControllers:@[self.closeMapButton]];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)showControllers:(NSArray *)controls animated:(BOOL)animated {
    [self showViews:controls inAllViews:@[self.historyButton, self.reloadButton, self.closeButton, self.mainViewButton, self.histodyDetailToHistoryButton, self.closeMapButton] animated:animated];
}

- (void)showControllers:(NSArray *)controls {
    [self showControllers:controls animated:YES];
}

- (void)showViews:(NSArray *)showViews inAllViews:(NSArray *)allViews animated:(BOOL)animated {
    NSArray *hideViews = [allViews bk_reject:^BOOL(id obj) {
        return [showViews containsObject:obj];
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [showViews bk_each:^(UIView *obj) {
                obj.alpha = 1.0f;
            }];
            
            [hideViews bk_each:^(UIView *obj) {
                obj.alpha = 0.0f;
            }];
        }];
    }
    else {
        [showViews bk_each:^(UIView *obj) {
            obj.alpha = 1.0f;
        }];
        
        [hideViews bk_each:^(UIView *obj) {
            obj.alpha = 0.0f;
        }];
    }
}

#pragma mark - UIViewController Lifecycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupDotFrameView];
    
    //tweak
    FBTweakBind(self, showScore, @"Card", @"Algorithm", @"Show score", NO);
    FBTweakBind(self, showFeedback, @"Main", @"Feedback", @"Show feedback", YES);
    FBTweakBind(self, showLocationRequestTime, @"Location", @"request", @"Show request time", YES);
    
    [self.KVOController observe:self keyPath:@keypath(self, showFeedback) options:NSKeyValueObservingOptionNew block:^(id observer, ENMainViewController *mainVC, NSDictionary *change) {
        if (mainVC.showFeedback) {
            self.consoleButton.hidden = NO;
        }else{
            self.consoleButton.hidden = YES;
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [ENLocationManager shared];
    self.serverManager = [ENServerManager shared];
    self.cardViews = [NSMutableArray array];
    [self showControllers:@[self.historyButton, self.reloadButton] animated:NO]; //disable animation
    self.currentMode = ENMainViewControllerModeMain;

    [self setupNoRestaurantStatus];
    
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
        if (self.cardViews.count)  return;
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
        if (self.cardViews.count)  return;
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
    
    
    
    [self.KVOController observe:self keyPaths:@[@keypath(self.isSearchingFromServer), @keypath(self.isDismissingCard), @keypath(self.isShowingCards)] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if (!self.isSearchingFromServer && !self.isShowingCards && !self.isDismissingCard) {
            self.reloadButton.enabled = YES;
            self.loadingIndicator.alpha = 0;
            //DDLogInfo(@"show loding indicator :%@ %@ %@", @(self.isSearchingFromServer), @(self.isShowingCards), @(self.isDismissingCard));
        }
        else {
            self.reloadButton.enabled = NO;
            self.loadingIndicator.alpha = 1;
            //DDLogInfo(@"hide loding indicator :%@ %@ %@", @(self.isSearchingFromServer), @(self.isShowingCards), @(self.isDismissingCard));
        }
    }];

    //history to review
    [[NSNotificationCenter defaultCenter] addObserverForName:kHistroyUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {

        self.historyToReview = [NSMutableArray array];

        for (NSDictionary *historyData in [ENServerManager shared].history) {

            NSString *dateStr = historyData[@"date"];
            NSDate *date = [NSDate dateFromISO1861:dateStr];
            BOOL reviewTimePassed = [[NSDate date] timeIntervalSinceDate:date] > kMaxSelectedRestaurantRetainTime;
#ifdef DEBUG
            reviewTimePassed = YES;
#endif
            BOOL needReview = [historyData[@"reviewed"] boolValue] == NO;

            if (reviewTimePassed && needReview) {
                [self.historyToReview addObject:historyData];
            }
        }
    }];
	
	//simple state machine
    self.showRestaurantCardTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onShowRestaurantTimer:) userInfo:nil repeats:YES];

    //load restaurants from server
    [self searchNewRestaurantsForced:NO completion:^(NSArray *response, NSError *error) {
        if (!error) {
            self.needShowRestaurant = YES;
        }
        
        //HACK: should remove error magic number
        if ([error.domain isEqualToString:kEatNowErrorDomain] && error.code == -1) {
            self.needShowRestaurant = NO;
        }
    }];
    
    self.cardView.backgroundColor = [UIColor clearColor];
    self.detailCardContainer.backgroundColor = [UIColor clearColor];
    
    if (self.restaurants.count == 0) {
        [self onReloadButton:nil];
    }
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
	
    if (!self.visualEffectView) {
        //background
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bluredEffectView setFrame:self.view.frame];
        [self.view insertSubview:bluredEffectView aboveSubview:self.background];
        self.visualEffectView = bluredEffectView;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRestauranntViewImageDidChangeNotification:) name:kRestaurantViewImageChangedNotification object:nil];
    
    //hide history view
    [self toggleHistoryView];
    
    [self setupDotFrameView];
}

- (void)onRestauranntViewImageDidChangeNotification:(NSNotification *)notification {
    if (notification.object == self.firstRestaurantViewController) {
        [self setBackgroundImage:notification.userInfo[@"image"]];
    }
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

- (IBAction)onCloseMapButton:(id)sender {
    [[self firstRestaurantViewController] closeMap];
    self.currentMode = ENMainViewControllerModeDetail;
}

- (IBAction)onReloadButton:(id)sender {
    [self hideNoRestaurantStatus];
    
    if (self.isShowingCards) {
        DDLogInfo(@"showing cards, ignore reload button");
        return;
    }
    NSLog(@"reload button clicked");
    NSParameterAssert(!self.isSearchingFromServer);
    NSParameterAssert(!self.isShowingCards);
    NSParameterAssert(!self.isDismissingCard);
    self.isSearchingFromServer = YES;
    self.isDismissingCard = YES;
    self.needShowRestaurant = YES;
    
    self.restaurants = nil;
    
    if (self.cardViews.count == 0) {
        self.isDismissingCard = NO;
    }
    
    //dismissing with animation
    for (int i = 0; i < self.cardViews.count && i <= kMaxCardsToAnimate; i++) {
        float delay = i * kCardShowInterval;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint v = CGPointMake(50.0f - arc4random_uniform(100), 0);
            [self dismissFrontCardWithVelocity:v completion:^(NSArray *leftcards) {
            }];
            
            if (i == kMaxCardsToAnimate || i == (self.cardViews.count - 1)) {
                self.isDismissingCard = NO;
                
                //dismiss the rest of the cards,
                // note that dismissFrontCardWithVelocity mutated self.restaurantCards
                for (int i = 0; i < self.cardViews.count; i++) {
                    ENRestaurantViewController *card = self.cardViews[i];
                    DDLogInfo(@"Dismissing card %@", card.restaurant.name);
                    [self.cardViews removeObjectAtIndex:i];
                    [card.view removeFromSuperview];
                    [card removeFromParentViewController];
                }
            }
        });
    }

    //search for new
    [self searchNewRestaurantsForced:YES completion:^(NSArray *response, NSError *error) {
        self.isSearchingFromServer = NO;
        
        //HACK: should remove error magic number
        if ([error.domain isEqualToString:kEatNowErrorDomain] && error.code == -1) {
            self.needShowRestaurant = NO;
        }
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
    NSDate *start = [NSDate date];
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location, INTULocationAccuracy achievedAccuracy, ENLocationStatus status) {
        @strongify(self);
        if (self.showLocationRequestTime) {
            NSString *str = [NSString stringWithFormat:@"It took %.0fs to get location", [[NSDate date] timeIntervalSinceDate:start]];
            [ENUtil showText:str];
        }
        if (location) {
            [self.serverManager searchRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
                @strongify(self);
                if (success) {
                    self.restaurants = response.mutableCopy;
//                    self.restaurants = [NSMutableArray array];
                    if (self.restaurants.count == 0) {
                        [self showNoRestaurantStatus];
                    }
                }
                
                block(response, error);
            }];
        }
        else {
            NSError *error = [NSError errorWithDomain:kEatNowErrorDomain code:-1 userInfo:nil];
            block(nil, error);
        }
    } forece:force];
}

- (void)onShowRestaurantTimer:(id)sender {
    /**
     *  Only show all cards when need show restaurant flag is set
     *  and reloading finished
     *  and cards are all dismissed.
     */
    if (self.needShowRestaurant && !self.isSearchingFromServer && !self.isDismissingCard && !self.isShowingCards) {
        self.needShowRestaurant = NO;
        [self showAllRestaurantCards];
    }
}

- (void)showAllRestaurantCards{
    NSParameterAssert(!self.isSearchingFromServer);
    self.loadingInfo.text = @"";
    
    if (self.cardViews.count > 0) {
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
    NSUInteger feedbackCount = self.historyToReview.count;
    NSUInteger totalCardCount = restaurantCount + feedbackCount;
    for (NSInteger i = 1; i <= totalCardCount; i++) {
        //insert card
        UIViewController<ENCardViewControllerProtocol> *card;
        if (self.historyToReview.count > 0) {
            ENFeedbackViewController *feedbackViewController = [self popFeedbackViewWithFrame:[self initialCardFrame]];
            card = feedbackViewController;
        }else{
            ENRestaurantViewController *restaurantViewController = [self popResuturantViewWithFrame:[self initialCardFrame]];
            card = restaurantViewController;
        }
        card.view.hidden = YES;


        if (i==1) {
			//DDLogVerbose(@"Poping %@th card: %@", @(i), restaurantViewController.restaurant.name);
            [self addChildViewController:card];
            [self.detailCardContainer addSubview:card.view];
            [card.view addGestureRecognizer:self.panGesture];
            if ([card isKindOfClass:[ENRestaurantViewController class]]) [[(ENRestaurantViewController *)card info] addGestureRecognizer:self.tapGesture];
            [card didChangedToFrontCard];
        }
        else{
			//DDLogVerbose(@"Poping %@th card: %@", @(i), restaurantViewController.restaurant.name);
            //insert behind previous card
            ENRestaurantViewController *previousCard = self.cardViews[i-2];
            NSParameterAssert(previousCard.view.superview);
            [self.detailCardContainer insertSubview:card.view belowSubview:previousCard.view];
        }
        
        //animate
        if (i <= kMaxCardsToAnimate){
            //animate
            float delay = (kMaxCardsToAnimate - i + 1) * kCardShowInterval - 0.02 * i;
            DDLogVerbose(@"Delay %f sec for %ldth card", delay, (long)i);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                card.view.hidden = NO;
                [self snapCardToCenter:card];
                DDLogVerbose(@"Animating %ldth card to center", (long)i);
            });
        }
        else {
            float delay = kMaxCardsToAnimate * kCardShowInterval + 2;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                card.view.frame = [self cardViewFrame];
                card.view.hidden = NO;
                DDLogVerbose(@"Showing %ldth card", (long)i);
            });
        }
        
        //finish
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kMaxRestaurants * kCardShowInterval + 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isShowingCards = NO;
            self.needShowRestaurant = NO;
        });
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
        [self.cardViews removeObjectAtIndex:0];
        
        //add pan gesture to next
        [firstRestaurantViewController.view removeGestureRecognizer:self.panGesture];
        if ([firstRestaurantViewController isKindOfClass:[ENRestaurantViewController class]]) {
            [firstRestaurantViewController.info removeGestureRecognizer:self.tapGesture];
        }
        [self.firstRestaurantViewController.view addGestureRecognizer:self.panGesture];
        if ([self.firstRestaurantViewController isKindOfClass:[ENRestaurantViewController class]]) {
            [self.firstRestaurantViewController.info addGestureRecognizer:self.tapGesture];
        }
        
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
                completion(self.cardViews);
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
    
    void (^clearShadowBlock)(ENRestaurantViewController *viewController) = ^(ENRestaurantViewController *viewController) {
        viewController.shadowView.hidden = YES;
    };
    
    ENRestaurantViewController *firstRestauantViewController= self.firstRestaurantViewController;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //attachment behavior
        [_animator removeBehavior:_attachment];
        UIOffset offset = UIOffsetMake(locInCard.x - firstRestauantViewController.view.bounds.size.width/2, locInCard.y - firstRestauantViewController.view.bounds.size.height/2);
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:firstRestauantViewController.view offsetFromCenter:offset attachedToAnchor:locInView];
        [_animator addBehavior:_attachment];
        firstRestauantViewController.shadowView.hidden = NO;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        _attachment.anchorPoint = locInView;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
        clearShadowBlock(firstRestauantViewController);
        [_animator removeBehavior:_attachment];
        CGPoint translation = [gesture translationInView:self.view];
        BOOL canSwipe = firstRestauantViewController.canSwipe;
        BOOL panDistanceLargeEnough = sqrtf(pow(translation.x, 2) + pow(translation.y, 2)) > 50;
        if (canSwipe && panDistanceLargeEnough) {
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
    else {
        clearShadowBlock(firstRestauantViewController);
    }
}

// This is called when a user didn't fully swipe left or right.
- (void)snapCardToCenter:(UIViewController<ENCardViewControllerProtocol> *)card {
    NSParameterAssert(card);
    if (card.snap) {\
        //skip if snap is already in place
        return;
        //[self.animator removeBehavior:card.snap];
    }
    if (!card.view.superview) {
        //skip if not in view
        return;
    }
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:card.view snapToPoint:self.cardView.center];
    
    snap.damping = 0.9;
    [self.animator addBehavior:snap];
    card.snap = snap;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.animator removeBehavior:card.snap];
//    });
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
    card.mainVC = self;
    card.view.frame = frame;
    card.restaurant = self.restaurants.firstObject;
    [card updateLayout];
	[self.restaurants removeObjectAtIndex:0];
    [self.cardViews addObject:card];
    
    return card;
}

- (ENFeedbackViewController *)popFeedbackViewWithFrame:(CGRect)frame {
    if (self.historyToReview.count == 0) {
        DDLogWarn(@"No feedback to pop");
        return nil;
    }
    NSDictionary *historyData = self.historyToReview.firstObject;
    ENFeedbackViewController *card = [ENFeedbackViewController viewController];
    card.history = historyData;
    card.mainViewController = self;
    card.view.frame = frame;
    [self.historyToReview removeObjectAtIndex:0];
    [self.cardViews addObject:card];

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

#pragma mark -
- (void)showNoRestaurantStatus {
    self.noRestaurantsLabel.hidden = NO;
}

- (void)hideNoRestaurantStatus {
    self.noRestaurantsLabel.hidden = YES;
}

- (void)setupNoRestaurantStatus {
    NSMutableAttributedString *text = [[[NSAttributedString alloc] initWithString:@"Oops.\n\n It looks like there are no more restaurants nearby. :(" attributes:@{}] mutableCopy];
    [text addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:28]} range:NSMakeRange(0, 6)];
    [text addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans-Light" size:20]} range:NSMakeRange(6, text.length - 6)];
    self.noRestaurantsLabel.attributedText = text;
}

#pragma mark - 
- (void)setupDotFrameView {
    CGRect cardFrame = self.cardView.bounds;
    CGFloat shrink = 2;
    cardFrame = CGRectMake(cardFrame.origin.x + shrink, cardFrame.origin.y + shrink, cardFrame.size.width - shrink*2, cardFrame.size.height - shrink*2);
    
    if (!self.dotFrameView) {
        CGFloat onePixel = 1.0 / [UIScreen mainScreen].scale;
        
        self.dotFrameView = [[EnShapeView alloc] init];
        
        self.dotFrameView.shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:cardFrame cornerRadius:16].CGPath;
        self.dotFrameView.shapeLayer.lineWidth = 1 * onePixel;
        self.dotFrameView.shapeLayer.lineCap = kCALineCapButt;
        self.dotFrameView.shapeLayer.lineDashPattern = @[@(1 * onePixel), @(5 * onePixel)];
        self.dotFrameView.shapeLayer.fillColor = nil;
        self.dotFrameView.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.cardView insertSubview:self.dotFrameView atIndex:2];
    }
    else {
        self.dotFrameView.shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:cardFrame cornerRadius:16].CGPath;
    }
}
@end
