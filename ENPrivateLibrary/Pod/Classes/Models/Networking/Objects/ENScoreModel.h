//
//  ENScoreModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@interface ENScoreModel : JSONModel

@property (nonatomic, strong) NSNumber *totalScore; // total_score
@property (nonatomic, strong) NSNumber *modeScore; // mode_score
@property (nonatomic, strong) NSNumber *timeScore; // time_score
@property (nonatomic, strong) NSNumber *priceScore; // price_score
@property (nonatomic, strong) NSNumber *commentScore; // comment_score
@property (nonatomic, strong) NSNumber *distanceScore; // distance_score
@property (nonatomic, strong) NSNumber *cuisineScore; // cuisine_score
@property (nonatomic, strong) NSNumber *ratingScore; // rating_score
@property (nonatomic, strong) NSNumber *averageDistance; // avgDistance
@property (nonatomic, strong) NSNumber *averagePrice; // avgPrice
@property (nonatomic, strong) NSNumber *averageRating; // avgRating
//@property (nonatomic, strong) NSDate *localTime; // local_time
@property (nonatomic, strong) NSNumber *averageLike; // avgLike

@end
