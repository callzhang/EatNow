//
// Person.h
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

#import <Foundation/Foundation.h>
@import CoreLocation;
@import MapKit;

@interface Restaurant : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *imageUrls;
@property (nonatomic, strong) NSArray *cuisines;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *reviews;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSDictionary *json;
@property (nonatomic, strong) MKPlacemark *placemark;
- (NSString *)pricesStr;
- (NSString *)cuisineStr;
- (double)distance;
- (BOOL)validate;
@end
