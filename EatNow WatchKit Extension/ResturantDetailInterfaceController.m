//
//  ResturantDetailInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ResturantDetailInterfaceController.h"
#import "Restaurant.h"
#import "ENLocationManager.h"


@interface ResturantDetailInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *resturantName;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *resturantMap;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *resturantMoreInfo;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *resturantNameIMGoing;
@property (nonatomic, strong) Restaurant *restaurant;
@end


@implementation ResturantDetailInterfaceController

- (void)awakeWithContext:(Restaurant *)context {
    [super awakeWithContext:context];
    if (!context) {
        return;
    }
    self.restaurant = context;
    self.resturantName.text = self.restaurant.name;
    
    CGFloat scale = 2;
    CLLocationCoordinate2D from = [ENLocationManager cachedCurrentLocation].coordinate;
    CLLocation *_destination = self.restaurant.location;
    CLLocation *center = [[CLLocation alloc] initWithLatitude:(from.latitude + _destination.coordinate.latitude)/2 longitude:(from.longitude + _destination.coordinate.longitude)/2];
	MKCoordinateSpan span = MKCoordinateSpanMake(fabs(from.latitude - _destination.coordinate.latitude)*scale, fabs(from.longitude - _destination.coordinate.longitude)*scale);
    [self.resturantMap setRegion:MKCoordinateRegionMake(center.coordinate, span)];
    
    [self.resturantMap addAnnotation:from withPinColor:WKInterfaceMapPinColorPurple];
    [self.resturantMap addAnnotation:_destination.coordinate withPinColor:WKInterfaceMapPinColorRed];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

@end



