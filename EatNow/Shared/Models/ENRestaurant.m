//
// Person.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ENRestaurant.h"
#import "ENServerManager.h"
#import "TFHpple.h"
#import "ENUtil.h"
#import "ENLocationManager.h"
#import "ENMapManager.h"
@import AddressBook;

@implementation ENRestaurant
+ (instancetype)restaurantWithData:(NSDictionary *)json{
	ENRestaurant *restaurant = [ENRestaurant new];
	NSParameterAssert([json isKindOfClass:[NSDictionary class]]);
	restaurant.json = json;
	
	restaurant.ID = json[@"id"];
	restaurant.url = json[@"url"];
	restaurant.rating = (NSNumber *)json[@"rating"];
	restaurant.reviews = (NSNumber *)json[@"ratingSignals"];
	NSArray *list = json[@"categories"];
	restaurant.cuisines = [list valueForKey:@"global"];
	restaurant.imageUrls = json[@"food_image_url"];
	restaurant.phone = [json valueForKeyPath:@"contact.formattedPhone"];
	restaurant.name = json[@"name"];
	restaurant.price = json[@"price"];
	restaurant.openInfo = [json valueForKeyPath:@"hours.status"];
	restaurant.tips	= [json valueForKeyPath:@"stats.tipCount"];
	//location
	NSDictionary *address = json[@"location"];
	CLLocationDegrees lat = [(NSNumber *)address[@"lat"] doubleValue];
	CLLocationDegrees lon = [(NSNumber *)address[@"lng"] doubleValue];
	CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
	restaurant.location = loc;
	restaurant.distance = (NSNumber *)address[@"distance"];
	//score
	NSDictionary *scores = json[@"score"];
	NSNumber *totalScore = scores[@"total_score"];
	NSParameterAssert(![totalScore isEqual:[NSNull null]]);
	restaurant.score = totalScore;
	if (![restaurant validate]) {
		return nil;
	}
	return restaurant;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.walkDuration = NSTimeIntervalSince1970;
    }
    return self;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Restaurant: %@, rating: %.1f, reviews: %ld, cuisine: %@, price： %@, distance: %.1fkm \n", _name, self.rating.floatValue, (long)_reviews.integerValue, [self cuisineStr], [self pricesStr], [self.distance floatValue]/1000];
	
}


- (NSString *)pricesStr{
    NSMutableString *priceString = [NSMutableString string];
	NSString *currencySign = self.price[@"currency"];
	NSNumber *tier = self.price[@"tier"];
    for (NSUInteger i=0; i<tier.integerValue; i++) {
        [priceString appendString:currencySign];
    }
    return priceString.copy;
}

- (NSString *)cuisineStr{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *key in self.cuisines) {
        [string appendFormat:@"%@, ", key];
    }
    return [string substringToIndex:string.length-2];
}

- (NSString *)twitter{
    return [_json valueForKeyPath:@"twitter.twitter"];
}

- (NSString *)facebook{
    return [_json valueForKeyPath:@"twitter.facebook"];
}

- (NSString *)phoneNumber{
	return [_json valueForKeyPath:@"contact.phone"];
}

- (NSString *)scoreComponentsString{
	NSMutableString *scores = [NSMutableString new];
	[scores appendFormat:@"Rate:%ld ", [(NSNumber *)[_json valueForKeyPath:@"score.rating_score"] integerValue]];
	[scores appendFormat:@"Food:%ld ", [(NSNumber *)[_json valueForKeyPath:@"score.cuisine_score"] integerValue]];
	[scores appendFormat:@"Dist:%ld ", [(NSNumber *)[_json valueForKeyPath:@"score.distance_score"] integerValue]];
	[scores appendFormat:@"Tips:%ld ", [(NSNumber *)[_json valueForKeyPath:@"score.comment_score"] integerValue]];
	[scores appendFormat:@"Price:%ld ", [(NSNumber *)[_json valueForKeyPath:@"score.price_score"] integerValue]];
	[scores appendFormat:@"Time:%ld", [(NSNumber *)[_json valueForKeyPath:@"score.time_score"] integerValue]];
	
	return scores.copy;
}

- (BOOL)validate{
    BOOL good = YES;
	if (!_json) {
		DDLogError(@"Missing json data %@", self);
		return NO;
	}
    if (!_ID) {
        DDLogError(@"Restaurant missing ID %@", self);
        good = NO;
    }
    if (!_name) {
        DDLogError(@"Restaurant missing name %@", self);
        good = NO;
    }
    if (!_imageUrls || _imageUrls.count == 0) {
        DDLogError(@"Restaurant missing image %@", self);
        good = NO;
    }
    if (!_cuisines) {
        DDLogError(@"Restaurant missing cuisine %@", self);
        good = NO;
    }
    if (!_rating) {
        DDLogError(@"Restaurant missing rating %@", self);
        good = NO;
    }
    if (!_price) {
        DDLogError(@"Restaurant missing price %@", self);
		//good = NO;
    }
    if (!_reviews) {
        DDLogWarn(@"Restaurant missing reviews %@", self);
        //good = NO;
    }
    if (!_location) {
        DDLogWarn(@"Restaurant missing location %@", self);
    }
//    if (!_score) {
//        DDLogError(@"Restaurant missing score %@", self);
//        good = NO;
//    }
	if (!self.openInfo) {
		DDLogWarn(@"Resaurant missing open info %@", self);
	}
    
    return good;
}

- (MKPlacemark *)placemark{
	NSDictionary *address = self.json[@"location"];
    if (!_placemark && address && self.location) {
        NSDictionary *addressDict = @{
                                      (__bridge NSString *) kABPersonAddressStreetKey : address[@"address"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCityKey : address[@"city"]?:@"",
                                      (__bridge NSString *) kABPersonAddressStateKey : address[@"state"]?:@"",
                                      (__bridge NSString *) kABPersonAddressZIPKey : address[@"postalCode"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCountryKey : address[@"country"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCountryCodeKey : address[@"cc"]?:@""
                                      };
        CLLocation *loc = self.location;
        _placemark = [[MKPlacemark alloc] initWithCoordinate:loc.coordinate addressDictionary:addressDict];
    }
    return _placemark;
}

- (void)getWalkDurationWithCompletion:(void (^)(NSTimeInterval time, NSError *error))block {
    if (self.walkDuration != NSTimeIntervalSince1970) {
        block(self.walkDuration, nil);
        return;
    }
	
//	[[ENMapManager new] estimatedWalkingTimeToLocation:self.location completion:^(NSTimeInterval length, NSError *error) {
//		if (error) {
//			DDLogError(@"error:%@", error);
//			if (block) block(NSTimeIntervalSince1970, error);
//		}
//		else {
//			self.walkDuration = length;
//			if (block) block(length, nil);
//		}
//	}];
}
@end
