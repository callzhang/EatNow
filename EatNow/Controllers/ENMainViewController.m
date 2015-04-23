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
#import "ENWebViewController.h"
#import "FBKVOController.h"
#import "ENProfileViewController.h"
#import "ENMapViewController.h"
#import "ENLocationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "extobjc.h"
#import "NSTimer+BlocksKit.h"
#import "ENHistoryViewController.h"
#import "ENUtil.h"
#import "UIView+Extend.h"
#import "ATConnect.h"
//#import "AnimatedGIFImageSerialization.h"

//static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
//static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailCardTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailCardLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyChildViewControllerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyChildViewControllerLeadingConstraint;
@property (nonatomic, assign) BOOL isHistoryShown;
@end

@implementation ENMainViewController

#pragma mark - Object Lifecycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark - Accsessor
- (ENRestaurantView *)frontCardView{
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

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [ENLocationManager shared];
    self.serverManager = [ENServerManager shared];
    self.restaurantCards = [NSMutableArray array];
    
    //fetch user first
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        if (user) {
            NSParameterAssert([ENServerManager shared].userRating);
            DDLogVerbose(@"Got user history and rating data");
        }
    }];
    
    //Dynamics
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.detailFrame];
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
                    //self.loadingInfo.text = @"Determining location";
                    self.loading.alpha = 1;
                    break;
                case ENLocationStatusGotLocation:
                    //self.loadingInfo.text = @"Got location";
                    self.loading.alpha = 1;
                    break;
				case ENLocationStatusError:
					self.loadingInfo.text = @"Failed to get location";
                    self.loading.alpha = 0;
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
                    //self.loadingInfo.text = @"Finding the best restaurant";
                    self.loading.alpha = 1;
                    break;
                case ENResturantDataStatusFetchedRestaurant:
                    self.loading.alpha = 1;
                    break;
                case ENResturantDataStatusError:
					self.loadingInfo.text = @"Failed to get restaurant list";
					self.loading.alpha = 0;
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
				//self.loadingInfo.text = @"Determining connecting";
                self.loading.alpha = 1;
				break;
			case AFNetworkReachabilityStatusNotReachable:
				self.loadingInfo.text = @"No internet connection";
				ENLogError(@"No internet connection");
				self.loading.alpha = 0;
				break;
			case AFNetworkReachabilityStatusReachableViaWWAN:
			case AFNetworkReachabilityStatusReachableViaWiFi:
				//self.loadingInfo.text = @"Connected";
				break;
				
			default://
				break;
		}
	}];
	[[AFNetworkReachabilityManager sharedManager] startMonitoring];
	
    
    //load restaurants from server
    [self searchNewRestaurantsForced:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cardFrame.backgroundColor = [UIColor clearColor];
    self.detailFrame.backgroundColor = [UIColor clearColor];
	
	//loading gif
	NSArray *images = @[[UIImage imageNamed:@"eat-now-loading-indicator-1"],
						[UIImage imageNamed:@"eat-now-loading-indicator-2"],
						[UIImage imageNamed:@"eat-now-loading-indicator-3"],
						[UIImage imageNamed:@"eat-now-loading-indicator-4"],
						[UIImage imageNamed:@"eat-now-loading-indicator-5"],
						[UIImage imageNamed:@"eat-now-loading-indicator-6"]];
	self.loading.animationImages = images;
	self.loading.animationDuration = 1.2;
    [self.loading startAnimating];
	
	//background
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	[bluredEffectView setFrame:self.view.frame];
	[self.view insertSubview:bluredEffectView aboveSubview:self.background];
	[[NSNotificationCenter defaultCenter] addObserverForName:kRestaurantViewImageChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
		if (note.object == self.frontCardView) {
			[self setBackgroundImage:note.userInfo[@"image"]];
		}
	}];
    
    [self.KVOController observe:_loading keyPath:@"alpha" options:NSKeyValueObservingOptionNew block:^(id observer, UIView *object, NSDictionary *change) {
        DDLogVerbose(@"Loading alpha changed %f", object.alpha);
    }];
}

#pragma mark - Main methods
- (void)searchNewRestaurantsForced:(BOOL)force{
    @weakify(self);
    [self.locationManager getLocationWithCompletion:^(CLLocation *location) {
        @strongify(self);
		if (location) {
			[self.serverManager searchRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
				if (success) {
					self.restaurants = response.mutableCopy;
					[self showAllRestaurantCards];
				}
			}];
		}
		else{
			
		}
		
    } forece:force];
}

