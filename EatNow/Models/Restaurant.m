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

#import "Restaurant.h"
#import "ENServerManager.h"
#import "ENUtil.h"
@import AddressBook;

@implementation Restaurant

- (NSString *)description{
    return [NSString stringWithFormat:@"Restaurant: %@, rating: %.1f, reviews: %ld, cuisine: %@, price： %@, distance: %.1fkm", _name, self.rating.floatValue, (long)_reviews.integerValue, [self cuisineStr], [self pricesStr], [self distance]];
    
}


- (NSString *)pricesStr{
    NSMutableString *dollarSign = [@"" mutableCopy];
    for (NSUInteger i=0; i<self.price.integerValue; i++) {
        [dollarSign appendString:@"$"];
    }
    return dollarSign.copy;
}

- (NSString *)cuisineStr{
    return self.cuisines.string;
}

- (double)distance{
    if (!_location) {
        return 0;
    }
    double d = [[ENServerManager sharedInstance].currentLocation distanceFromLocation:_location]/1000;
    return d;
}

- (BOOL)validate{
    BOOL good = YES;
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
        good = NO;
    }
    if (!_reviews) {
        DDLogError(@"Restaurant missing reviews %@", self);
        good = NO;
    }
    if (!_url) {
        DDLogError(@"Restaurant missing url %@", self);
        good = NO;
    }
    if (!_location) {
        DDLogError(@"Restaurant missing location %@", self);
        good = NO;
    }
    if (!_score) {
        DDLogError(@"Restaurant missing score %@", self);
        good = NO;
    }
    
    return good;
}

- (MKPlacemark *)placemark{
    if (!_placemark) {
        NSDictionary *location = self.json[@"location"];
        NSDictionary *coordinates = location[@"coordinate"];
        float lat = [(NSNumber *)coordinates[@"latitude"] floatValue];
        float lon = [(NSNumber *)coordinates[@"longitude"] floatValue];
        NSDictionary *addressDict = @{
                                      (__bridge NSString *) kABPersonAddressStreetKey : [(NSArray *)location[@"display_address"] firstObject]?:@"",
                                      (__bridge NSString *) kABPersonAddressCityKey : location[@"city"]?:@"",
                                      (__bridge NSString *) kABPersonAddressStateKey : location[@"state_code"]?:@"",
                                      (__bridge NSString *) kABPersonAddressZIPKey : location[@"postal_code"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCountryKey : location[@"country_code"]?:@"",
                                      (__bridge NSString *) kABPersonAddressCountryCodeKey : location[@"country_code"]?:@""
                                      };
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        _placemark = [[MKPlacemark alloc] initWithCoordinate:loc.coordinate addressDictionary:addressDict];
    }
    return _placemark;
}
@end
