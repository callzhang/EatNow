//
//  ENRestaurantView.m
//  EatNow
//
//  Created by Lei Zhang on 4/10/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENRestaurantViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ENServerManager.h"
#import "FBKVOController.h"
#import "NSTimer+BlocksKit.h"
#import "ENMapManager.h"
#import "UIAlertView+BlocksKit.h"
#import "ENUtil.h"
#import "AMRatingControl.h"
#import "NSDate+Extension.h"
#import "UIView+Material.h"
#import "extobjc.h"
#import "UIView+Extend.h"
#import "ENHistoryViewCell.h"
#import "ENRestaurantTableViewCell.h"
#import "TMAlertController.h"
#import "TMAlertAction.h"
#import "ENMainViewController.h"
#import "PureLayout.h"
#import "TOWebViewController.h"
@import AddressBook;

NSString *const kRestaurantViewImageChangedNotification = @"restaurant_view_image_changed";
NSString *const kSelectedRestaurantNotification = @"selected_restaurant";
NSString *const kMapViewDidShow = @"map_view_did_show";
NSString *const kMapViewDidDismiss = @"map_view_did_dismiss";

@interface ENRestaurantViewController()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *restautantInfo;

//IB
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *cuisine;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *openTime;
@property (weak, nonatomic) IBOutlet UILabel *walkingDistance;
@property (weak, nonatomic) IBOutlet UIView *openInfo;
@property (weak, nonatomic) IBOutlet UIView *distanceInfo;
@property (weak, nonatomic) IBOutlet UIView *card;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) NSMutableArray *imageViewsInImageScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *imageScrollViewPageControl;

//view
@property (strong, nonatomic) MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *userRatingView;
@property (weak, nonatomic) UILabel *mapDistanceLabel;

//autolayout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHightRatio;//normal 0.45

//internal
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) BOOL isLoadingImage;
@property (nonatomic, strong) ENMapManager *mapManager;
@property (nonatomic, weak) UIView *mapIcon;
@property (nonatomic, assign) BOOL hasParsedImage;
@property (nonatomic, assign) float walkingSeconds;
@property (nonatomic, assign) NSTimeInterval lastWalkingEstimate;
@end


@implementation ENRestaurantViewController
+ (instancetype)viewController {
    ENRestaurantViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENCardContainer"];
    return vc;
}

- (BOOL)canSwipe {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shadowView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowRadius = 10;
    self.shadowView.layer.shadowOpacity = 0.5;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    self.shadowView.hidden = YES;
    self.card.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.2].CGColor;
    self.card.layer.borderWidth = 1;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.map removeFromSuperview];
    self.map = nil;
    self.mapManager = nil;
}

//initialization method
- (void)setRestaurant:(ENRestaurant *)restaurant{
	_restaurant = restaurant;
    //table view data
	[self prepareData];
    
    [self activateImageScrollViewToIndex:1];
    //UI
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisineText;
    self.price.text = restaurant.pricesText;
    self.rating.text = [NSString stringWithFormat:@"%.1f", [restaurant.rating floatValue]];
    self.walkingDistance.text = _restaurant.distanceStr;
    self.openTime.text = restaurant.openInfo;
    if (restaurant.ratingColor) self.rating.backgroundColor = restaurant.ratingColor;
	
	//go button
	[self updateGoButton];
}

- (void)viewDidLayoutSubviews {
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:16].CGPath;
}

