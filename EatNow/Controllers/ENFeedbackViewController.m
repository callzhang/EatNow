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

@interface ENFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *didnotGoButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (nonatomic, strong) ENRestaurant *restaurant;

@end

@implementation ENFeedbackViewController
@synthesize snap;
+ (instancetype)viewController {
    ENFeedbackViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENFeedbackViewController"];
    return vc;
}

- (void)didChangedToFrontCard{
    if (self.backgroundImageView.image) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image": self.backgroundImageView.image}];
    }
}

- (void)setHistory:(NSDictionary *)history{
    _history = history;
    _restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:history[@"restaurant"]];

    self.titleLabel.text = _restaurant.name;
    self.addressLabel.text = _restaurant.streetText;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_history) {
        [self.backgroundImageView setImageWithURL:[NSURL URLWithString:_restaurant.imageUrls.firstObject] placeholderImage:nil];
        NSNumber *like = _history[@"like"];
        [self addRatingOnView:self.ratingView withRating:like.floatValue+3];
    }
}

- (void)addRatingOnView:(UIView *)view withRating:(NSInteger)rating{
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-feedback-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-feedback-star-yellow"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:emptyImageOrNil solidImage:solidImageOrNil andMaxRating:5];
    [imagesRatingControl setStarSpacing:3];
    imagesRatingControl.rating = rating;
    [view addSubview:imagesRatingControl];
}

- (IBAction)onDidnotGoButton:(id)sender {
}

- (IBAction)onRateButton:(id)sender {
}

@end
