//
//  ENRestaurantView.m
//  EatNow
//
//  Created by Lei Zhang on 4/10/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENRestaurantView.h"
#import "TFHpple.h"
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
@import AddressBook;

NSString *const kRestaurantViewImageChangedNotification = @"restaurant_view_image_changed";
NSString *const kSelectedRestaurantNotification = @"selected_restaurant";
NSString *const kMapViewDidShow = @"map_view_did_show";
NSString *const kMapViewDidDismiss = @"map_view_did_dismiss";

@interface ENRestaurantView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *restautantInfo;

//IB
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *cuisine;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UILabel *openTime;
@property (weak, nonatomic) IBOutlet UILabel *walkingDistance;
@property (weak, nonatomic) IBOutlet UIView *openInfo;
@property (weak, nonatomic) IBOutlet UIView *distanceInfo;
@property (weak, nonatomic) IBOutlet UIView *card;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) MKMapView *map;
@property (weak, nonatomic) IBOutlet UIView *userRatingView;

//autolayout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHightRatio;//normal 0.45

//internal
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) BOOL isLoadingImage;
@property (nonatomic, strong) ENMapManager *mapManager;
@property (nonatomic, weak) UIView *mapIcon;
@end


@implementation ENRestaurantView
+ (instancetype)loadView{
    UIViewController *container = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENCardContainer"];
    ENRestaurantView *view = (ENRestaurantView *)container.view;
    NSParameterAssert([view isKindOfClass:[ENRestaurantView class]]);
    return view;
}

//initialization method
- (void)setRestaurant:(ENRestaurant *)restaurant{
	_restaurant = restaurant;
    //table view data
	[self prepareData];
	
	//update view
    self.status = ENRestaurantViewStatusCard;
    [self updateLayout];
    
    //image
    _currentImageIndex = -1;
    [self loadNextImage];
    
    //UI
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisineText;
    self.price.text = restaurant.pricesText;
    self.rating.text = [NSString stringWithFormat:@"%.0f", round(restaurant.rating.integerValue)];
    self.walkingDistance.text = [NSString stringWithFormat:@"%.1fkm", restaurant.distance.floatValue/1000];
    self.openTime.text = restaurant.openInfo;
    if (restaurant.ratingColor) self.rating.backgroundColor = restaurant.ratingColor;
	
	//go button
	[self updateGoButton];
}

#pragma mark - State change
- (void)switchToStatus:(ENRestaurantViewStatus)status withFrame:(CGRect)frame animated:(BOOL)animate completion:(VoidBlock)block{
    float duration = animate ? 0.5 : 0;
    float damping = status == ENRestaurantViewStatusMinimum ? 1 : 0.7;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveLinear animations:^{
        self.frame = frame;
        self.status = status;
        [self updateLayout];
    } completion:^(BOOL finished) {
        if (status == ENRestaurantViewStatusDetail) {
            [self loadNextImage];
        }
        if (block) {
            block();
        }
    }];
    
    //close map if colapse
    if (self.map.frame.size.height > 0) {
        if (status == ENRestaurantViewStatusCard || status == ENRestaurantViewStatusMinimum) {
            [self toggleMap:nil];
        }
    }
}

- (void)didChangedToFrontCard{
    if ([self.restaurant.images.firstObject isKindOfClass:[UIImage class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image":self.restaurant.images.firstObject}];
    }
    //load image from webpage
    if (self.restaurant.imageUrls.count <= 1) {
        @weakify(self);
        NSString *tempUrl = self.restaurant.url ?: [NSString stringWithFormat:@"http://foursquare.com/v/%@", self.restaurant.foursquareID];
        [self parseFoursquareWebsiteForImagesWithUrl:tempUrl completion:^(NSArray *imageUrls, NSError *error) {
            @strongify(self);
            if (!imageUrls) {
                ENLogError(@"Failed to parse foursquare image %@", self.restaurant.url);
                return;
            }
            
            self.restaurant.imageUrls = imageUrls;
        }];
    }
}

#pragma mark - UI
- (IBAction)selectRestaurant:(id)sender {
	if ([ENServerManager shared].selectedRestaurant == _restaurant) {
		//cancel
		[[ENServerManager shared] clearSelectedRestaurant];
        @weakify(self);
        [[ENServerManager shared] cancelSelectedRestaurant:[ENServerManager shared].selectionHistoryID completion:^(NSError *error) {
            @strongify(self);
			if (error) {
				ENLogError(error.localizedDescription);
				[ENUtil showFailureHUBWithString:@"failed"];
			}else{
				DDLogInfo(@"Disliked %@", _restaurant.name);
				[self updateGoButton];
			}
		}];
        
		return;
	}
    
	if (![ENServerManager shared].canSelectNewRestaurant) {
		[UIAlertView bk_showAlertViewWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Do you want to go to %@ instead? Your previous choice (%@) will be removed.", self.restaurant.name, [ENServerManager shared].selectedRestaurant.name] cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Yes, I changed my mind."] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
			if (buttonIndex == 1) {
				[[ENServerManager shared] clearSelectedRestaurant];
				[self selectRestaurant:nil];
			}
		}];
		return;
	}
	
	//select
	[[ENServerManager shared] selectRestaurant:_restaurant like:1 completion:^(NSError *error) {
		if (error) {
			ENLogError(error.localizedDescription);
			[ENUtil showFailureHUBWithString:@"failed"];
		}
        else{
			DDLogInfo(@"Selected %@", _restaurant.name);
            [self showNotification:@"Nice choice" WithStyle:HUDStyleNiceChioce audoHide:3];
            [self prepareData];
            [self.tableView reloadData];
		}
	}];
	
	//map
    if (!self.map) {
        [self toggleMap:nil];
    }
    
    @weakify(self);
    [self.mapManager routeToRestaurant:_restaurant repeat:10 completion:^(NSTimeInterval length, NSError *error) {
        @strongify(self);
        self.walkingDistance.text = [NSString stringWithFormat:@"%.1f Min Walking", length/60];
    }];
	
	//button
	[self updateGoButton];
}