#pragma mark - State change
- (void)switchToStatus:(ENRestaurantViewStatus)status withFrame:(CGRect)frame animated:(BOOL)animate completion:(VoidBlock)block{
    float duration = animate ? 0.5 : 0;
    float damping = 0.7;
    if (status == ENRestaurantViewStatusMinimum || status == ENRestaurantViewStatusCard) {
        damping = 0.8;
    }
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveLinear animations:^{
        self.view.frame = frame;
        self.status = status;
        [self updateLayout];
        if (status == ENRestaurantViewStatusDetail) {
            self.shadowView.hidden = NO;
        }else {
            self.shadowView.hidden = YES;
        }
    } completion:^(BOOL finished) {
        switch (status) {
            case ENRestaurantViewStatusDetail:
            case ENRestaurantViewStatusHistoryDetail:{
                [self didChangeToDetailView];
                break;
            }
            default:{
                //close map if colapse
                [self closeMap];
                break;
            }
        }
        
        if (block) {
            block();
        }
        
        [self.tableView setContentOffset:CGPointZero animated:NO];
    }];
    
    
    switch (status) {
        case ENRestaurantViewStatusCard: {
            [self fillImageScrollViewWithCurrentImageView];
            break;
        }
        case ENRestaurantViewStatusDetail: {
            [self fillImageScrollViewWithAllImageViews];
            break;
        }
        case ENRestaurantViewStatusMinimum: {
            [self fillImageScrollViewWithFirstImageViews];
            break;
        }
        case ENRestaurantViewStatusHistoryDetail: {
            [self fillImageScrollViewWithAllImageViews];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)didChangedToFrontCard{
    if ([self.restaurant.images.firstObject isKindOfClass:[UIImage class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image":self.restaurant.images.firstObject}];
    }
    
    //start to calculate
    self.mapManager = [[ENMapManager alloc] initWithMap:nil];
    [self.mapManager estimatedWalkingTimeToLocation:_restaurant.location completion:^(NSTimeInterval length, NSError *error) {
        if (!error) {
            [self showWalkingTime:length];
        }
    }];
}

- (void)didChangeToDetailView{
    //parse image
    if (self.status == ENRestaurantViewStatusDetail){
        [self parseVendorImages];
    }
    
    //add map to view and hide
    self.map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.map.region = MKCoordinateRegionMakeWithDistance(self.restaurant.location.coordinate, 1000, 1000);
    [self.card insertSubview:self.map belowSubview:self.goButton];
    self.map.hidden = YES;
    self.mapManager.map = self.map;
    [self showWalkingTime:self.lastWalkingEstimate];
}

#pragma mark - UI
- (IBAction)selectRestaurant:(id)sender {
    if ([[ENServerManager shared].selectedRestaurant.ID isEqualToString:_restaurant.ID] ) {
        if (![ENServerManager shared].selectionHistoryID) {
            //need to wait for selection history ID returns
            return;
        }
        //cancel
        [[ENServerManager shared] clearSelectedRestaurant];
        @weakify(self);
        [[ENServerManager shared] cancelHistory:[ENServerManager shared].selectionHistoryID completion:^(NSError *error) {
            @strongify(self);
            if (error) {
                [ENUtil showFailureHUBWithString:@"failed"];
            }else{
                DDLogInfo(@"Cancelled %@", _restaurant.name);
                [self updateGoButton];
            }
        }];
        
        return;
    }
    
    if (![ENServerManager shared].canSelectNewRestaurant) {
        @weakify(self);
        
        TMAlertController *alertController = [TMAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Going %@ instead?", self.restaurant.name] message:[NSString stringWithFormat:@"You just said you were going to %@.", [ENServerManager shared].selectedRestaurant.name] preferredStyle:TMAlartControllerStyleAlert];
        
#ifdef DEBUG
        [alertController addAction:[TMAlertAction actionWithTitle:@"Force?" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
            @strongify(self);
            [[ENServerManager shared] clearSelectedRestaurant];
            [self selectRestaurant:nil];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
#endif
        
        [alertController addAction:[TMAlertAction actionWithTitle:@"NO" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [alertController addAction:[TMAlertAction actionWithTitle:@"YES" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
            @strongify(self);
            [ENUtil showWatingHUB];
            [[ENServerManager shared] cancelHistory:[ENServerManager shared].selectionHistoryID completion:^(NSError *error) {
                [ENUtil dismissHUD];
                [self dismissViewControllerAnimated:YES completion:nil];
                @strongify(self);
                if (error) {
                    ENLogError(error.localizedDescription);
                    [ENUtil showFailureHUBWithString:@"Failed to Cancel"];
                }else{
                    DDLogInfo(@"Cancelled %@", _restaurant.name);
                    [self updateGoButton];
                    [self selectRestaurant:nil];
                }
            }];
        }]];

        
        alertController.iconStyle = TMAlertControlerIconStyleQustion;
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    //select
    [[ENServerManager shared] selectRestaurant:_restaurant like:1 completion:^(NSError *error) {
        if (error) {
            ENLogError(error.localizedDescription);
            [ENUtil showFailureHUBWithString:@"failed"];
            [self updateGoButton];
        }
        else{
            DDLogInfo(@"Selected %@", _restaurant.name);
            NSString *kShouldShowNiceChoiceKey = @"shouldShowNiceChoice";
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{kShouldShowNiceChoiceKey : @(YES)}];
            BOOL shouldShowNiceChoice = [[NSUserDefaults standardUserDefaults] boolForKey:kShouldShowNiceChoiceKey];
            if (shouldShowNiceChoice
//                || YES
                ) {
                TMAlertController *alertController = [TMAlertController alertControllerWithTitle:@"Nice Pick!" message:@"Eat Now learns about your taste each time you tap Go There." preferredStyle:TMAlartControllerStyleAlert];
                alertController.iconStyle = TMAlertControlerIconStyleThumbsUp;
                [alertController addAction:[TMAlertAction actionWithTitle:@"OK" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShouldShowNiceChoiceKey];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            [self prepareData];
            [self.tableView reloadData];
            [self updateGoButton];
        }
    }];
    
    //map
    if (self.map.hidden == YES) {
        [self showMap:nil];
    }
    
    //button
    [self updateGoButton];
}

- (IBAction)showMap:(id)sender{
    self.map.hidden = NO;
    self.map.showsUserLocation = YES;
    self.map.delegate = self.mapManager;
    
    [UIView collapse:self.mapIcon view:self.map animated:NO completion:nil];
    [UIView expand:self.mapIcon view:self.map completion:nil];
    
    [self.mapManager addAnnotationForRestaurant:_restaurant];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMapViewDidShow object:nil];
    
    //route
    @weakify(self);
    [self.mapManager routeToRestaurant:_restaurant repeat:10 completion:^(NSTimeInterval length, NSError *error) {
        if (!error) {
            @strongify(self);
            [self showWalkingTime:length];
        }
    }];
    
    self.mainVC.currentMode = ENMainViewControllerModeMap;
}

- (void)closeMap {
    [UIView collapse:self.mapIcon view:self.map animated:YES completion:^{
        self.map.hidden = YES;
        [self.mapManager cancelRouting];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMapViewDidDismiss object:nil];
    }];
}

- (void)updateLayout{
    //radio
    float multiplier = (self.status == ENRestaurantViewStatusDetail || self.status == ENRestaurantViewStatusHistoryDetail) ? ENRestaurantViewImageRatio : 1.0;
    NSLayoutConstraint *newRatio = [NSLayoutConstraint constraintWithItem:_infoHightRatio.firstItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_infoHightRatio.secondItem attribute:NSLayoutAttributeHeight multiplier:multiplier constant:0];
    self.infoHightRatio.active = NO;
    self.infoHightRatio = newRatio;
    self.infoHightRatio.active = YES;
    [self.view layoutIfNeeded];
    
    //show information only for card view
    if (self.status == ENRestaurantViewStatusCard) {
        if (self.walkingDistance.text) {
            self.distanceInfo.alpha = 1;
        }
        if (self.openTime.text) {
            self.openInfo.alpha = 1;
        }
        self.goButton.alpha = 0;
        self.rating.alpha = 1;
        self.userRatingView.alpha = 0;
        self.price.alpha = 1;
    }
    else if (self.status == ENRestaurantViewStatusDetail) {
        self.distanceInfo.alpha = 0;
        self.openInfo.alpha = 0;
        self.goButton.alpha = 1;
        self.rating.alpha = 1;
        self.userRatingView.alpha = 0;
        self.price.alpha = 1;
    }
    else if (self.status == ENRestaurantViewStatusMinimum) {
        self.distanceInfo.alpha = 0;
        self.openInfo.alpha = 0;
        self.goButton.alpha = 0;
        self.rating.alpha = 0;
        self.price.alpha = 0;
        NSDictionary *history = [ENServerManager shared].userRating;
        NSDictionary *rating = history[self.restaurant.ID];
        NSNumber *rate = rating[@"rating"];
        if (rating) {
            self.userRatingView.alpha = 1;
            [self addRatingOnView:self.userRatingView withRating:rate.integerValue];
        }
        
    }
    else if (self.status == ENRestaurantViewStatusHistoryDetail) {
        self.distanceInfo.alpha = 0;
        self.openInfo.alpha = 0;
        self.goButton.alpha = 0;
        self.rating.alpha = 0;
        self.userRatingView.alpha = 0;
        self.price.alpha = 1;
    }
}

- (void)updateGoButton{
    if ([[ENServerManager shared].selectedRestaurant.ID isEqualToString:self.restaurant.ID]) {
        [self.goButton setImage:[UIImage imageNamed:@"eat-now-card-details-view-cancel-button"] forState:UIControlStateNormal];
    }
    else{
        [self.goButton setImage:[UIImage imageNamed:@"eatnew-card-details-view-go-button"] forState:UIControlStateNormal];
    }
}

- (void)addRatingOnView:(UIView *)view withRating:(NSInteger)rating{
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-yellow"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0)
                                                                          emptyImage:emptyImageOrNil
                                                                          solidImage:solidImageOrNil
                                                                        andMaxRating:5];
    [imagesRatingControl setStarSpacing:3];
    imagesRatingControl.rating = rating + 3;
    [view addSubview:imagesRatingControl];
}

#pragma mark - ImageScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.imageScrollViewPageControl.currentPage = page;
    
    //TODO: add change notification if necessary
//    //send image change notification
//    [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image":image}];
}

- (void)fillImageScrollViewWithAllImageViews {
    [self activateImageScrollViewToIndex:self.restaurant.imageUrls.count];
    self.imageScrollView.scrollEnabled = YES;
}

- (void)fillImageScrollViewWithFirstImageViews {
    [self activateImageScrollViewToIndex:self.restaurant.imageUrls.count > 0 ? 1: 0];
    self.imageScrollView.scrollEnabled = NO;
}

- (void)fillImageScrollViewWithCurrentImageView {
    [self activateImageScrollViewToIndex:self.imageScrollViewPageControl.currentPage + 1];
    self.imageScrollView.scrollEnabled = NO;
}

- (void)setupScrollViewConstraints {
    self.imageScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageViewsInImageScrollView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    [self.imageViewsInImageScrollView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [self.imageScrollView addSubview:view];
    }];
    
    [self.imageViewsInImageScrollView enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:view.superview];
        [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:view.superview];
    }];
    [self.imageViewsInImageScrollView.firstObject autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    if (self.imageViewsInImageScrollView.count >= 2) {
        [self.imageViewsInImageScrollView autoDistributeViewsAlongAxis:ALAxisHorizontal alignedTo:ALAttributeHorizontal withFixedSpacing:0 insetSpacing:YES matchedSizes:YES];
    }
    else {
        [self.imageViewsInImageScrollView.firstObject autoAlignAxisToSuperviewAxis:ALAxisVertical];
    }
}

- (void)activateImageScrollViewToIndex:(NSInteger)index {
    NSInteger totalImageCount = self.imageViewsInImageScrollView.count;
    if (index < totalImageCount) {
        [self.imageViewsInImageScrollView removeObjectsInRange:NSMakeRange(index, totalImageCount - index)];
    }
    else {
        for (NSInteger i = totalImageCount; i < index && i < ENRestaurantViewImagesMaxCount; i++) {
            UIImageView *imageView = [self createdImageViewForIndex:i];
            if (imageView) {
                [self.imageViewsInImageScrollView addObject:imageView];
            }
        }
    }
    [self setupScrollViewConstraints];
    self.imageScrollViewPageControl.numberOfPages = self.imageViewsInImageScrollView.count;
}

- (UIImageView *)createdImageViewForIndex:(NSUInteger)index {
    if (index >= self.restaurant.imageUrls.count) {
        return nil;
    }
    
    NSString *url = self.restaurant.imageUrls[index];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    DDLogVerbose(@"Loading %luth image for %@", (unsigned long)index, self.restaurant.name);
    [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:nil
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        ENLogError(@"*** Failed to download image \n %@ \n with error: %@", url, error);
    }];
    
    return imageView;
}

- (NSMutableArray *)imageViewsInImageScrollView {
    if (!_imageViewsInImageScrollView) {
        _imageViewsInImageScrollView = [NSMutableArray array];
    }
    
    return _imageViewsInImageScrollView;
}


- (void)parseVendorImages{
    if (self.restaurant.imageUrls.count > 10) return;
    if (self.hasParsedImage == YES) return;
    self.hasParsedImage = YES;
    DDLogVerbose(@"start to parse image for %@", self.restaurant.name);
    //load image from webpage
    @weakify(self);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.restaurant parseFoursquareWebsiteForImagesWithUrl:self.restaurant.venderUrl completion:^(NSArray *imageUrls, NSError *error) {
            if (!self) {
                DDLogVerbose(@"Restaurant view dismissed before updating images");
                return;
            }
            @strongify(self);
            if (!imageUrls) {
#ifdef DEBUG
                ENLogError(@"Failed to parse foursquare image %@, error %@", self.restaurant.url, error);
#endif
                return;
            }
            if (imageUrls.count > 1) {
                //show image
                //[self loadNextImage];
                //update to server
                [[ENServerManager shared] updateRestaurant:self.restaurant withInfo:@{@"img_url":imageUrls} completion:nil];
            }
        }];
    });
}

