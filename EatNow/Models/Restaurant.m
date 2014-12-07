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

@implementation Restaurant

- (NSString *)description{
    return [NSString stringWithFormat:@"Restaurant: %@, rating: %.1f, reviews: %ld, cuisine: %@, price： %@, distance: %.2fkm", _name, _rating, (unsigned long)_reviews, [self cuisineStr], [self pricesStr], [self distance]];
    
}


- (NSString *)pricesStr{
    NSMutableString *dollarSign = [@"" mutableCopy];
    for (NSUInteger i=0; i<self.price; i++) {
        [dollarSign appendString:@"$"];
    }
    return dollarSign.copy;
}

- (NSString *)cuisineStr{
    if (self.cuisines.count == 0) {
        return @"";
    }
    NSMutableString *cuisineStr = [NSMutableString new];
    for (NSString *c in self.cuisines) {
        [cuisineStr appendFormat:@"%@, ", c];
    }
    [cuisineStr deleteCharactersInRange:NSMakeRange(cuisineStr.length-2, 2)];
    return cuisineStr.copy;
}

- (double)distance{
    if (!_location) {
        return 0;
    }
    double d = [[ENServerManager sharedInstance].currentLocation distanceFromLocation:_location]/1000;
    return d;
}
@end