- (IBAction)toggleMap:(id)sender{
    static UIButton *closeMap;
    if (!_map) {
        //map
        
        self.map = [[MKMapView alloc] initWithFrame:self.bounds];
        self.mapManager = [[ENMapManager alloc] initWithMap:self.map];
        self.map.region = MKCoordinateRegionMakeWithDistance(self.restaurant.location.coordinate, 1000, 1000);
        self.map.showsUserLocation = YES;
        self.map.delegate = self.mapManager;
        [self insertSubview:self.map belowSubview:self.goButton];
        
        closeMap = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [closeMap setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [closeMap addTarget:self action:@selector(toggleMap:) forControlEvents:UIControlEventTouchUpInside];
        closeMap.tintColor = [UIColor blueColor];
        [UIView collapse:self.mapIcon view:self.map animated:NO completion:nil];
        [UIView expand:self.mapIcon view:self.map completion:^{
            [self addSubview:closeMap];
        }];
        
        [self.mapManager addAnnotationForRestaurant:_restaurant];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMapViewDidShow object:nil];
        
        //route if select
        if ([ENServerManager shared].selectedRestaurant == _restaurant){
            @weakify(self);
            [self.mapManager routeToRestaurant:_restaurant repeat:10 completion:^(NSTimeInterval length, NSError *error) {
                @strongify(self);
                self.walkingDistance.text = [NSString stringWithFormat:@"%.1f Min Walking", length/60];
            }];
        }
        
    }
    else{
        //hide
        [closeMap removeFromSuperview];
        closeMap = nil;
        [UIView collapse:self.mapIcon view:self.map animated:YES completion:^{
            [self.mapManager cancelRouting];
            [self.map removeFromSuperview];
            self.map = nil;
            self.mapManager = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kMapViewDidDismiss object:nil];
        }];
    }
}

- (void)updateLayout{
    //radio
    float multiplier = (self.status == ENRestaurantViewStatusDetail || self.status == ENRestaurantViewStatusHistoryDetail) ? 0.4 : 1.0;
    NSLayoutConstraint *newRatio = [NSLayoutConstraint constraintWithItem:_infoHightRatio.firstItem attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_infoHightRatio.secondItem attribute:NSLayoutAttributeHeight multiplier:multiplier constant:0];
    self.infoHightRatio.active = NO;
    self.infoHightRatio = newRatio;
    self.infoHightRatio.active = YES;
    [self layoutIfNeeded];
    
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
	if ([ENServerManager shared].selectedRestaurant == self.restaurant) {
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

#pragma mark - Private

- (void)parseFoursquareWebsiteForImagesWithUrl:(NSString *)urlString completion:(void (^)(NSArray *imageUrls, NSError *error))block{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    @weakify(self);
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        NSData *data = responseObject;
        TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
        NSArray * elements  = [doc searchWithXPathQuery:@"//div[@class='photosSection']/ul/li/img"];
        NSMutableArray *images = [NSMutableArray array];
        for (TFHppleElement *element in elements) {
            NSString *imgUrl = [element objectForKey:@"data-retina-url"];
            if (imgUrl) {
                NSMutableArray *urlComponents = [imgUrl componentsSeparatedByString:@"/"].mutableCopy;
                NSString *sizeStr = urlComponents[urlComponents.count-2];
                if (sizeStr.length == 7 && [sizeStr characterAtIndex:3] == 'x') {
                    urlComponents[urlComponents.count-2] = @"original";
                    imgUrl = [urlComponents componentsJoinedByString:@"/"];
                }
                [images addObject:imgUrl];
            }
        }
		
        block(images, nil);
		
		//update to server
		[[ENServerManager shared] updateRestaurant:self.restaurant withInfo:@{@"img_url":images} completion:nil];
		
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ENLogError(@"Failed to download website %@", urlString);
        block(nil, error);
    }];;
    [op start];
}

