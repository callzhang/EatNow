//
//  ENFeedbackViewController.m
//  EatNow
//
//  Created by Zitao Xiong on 5/2/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENFeedbackViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AMRatingControl.h"
#import "ENServerManager.h"
#import "ENMainViewController.h"
#import "extobjc.h"
#import "ReactiveCocoa.h"

@interface ENFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *didnotGoButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (nonatomic, assign) AMRatingControl *ratingControl;
@property (nonatomic, strong) NSNumber *rating;

@end

@implementation ENFeedbackViewController
@synthesize snap;
+ (instancetype)viewController {
    ENFeedbackViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENFeedbackViewController"];
    return vc;
}

- (BOOL)canSwipe {
    return NO;
}

- (void)didChangedToFrontCard{
    if (self.backgroundImageView.image) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image": self.backgroundImageView.image}];
    }
}

- (void)setHistory:(NSDictionary *)history{
    _history = history;
    self.restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:self.history[@"restaurant"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSParameterAssert(self.history);
    NSParameterAssert(self.restaurant);
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.restaurant.imageUrls.firstObject] placeholderImage:nil];
    NSNumber *like = _history[@"like"];
    [self addRatingOnView:self.ratingView withRating:like.floatValue+3];

    self.titleLabel.text = _restaurant.name;
    self.addressLabel.text = _restaurant.streetText;
    
    RAC(self.rateButton, enabled) = [RACSignal combineLatest:@[RACObserve(self, rating)] reduce:^id(NSNumber *rating){
        if (rating) {
            return @(YES);
        }
        
        return @(NO);
    }];
}

- (void)addRatingOnView:(UIView *)view withRating:(NSInteger)rating{
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-feedback-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-feedback-star-yellow"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:emptyImageOrNil solidImage:solidImageOrNil andMaxRating:5];
    [imagesRatingControl setStarSpacing:3];
    imagesRatingControl.rating = rating;
    [view addSubview:imagesRatingControl];
    @weakify(self);
    [imagesRatingControl setEditingChangedBlock:^(NSUInteger rating) {
        @strongify(self);
        self.rating = @(rating);
    }];
    self.ratingControl = imagesRatingControl;
}

- (IBAction)onDidnotGoButton:(id)sender {
    [[ENServerManager shared] cancelSelectedRestaurant:self.history[@"_id"] completion:^(NSError *error) {
       [self.mainViewController dismissFrontCardWithVelocity:CGPointMake(0, 0) completion:^(NSArray *leftcards) {
           
       }];
    }];
}

- (IBAction)onRateButton:(id)sender {
    [[ENServerManager shared] updateHistory:self.history[@"_id"] withRating:[self.rating floatValue] - 3 completion:^(NSError *error) {
        [self.mainViewController dismissFrontCardWithVelocity:CGPointMake(0, 0) completion:^(NSArray *leftcards) {
            
        }];
    }];
}

@end
