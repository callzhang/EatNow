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
#import "ENMapViewController.h"
#import "ENMapManager.h"
@import AddressBook;

@interface ENRestaurantView()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *restautantInfo;

//IB
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *cuisine;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UILabel *openTime;
@property (weak, nonatomic) IBOutlet UILabel *walkingDistance;
@property (weak, nonatomic) IBOutlet UIView *openInfo;
@property (weak, nonatomic) IBOutlet UIView *distanceInfo;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *card;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet MKMapView *map;

//autolayout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoHightRatio;//normal 0.45
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeight;


//internal
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) BOOL isLoadingImage;
@property (nonatomic, strong) ENMapManager *mapManager;
@end


@implementation ENRestaurantView
+ (instancetype)loadView{
    UIViewController *container = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENCardContainer"];
    ENRestaurantView *view = (ENRestaurantView *)container.view;
    NSParameterAssert([view isKindOfClass:[ENRestaurantView class]]);
	view.rating.layer.cornerRadius = 10;
    return view;
}

//initialization method
- (void)setRestaurant:(Restaurant *)restaurant{
	_restaurant = restaurant;
    //table view data
	[self prepareData];
	
	//update view
    self.status = ENRestaurantViewStatusCard;
    [self updateLayoutConstraintValue];
    
    //map
    self.mapManager = [[ENMapManager alloc] initWithMap:self.map];
    self.map.region = MKCoordinateRegionMakeWithDistance(_restaurant.location.coordinate, 1000, 1000);
    self.map.showsUserLocation = YES;
    self.map.delegate = _mapManager;
    
    //image
    _currentImageIndex = -1;
    [self loadNextImage];
    NSString *tempUrl = [NSString stringWithFormat:@"http://foursquare.com/v/%@", restaurant.ID];
    [self parseFoursquareWebsiteForImagesWithUrl:tempUrl completion:^(NSArray *imageUrls, NSError *error) {
        if (!imageUrls) {
            ENLogError(@"Failed to parse foursquare %@", restaurant.url);
            return;
        }
		
        restaurant.imageUrls = imageUrls;
    }];
    
    //UI
    self.name.text = restaurant.name;
    self.cuisine.text = restaurant.cuisineStr;
    self.price.text = restaurant.pricesStr;
    self.rating.text = [NSString stringWithFormat:@"%ld", (long)restaurant.rating.integerValue];
    //self.reviews.text = [NSString stringWithFormat:@"%lu", (long)restaurant.reviews.integerValue];
    self.walkingDistance.text = [NSString stringWithFormat:@"%.1fkm", restaurant.distance.floatValue/1000];//TODO: add waking time api
    self.openTime.text = restaurant.openInfo;
}

- (void)switchToStatus:(ENRestaurantViewStatus)status withFrame:(CGRect)frame{
    static NSTimer *nextImageDelay;
    [nextImageDelay invalidate];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = frame;
        self.status = status;
        [self updateLayoutConstraintValue];
    } completion:^(BOOL finished) {
        if (status == ENRestaurantViewStatusDetail) {
            nextImageDelay = [NSTimer bk_scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
                [self loadNextImage];
            } repeats:NO];
        }
    }];
    
    if (status == ENRestaurantViewStatusCard && self.map.frame.size.height > 0) {
        [self toggleMap:nil];
    }
}

- (void)didChangedToFrontCard{
    if (self.imageView.image) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image":self.imageView.image}];
    }
}

#pragma mark - UI
- (IBAction)go:(id)sender {
    if (self.map.frame.size.height == 0) {
        [self toggleMap:nil];
    }
    
    [self.mapManager routeToLocation:_restaurant.location repeat:10 completion:^(NSTimeInterval length, NSError *error) {
        self.walkingDistance.text = [NSString stringWithFormat:@"%@ Min Walking", @(length/60)];
    }];
}

- (IBAction)toggleMap:(id)sender{
    if (self.map.frame.size.height == 0) {
        //show
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGFloat tableHeight = self.tableView.frame.size.height;
            self.mapHeight.constant = tableHeight;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            //
        }];
    }else{
        //hide
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.mapHeight.constant = 0;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.mapManager cancelRouting];
        }];
    }
}

- (void)updateLayoutConstraintValue{
    //radio
    float multiplier = self.status == ENRestaurantViewStatusCard ? 1:0.45;
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
        self.pageControl.alpha = 0;
        self.goButton.alpha = 0;
    }else{
        self.distanceInfo.alpha = 0;
        self.openInfo.alpha = 0;
        self.pageControl.alpha = 1;
        self.goButton.alpha = 1;
    }
}