- (void)loadNextImage{
    if (self.status == ENRestaurantViewStatusCard && _currentImageIndex != -1) {
        return;
    }
    if (_isLoadingImage) {
        DDLogVerbose(@"Loading image, skip");
        return;
    }
    if (_restaurant.imageUrls.count == 1 && self.imageView.image && _currentImageIndex != -1) {
        DDLogVerbose(@"Only one image, skip");
        return;
    }
    
    NSInteger nextIdx = (_currentImageIndex + 1) % self.restaurant.imageUrls.count;
    
    //display if downloaded
    if (self.restaurant.images.count > nextIdx) {
        if (self.restaurant.images[nextIdx] != [NSNull null]) {
            _currentImageIndex = nextIdx;
            [self showImage:self.restaurant.images[nextIdx]];
            return;
        }
    }
    
    //download
    self.isLoadingImage = YES;
    [self.loading startAnimating];
    NSURL *url = [NSURL URLWithString:self.restaurant.imageUrls[nextIdx]];
    //download first
    @weakify(self);
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        @strongify(self);
		_currentImageIndex = nextIdx;
		_isLoadingImage = NO;
		[self.loading stopAnimating];
		NSMutableArray *images = _restaurant.images;
		while (images.count <= _currentImageIndex) {
			[images addObject:[NSNull null]];
		}
		images[_currentImageIndex] = image;
		_restaurant.images = images;
		
		[self showImage:image];
		
		//self.pageControl.currentPage = nextIdx;
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		ENLogError(@"*** Failed to download image with error: %@", error);
	}];
}

- (void)showImage:(UIImage *)image{
    if (self.loading.isAnimating) {
        [self.loading stopAnimating];
    }
    
    if (self.map) {
        return;
    }
    
    self.imageView.image = image;
    
    //duplicate view
    if (self.superview) {
        UIView *imageViewCopy = [self.imageView snapshotViewAfterScreenUpdates:NO];
        [self insertSubview:imageViewCopy aboveSubview:self.imageView];
        [UIView animateWithDuration:0.5 animations:^{
            imageViewCopy.alpha = 0;
        } completion:^(BOOL finished) {
            [imageViewCopy removeFromSuperview];
        }];
    }
        
    //send image change notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image":image}];
    
    //start next
    if (self.status == ENRestaurantViewStatusDetail) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadNextImage) object:nil];
        [self performSelector:@selector(loadNextImage) withObject:nil afterDelay:5];
    }
    
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
            distance.text = [NSString stringWithFormat:@"%.1fkm away", weakSelf.restaurant.distance.floatValue/1000];
            
            weakSelf.mapIcon = [cell viewWithTag:333];
        },
                          @"action": ^{
            //action to open map
            [weakSelf toggleMap:nil];
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
				[[UIApplication sharedApplication] openURL:phoneUrl];
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
				[[UIApplication sharedApplication] openURL:url];
			}
		}}];
	}
	if (weakSelf.restaurant.reviews) {
		[info addObject:@{@"type": @"reviews",
						  @"cellID": @"cell",
						  @"image": @"eat-now-card-details-view-twitter-icon",
						  @"title": [NSString stringWithFormat:@"%@ tips", weakSelf.restaurant.reviews],
                          @"accessory": @"disclosure",
						  @"action": ^{
			[ENUtil showText:@"Coming soon"];
		}}];
	}
    
	//rating
    NSDictionary *history = [ENServerManager shared].userRating;
    NSDictionary *rating = history[weakSelf.restaurant.ID];
    NSNumber *rate = rating[@"rating"];
    NSInteger ratingValue = rate.integerValue;
    
    if (rating) {
        [info addObject:@{@"type": @"score",
                          @"cellID": @"rating",
                          @"layout": ^(UITableViewCell *cell){

                                //Set rating from history
                                UIView *ratingView = [cell viewWithTag:99];
                                [self addRatingOnView:ratingView withRating:ratingValue];
            
                                //set time
                                NSDate *time = rating[@"time"];
                                UILabel *timeLabel = (UILabel *)[cell viewWithTag:88];
                                timeLabel.text = [NSString stringWithFormat:@"(%@)", time.string];
                            },
                          @"image": @"eat-now-card-details-view-feedback-icon",
                          @"detail": [NSString stringWithFormat:@"%@", weakSelf.restaurant.scoreComponentsText]
                          }];
    }
	
    //score
    if (weakSelf.restaurant.score) {
        [info addObject:@{@"type": @"score",
                          @"cellID":@"subtitle",
                          @"title": [NSString stringWithFormat:@"Total score: %.1f", weakSelf.restaurant.score.floatValue],
                          @"detail": [NSString stringWithFormat:@"%@", weakSelf.restaurant.scoreComponentsText]
                          }];
    }
    
    //footer
    [info addObject:@{
                      @"type": @"footer",
                      @"cellID": @"foursquare",
                      @"height": @100,
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
	if (info[@"title"]) cell.textLabel.text = info[@"title"];
	if (info[@"detail"]) cell.detailTextLabel.text = info[@"detail"];
	if (info[@"image"]) cell.imageView.image = [UIImage imageNamed:info[@"image"]];
    if (info[@"accessory"]) {
        if ([info[@"accessory"] isEqualToString:@"disclosure"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
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

- (void)dealloc{
    DDLogVerbose(@"Card dismissed: %@", _restaurant.name);
}
@end
