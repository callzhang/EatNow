//
//  ENHistoryViewCell.m
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AMRatingControl.h"

@implementation ENHistoryViewCell

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setRestaurant:(ENRestaurant *)restaurant{
    _restaurant = restaurant;
    [self.background setImageWithURL:[NSURL URLWithString:self.restaurant.imageUrls.firstObject]];
    self.title.text = _restaurant.name;
    self.subTitile.text = _restaurant.cuisineStr;
}

- (void)setRate:(NSInteger)rate{
    //rating
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-yellow"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0)
                                                                          emptyImage:emptyImageOrNil
                                                                          solidImage:solidImageOrNil
                                                                        andMaxRating:5];
    [imagesRatingControl setStarSpacing:3];
    imagesRatingControl.rating = rate + 3;
    [self.rating addSubview:imagesRatingControl];
}

@end
