//
//  ENMapManager.h
//  Pods
//
//  Created by Lee on 4/14/15.
//
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"
@import MapKit;
@interface ENMapManager : NSObject<MKMapViewDelegate>

- (instancetype)initWithMap:(MKMapView *)map;

- (void)findDirectionsTo:(CLLocation *)location completion:(void (^)(MKDirectionsResponse *response, NSError *error))block;

- (void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination completion:(void (^)(MKDirectionsResponse *response, NSError *error))block;

- (void)estimatedWalkingTimeToLocation:(CLLocation *)location completion:(void (^)(NSTimeInterval length, NSError *error))block;

- (void)routeToRestaurant:(Restaurant *)restaurant repeat:(NSTimeInterval)updateInterval completion:(void (^)(NSTimeInterval length, NSError *error))block;


- (void)addAnnotationForRestaurant:(Restaurant *)restaurant;

- (void)cancelRouting;
@end