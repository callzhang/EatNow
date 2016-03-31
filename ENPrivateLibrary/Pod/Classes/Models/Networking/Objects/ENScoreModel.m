//
//  ENScoreModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENScoreModel.h"

@implementation ENScoreModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *map = @{
                          @"total_score": @"totalScore",
                          @"mode_score": @"modeScore",
                          @"time_score": @"timeScore",
                          @"price_score": @"priceScore",
                          @"comment_score": @"commentScore",
                          @"distance_score": @"distanceScore",
                          @"cuisine_score": @"cuisineScore",
                          @"rating_score": @"ratingScore",
                          @"avgDistance": @"averageDistance",
                          @"avgPrice": @"averagePrice",
                          @"avgRating": @"averageRating",
//                          @"local_time": @"localTime",
                          @"avgLike": @"averageLike"
                          };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}


@end