- (void)showWalkingTime:(NSTimeInterval)length{
    self.lastWalkingEstimate = length;
    NSString *str = [NSString stringWithFormat:@"%@ away, %@ walking", _restaurant.distanceStr, [ENUtil getStringFromTimeInterval:length]];
    self.walkingDistance.text = str;
    self.mapDistanceLabel.text = str;
}

#pragma mark - Table view
- (void)prepareData{
    NSParameterAssert(_restaurant.json);
    NSMutableArray *info = [NSMutableArray new];
    __weak __typeof(self)weakSelf = self;
    if (weakSelf.restaurant.placemark) {
        [info addObject:@{@"type": @"address",
                          @"cellID": @"mapCell",
                          @"height": @80,
                          @"image": @"eat-now-card-details-view-map-icon",
                          //@"title": _restaurant.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStreetKey],
                          //@"detail":[NSString stringWithFormat:@"%.1fkm away", _restaurant.distance.floatValue/1000],
                          @"layout": ^(UITableViewCell *cell){
            UILabel *address = (UILabel *)[cell viewWithTag:111];
            UILabel *distance = (UILabel *)[cell viewWithTag:222];
            NSString *street = weakSelf.restaurant.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStreetKey];
            NSString *city = weakSelf.restaurant.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressCityKey];
            NSString *state = weakSelf.restaurant.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStateKey];
            NSString *zip = weakSelf.restaurant.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressZIPKey];
            address.text = [NSString stringWithFormat:@"%@\n%@, %@ %@", street, city, state, zip];
            distance.text = _restaurant.distanceStr;
            weakSelf.mapIcon = [cell viewWithTag:333];
            self.mapDistanceLabel = distance;
        },
                          @"action": ^{
            //action to open map
            [weakSelf showMap:nil];
        }}];
    }
    if (weakSelf.restaurant.openInfo) {
        [info addObject:@{@"type": @"address",
                          @"cellID": @"cell",
                          @"image": @"eat-now-card-details-view-time-icon",
                          @"title": weakSelf.restaurant.openInfo}];
    }
    if (weakSelf.restaurant.phone) {
        [info addObject:@{@"type": @"phone",
                          @"cellID": @"cell",
                          @"image": @"eat-now-card-details-view-phone-icon",
                          @"title": weakSelf.restaurant.phone,
                          @"action": ^{
            NSString *phoneStr = [NSString stringWithFormat:@"tel:%@",weakSelf.restaurant.phoneNumber];
            NSURL *phoneUrl = [NSURL URLWithString:phoneStr];
            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                TMAlertController *alert = [TMAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Call %@?", weakSelf.restaurant.phoneNumber] message:nil preferredStyle:TMAlartControllerStyleAlert];
                alert.iconStyle = TMAlertControlerIconStylePhone;
                [alert addAction:[TMAlertAction actionWithTitle:@"Cancel" style:TMAlertActionStyleCancel handler:^(TMAlertAction *action) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }]];
                [alert addAction:[TMAlertAction actionWithTitle:@"Call" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
                    [[UIApplication sharedApplication] openURL:phoneUrl];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
            }}];
    }
    if (weakSelf.restaurant.url) {
        [info addObject:@{@"type": @"url",
                          @"cellID": @"cell",
                          @"image": @"eat-now-card-details-view-web-icon",
                          @"title": weakSelf.restaurant.url,
                          @"action": ^{
            NSURL *url = [NSURL URLWithString:weakSelf.restaurant.url];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                TMAlertController *alert = [TMAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Open Web Page?"] message:[NSString stringWithFormat:@"View %@ in the web browser?", weakSelf.restaurant.url] preferredStyle:TMAlartControllerStyleAlert];
                alert.iconStyle = TMAlertControlerIconStyleQustion;
                [alert addAction:[TMAlertAction actionWithTitle:@"Cancel" style:TMAlertActionStyleCancel handler:^(TMAlertAction *action) {
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }]];
                [alert addAction:[TMAlertAction actionWithTitle:@"Open" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
                    [[UIApplication sharedApplication] openURL:url];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        }}];
    }
    if (weakSelf.restaurant.mobileMenuURL) {
        [info addObject:@{@"type": @"url",
                          @"cellID": @"cell",
                          @"image": @"eat-now-card-details-view-web-icon",
                          @"title": @"View Menu",
                          @"action": ^{
            TOWebViewController *vc = [[TOWebViewController alloc] initWithURLString:weakSelf.restaurant.mobileMenuURL];
            vc.showPageTitles = YES;
            vc.showUrlWhileLoading = NO;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [weakSelf presentViewController:nav animated:YES completion:nil];
        }}];
    }
//    if (weakSelf.restaurant.reviews) {
//        [info addObject:@{@"type": @"reviews",
//                          @"cellID": @"cell",
//                          @"image": @"eat-now-card-details-view-twitter-icon",
//                          @"title": [NSString stringWithFormat:@"%@ tips", weakSelf.restaurant.reviews],
//                          @"accessory": @"disclosure",
//                          @"action": ^{
//            [ENUtil showText:@"Coming soon"];
//        }}];
//    }
    
    //rating
    NSDictionary *histories = [ENServerManager shared].userRating;
    NSDictionary *history = histories[weakSelf.restaurant.ID];
    NSNumber *rate = history[@"rating"];
    NSNumber *reviewed = history[@"reviewed"];
    NSInteger ratingValue = rate.integerValue;
    
    if (history && reviewed.boolValue) {
        if (reviewed.boolValue) {
            [info addObject:
             @{@"type": @"score",
                @"cellID": @"rating",
                @"layout": ^(UITableViewCell *cell){
                    //Set rating from history
                    UIView *ratingView = [cell viewWithTag:99];
                    [self addRatingOnView:ratingView withRating:ratingValue];
                    
                    //set time
                    NSDate *time = history[@"time"];
                    UILabel *timeLabel = (UILabel *)[cell viewWithTag:88];
                    timeLabel.text = [NSString stringWithFormat:@"%@", time.string];
                },
                  @"image": @"eat-now-card-details-view-feedback-icon",
                  @"detail": [NSString stringWithFormat:@"%@", weakSelf.restaurant.scoreComponentsText]
            }];
        }
        
    }
    if (self.mainVC.showScore) {
        if (weakSelf.restaurant.score) {
			float original_score = [(NSNumber *)[weakSelf.restaurant.json valueForKeyPath:@"score.original_score"] floatValue];
			float total = weakSelf.restaurant.score.floatValue;
			float perc = total/original_score-1;
            [info addObject:@{@"type": @"score",
                              @"cellID":@"subtitle",
                              @"title": [NSString stringWithFormat:@"Total score: %.1f(%.0f%%)", total, perc*100],
                              @"detail": [NSString stringWithFormat:@"%@", weakSelf.restaurant.scoreComponentsText]
                              }];
        }
    }
    
    //footer
    [info addObject:@{
                      @"type": @"footer",
                      @"cellID": @"foursquare",
                      @"height": @114,
                      @"layout": ^(UITableViewCell *cell){
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(weakSelf.tableView.bounds));
    }
                      }];
    
    
    self.restautantInfo = info.copy;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.restautantInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *info = self.restautantInfo[indexPath.row];
    if (info[@"height"]) {
        NSNumber *height = info[@"height"];
        return height.floatValue;
    }
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    NSDictionary *info = self.restautantInfo[indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:info[@"cellID"]];
    if (info[@"layout"]) {
        tableViewCellLayoutBlock block = info[@"layout"];
        block(cell);
    }
    
    if (![cell isKindOfClass:[ENRestaurantTableViewCell class]]) {
        if (info[@"title"]) cell.textLabel.text = info[@"title"];
        if (info[@"detail"]) cell.detailTextLabel.text = info[@"detail"];
        if (info[@"image"]) {
            UIImageView *iconImageView = (UIImageView *) [cell viewWithTag:1985];
            iconImageView.image = [UIImage imageNamed:info[@"image"]];
        }
    }
    else {
        ENRestaurantTableViewCell *restrantCell = (ENRestaurantTableViewCell *)cell;
        restrantCell.cellTitleLabel.text = info[@"title"];
        restrantCell.iconImageView.image = [UIImage imageNamed:info[@"image"]];
    }
    cell.selectedBackgroundView = [[UIView alloc] init];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    
    if (info[@"accessory"]) {
        if ([info[@"accessory"] isEqualToString:@"disclosure"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if ([cell respondsToSelector:@selector(setRestaurant:)]) {
        [cell setValue:self.restaurant forKeyPath:@keypath(self.restaurant)];
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.preservesSuperviewLayoutMargins = NO;
    
    //hide bottom seperator for foursquare cell
    if ([info[@"cellID"] isEqualToString:@"foursquare"]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 2000, 0, 0);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *info = self.restautantInfo[indexPath.row];
    VoidBlock action = info[@"action"];
    if (action) {
        action();
    }
    
    //deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