- (void)showAllRestaurantCards{
    
    self.loadingInfo.text = @"";
	
    if (self.restaurantCards.count > 0) {
        DDLogWarn(@"=== Already have cards, skip showing restaurant");
        return;
    }
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to show, skip showing restaurants");
        return;
    }
    if (_isDismissingCard) {
        DDLogWarn(@"Dismissing in progress, skip showing restaurant!");
        return;
    }
	if (_isShowingCards) {
		DDLogWarn(@"Showing cards in progress, skip showing again");
		return;
	}
    
	_isShowingCards = YES;
    // Display cards animated
	NSUInteger restaurantCount = _restaurants.count;
    for (NSInteger i = 1; i <= restaurantCount; i++) {
		//insert card
		ENRestaurantView *card = [self popResuturantViewWithFrame:[self initialCardFrame]];
		card.hidden = YES;
		if (i==1) {
			DDLogVerbose(@"Poping %@th card: %@", @(i), card.restaurant.name);
			[self.detailFrame addSubview:card];
			[card addGestureRecognizer:self.panGesture];
			[card.info addGestureRecognizer:self.tapGesture];
			[card didChangedToFrontCard];
        } else{
            DDLogVerbose(@"Poping %@th card: %@", @(i), card.restaurant.name);
			//insert behind previous card
			UIView *previousCard = self.restaurantCards[i-2];
			NSParameterAssert(previousCard.superview);
			[self.detailFrame insertSubview:card belowSubview:previousCard];
		}
		//animate
		if (i <= kMaxCardsToAnimate){
			//animate
            float delay = (kMaxCardsToAnimate - i) * 0.2;
            DDLogVerbose(@"Delay %f sec for %ldth card", delay, (long)i);
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				card.hidden = NO;
				[self snapCardToCenter:card];
			});
		}else {
			float delay = i * 0.2 + 2;
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				card.frame = [self cardViewFrame];
				card.hidden = NO;
			});
		}
    }
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((restaurantCount * 0.2 +2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isShowingCards = NO;
        //stop loading
        self.loading.alpha = 0;
	});
}



- (void)dismissFrontCardWithVelocity:(CGPoint)velocity{
    if (self.frontCardView) {
        ENRestaurantView *frontCard = self.frontCardView;
		//DDLogInfo(@"Dismiss card %@", frontCard.restaurant.name);
        //add dynamics
		[_animator removeBehavior:frontCard.snap];
		[_gravity addItem:frontCard];
		[_dynamicItem addItem:frontCard];
		if (velocity.x) {
			[_dynamicItem addLinearVelocity:velocity forItem:frontCard];
		}
		
        //remove front card from cards
        [self.restaurantCards removeObjectAtIndex:0];
        
        //add pan gesture to next
        [frontCard removeGestureRecognizer:self.panGesture];
		[frontCard.info removeGestureRecognizer:self.tapGesture];
        [self.frontCardView addGestureRecognizer:self.panGesture];
		[self.frontCardView.info addGestureRecognizer:self.tapGesture];
        
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
		
        //if last card, show refreshing button
		if (!self.frontCardView) {
            [self.view bringSubviewToFront:self.loading];
			self.loading.alpha = 1;
		}
    }
}

- (void)toggleCardDetails{
	[_animator removeBehavior:self.frontCardView.snap];
    if (self.frontCardView.status == ENRestaurantViewStatusCard) {
        [self.frontCardView switchToStatus:ENRestaurantViewStatusDetail withFrame:self.detailFrame.bounds animated:YES];
        [self.frontCardView removeGestureRecognizer:self.panGesture];
        //[self.frontCardView removeGestureRecognizer:self.tapGesture];
        [UIView animateWithDuration:0.3 animations:^{
            self.closeButton.alpha = 1;
        }];
    } else {
        [self.frontCardView switchToStatus:ENRestaurantViewStatusCard withFrame:self.cardViewFrame animated:YES];
        [self.frontCardView addGestureRecognizer:self.panGesture];
        //[self.frontCardView addGestureRecognizer:self.tapGesture];
        [UIView animateWithDuration:0.3 animations:^{
            self.closeButton.alpha = 0;
        }];
    }
}


- (void)toggleHistoryView {
    if (self.isHistoryShown) {
        //show
        self.historyChildViewControllerLeadingConstraint.constant = 0;
        self.historyChildViewControllerTrailingConstraint.constant = 0;
        self.detailCardLeadingConstraint.constant = self.view.frame.size.width;
        self.detailCardTrailingConstraint.constant = -self.view.frame.size.width;
        [self.historyViewController loadData];
    }
    else {
        //close
        self.historyChildViewControllerLeadingConstraint.constant = -self.view.frame.size.width;
        self.historyChildViewControllerTrailingConstraint.constant = self.view.frame.size.width;
        self.detailCardLeadingConstraint.constant = 0;
        self.detailCardTrailingConstraint.constant = 0;
    }
    
    [super updateViewConstraints];
}

