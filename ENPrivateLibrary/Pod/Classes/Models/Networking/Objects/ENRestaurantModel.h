//
//  ENRestaurantModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"
#import "ENPriceModel.h"
#import "ENContactModel.h"
#import "ENLocationModel.h"
#import "ENCategoryModel.h"
#import "ENStatsModel.h"
#import "ENPhotosModel.h"
#import "ENTagsModel.h"
#import "ENAttributesModel.h"
#import "ENScoreModel.h"

@interface ENRestaurantModel : JSONModel

@property (nonatomic, strong) NSString *identifier; // id
// TODO: __v
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) UIColor *ratingColor;
@property (nonatomic, strong) NSString *name;
// TODO: delivery
@property (nonatomic) BOOL hasMenu;
// TODO: hours
// TODO: popular
@property (nonatomic, strong) NSString *vendorURL; // vendorUrl
@property (nonatomic, strong) ENPriceModel *price;
@property (nonatomic, strong) ENContactModel *contact;
@property (nonatomic, strong) ENLocationModel *location;
@property (nonatomic, strong) NSArray <NSString *> *foodImageURL; // food_image_url
@property (nonatomic, strong) NSArray <ENCategoryModel *> *categories;
@property (nonatomic, strong) ENStatsModel *stats;
@property (nonatomic, strong) ENPhotosModel *photos;
@property (nonatomic, strong) ENTagsModel *tags;
@property (nonatomic, strong) ENAttributesModel *attributes;
@property (nonatomic, strong) ENScoreModel *score;

@end