#pragma mark - Private

- (void)parseFoursquareWebsiteForImagesWithUrl:(NSString *)urlString completion:(void (^)(NSArray *imageUrls, NSError *error))block{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        //DDLogVerbose(@"Parsed img urls: %@", images);
        block(images, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ENLogError(@"Failed to download website %@", urlString);
        block(nil, error);
    }];;
    [op start];
}

- (void)loadNextImage{
    if (self.status == ENRestaurantViewStatusCard && _currentImageIndex != -1) {
        DDLogVerbose(@"Skip loading next image in card mode");
        return;
    }
    if (_isLoadingImage) {
        DDLogVerbose(@"Loading image, skip");
        return;
    }
    if (_restaurant.imageUrls.count == 1 && self.imageView.image) {
        DDLogVerbose(@"Only one image, skip");
        return;
    }
    
    NSInteger nextIdx = (_currentImageIndex + 1) % self.restaurant.imageUrls.count;
    
    //display if downloaded
    if (self.restaurant.images.count > nextIdx) {
        if (self.restaurant.images[nextIdx] != [NSNull null]) {
            _currentImageIndex = nextIdx;
            self.pageControl.currentPage = nextIdx;
            [self showImage:self.restaurant.images[nextIdx]];
            return;
        }
    }
    
    //download
    self.isLoadingImage = YES;
    [self.loading startAnimating];
    NSURL *url = [NSURL URLWithString:self.restaurant.imageUrls[nextIdx]];
    //download first
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:self.imageView.image success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		_currentImageIndex = nextIdx;
		_isLoadingImage = NO;
		[self.loading stopAnimating];
		NSMutableArray *images = _restaurant.images.mutableCopy ?: [NSMutableArray arrayWithCapacity:_restaurant.imageUrls.count];
		while (images.count <= _currentImageIndex) {
			[images addObject:[NSNull null]];
		}
		images[_currentImageIndex] = image;
		_restaurant.images = images.copy;
		
		[self showImage:image];
		
		self.pageControl.currentPage = nextIdx;
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		ENLogError(@"*** Failed to download image with error: %@", error);
	}];
}

- (void)showImage:(UIImage *)image{
    if (self.loading.isAnimating) {
        [self.loading stopAnimating];
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


- (void)prepareData{
	NSParameterAssert(_restaurant.json);
	NSMutableArray *info = [NSMutableArray new];
	if (self.restaurant.placemark) {
		[info addObject:@{@"type": @"address",
						  @"cellID": @"mapCell",
						  @"image": @"eat-now-card-details-view-map-icon",
						  @"title": _restaurant.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStreetKey],
						  @"detail":[NSString stringWithFormat:@"%.1fkm away", _restaurant.distance.floatValue/1000],
                          @"action": ^{
            //action to open map
            [self toggleMap:nil];
        }}];
	}
	if (self.restaurant.openInfo) {
		[info addObject:@{@"type": @"address",
						  @"cellID": @"cell",
						  @"image": @"eat-now-card-details-view-time-icon",
						  @"title": self.restaurant.openInfo}];
	}
	if (self.restaurant.phone) {
		[info addObject:@{@"type": @"phone",
						  @"cellID": @"cell",
						  @"image": @"eat-now-card-details-view-phone-icon",
						  @"title": self.restaurant.phone}];
	}
	if (self.restaurant.url) {
		[info addObject:@{@"type": @"url",
						  @"cellID": @"cell",
						  @"image": @"eat-now-card-details-view-web-icon",
						  @"title": self.restaurant.url}];
	}
	if (_restaurant.reviews) {
		[info addObject:@{@"type": @"reviews",
						  @"cellID": @"cell",
						  @"image": @"eat-now-card-details-view-twitter-icon",
						  @"title": [NSString stringWithFormat:@"%@ tips", _restaurant.reviews],
                          @"accessory": @"disclosure"}];
	}
	
	self.restautantInfo = info.copy;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.restautantInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
	NSDictionary *info = self.restautantInfo[indexPath.row];
	cell = [tableView dequeueReusableCellWithIdentifier:info[@"cellID"]];
	cell.textLabel.text = info[@"title"];
	if (info[@"detail"]) cell.detailTextLabel.text = info[@"detail"];
	cell.imageView.image = [UIImage imageNamed:info[@"image"]];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
