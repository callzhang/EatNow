//
//  ENRestaurantModel.m
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "ENRestaurantModel.h"
#import "UIColor+PXColors.h"

@implementation ENRestaurantModel

+ (JSONKeyMapper *)keyMapper {
    NSDictionary *map = @{
                          @"id": @"identifier",
                          @"rating": @"rating",
                          @"ratingColor": @"ratingColor",
                          @"name": @"name",
                          @"hasMenu": @"hasMenu",
                          @"vendorUrl": @"vendorURL",
                          @"price": @"price",
                          @"contact": @"contact",
                          @"location": @"location",
                          @"foodImageURL": @"food_image_url",
                          @"categories": @"categories",
                          @"stats": @"stats",
                          @"photos": @"photos",
                          @"tags": @"tags",
                          @"attributes": @"attributes",
                          @"score": @"score"
                          };
    
    return [[JSONKeyMapper alloc] initWithDictionary:map];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}


// TODO: incomplete function
- (void)setRatingColorWithNSString:(NSString *)string{
    self.ratingColor = [UIColor colorWithHexString:string];
}

- (void)setCategoriesWithNSArray:(NSArray *)array {
    NSMutableArray *categories = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        ENCategoryModel *category = [[ENCategoryModel alloc] initWithDictionary:dic error:NULL];
        [categories addObject:category];
    }
    self.categories = [categories copy];
}

@end