#pragma mark - Guesture actions
- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture {
	[self toggleCardDetails];
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint locInView = [gesture locationInView:self.detailFrame];
    CGPoint locInCard = [gesture locationInView:self.frontCardView];
    ENRestaurantView *card = self.frontCardView;
    if (gesture.state == UIGestureRecognizerStateBegan) {
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
            [self dismissFrontCardWithVelocity:velocity];
        }
        else {
            [self snapCardToCenter:card];
        }
    }
}

// This is called when a user didn't fully swipe left or right.
- (void)snapCardToCenter:(ENRestaurantView *)card {
    NSParameterAssert(card);
	if (card.snap) {
		[_animator removeBehavior:card.snap];
	}
	UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:card snapToPoint:self.cardFrame.center];
	
    snap.damping = 0.98;
    [_animator addBehavior:snap];
    card.snap = snap;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[_animator removeBehavior:card.snap];
	});
}

#pragma mark - Internal Methods
//data methods, should not add view related codes
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
    [self.restaurantCards addObject:card];
    //set background iamge
    [card.imageView applyGredient2];
    //shadow: very slow, avoid!
    //[card applyShadow];
    
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
    CGRect frame = self.cardFrame.frame;
    frame.origin.x = arc4random_uniform(400) - 200.0f;
    frame.origin.y -= [UIScreen mainScreen].bounds.size.height/2 + frame.size.height;
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
                ENRestaurant *restaurant = self.frontCardView.restaurant;
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


- (IBAction)refresh:(id)sender {
    if (_isDismissingCard) {
        DDLogWarn(@"Already dismissing card!");
        return;
    }
	if (_isShowingCards) {
		DDLogWarn(@"Showing cards, skip refresh");
		return;
	}
    _isDismissingCard = YES;
    self.restaurants = nil;
	//dismiss cards
    for (NSUInteger i=self.restaurantCards.count; i > 0; i--) {
        if (i>kMaxCardsToAnimate) {
            ENRestaurantView *card = self.restaurantCards[i-1];
            DDLogInfo(@"Dismissing card %@", card.restaurant.name);
            [self.restaurantCards removeObjectAtIndex:i-1];
            [card removeFromSuperview];
        }else {
            float delay = i * 0.1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				CGPoint v = CGPointMake(50.0f - arc4random_uniform(100), 0);
                [self dismissFrontCardWithVelocity:v];
                if (i == kMaxCardsToAnimate) {
                    [self showAllRestaurantCards];
                }
            });
        }
    }
	//state
    float dismissDuration = MIN(_restaurantCards.count, kMaxRestaurants)*0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(dismissDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isDismissingCard = NO;
    });
	
	//search for new
    [self searchNewRestaurantsForced:YES];
        
    //show loading info
	self.loading.alpha = 1;
    self.loadingInfo.text = @"You have dismissed all cards.";
}

- (IBAction)showHistory:(id)sender{
    self.isHistoryShown = !_isHistoryShown;
    [self toggleHistoryView];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        //replace the button icon
        if (self.isHistoryShown) {
            [self.historyButton setImage:[UIImage imageNamed:@"eat-now-history-view-deck-button"] forState:UIControlStateNormal];
            self.reloadButton.alpha = 0;
            self.closeButton.alpha = 0;
        }else{
            [self.historyButton setImage:[UIImage imageNamed:@"eat-now-card-deck-view-history-button"] forState:UIControlStateNormal];
            self.reloadButton.alpha = 1;
            self.closeButton.alpha = 1;
        }
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)clapse:(id)sender {
    [self toggleCardDetails];
}

- (IBAction)test:(id)sender {
    [[ATConnect sharedConnection] presentMessageCenterFromViewController:self withCustomData:@{@"ID":[ENServerManager shared].myID}];
}

- (IBAction)close:(id)sender{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"embedHistorySegue"]) {
        self.historyViewController = segue.destinationViewController;
    }
    else {
        if ([segue.destinationViewController isKindOfClass:[ENMapViewController class]]) {
            ENMapViewController *mapVC = (ENMapViewController *)segue.destinationViewController;
            mapVC.restaurant = self.frontCardView.restaurant;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"embedHistorySegue"]) {
        return YES;
    }
    if (!self.frontCardView.restaurant) {
        return NO;
    }
    return YES;
}
@end
