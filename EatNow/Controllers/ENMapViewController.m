//
//  ENMapViewController.m
//  EatNow
//
//  Created by Lei Zhang on 2/23/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENMapViewController.h"
#import "ENUtil.h"

@interface ENMapViewController ()
@end

@implementation ENMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(37.501364, -122.182817);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.906448, 0.878906);
    self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    
    // ---- Start searching ----
    
    [ENUtil showWatingHUB];
    
    // San Francisco Caltrain Station
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(37.7764393,
                                                                       -122.39432299999999);\
    // Mountain View Caltrain Station
    CLLocationCoordinate2D toCoordinate   = CLLocationCoordinate2DMake(37.393879,
                                                                       -122.076327);
    
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate
                                                       addressDictionary:nil];
    
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate
                                                       addressDictionary:nil];
    
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    [self findDirectionsFrom:fromItem
                          to:toItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)findDirectionsFrom:(MKMapItem *)source
                        to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         
         [ENUtil dismissHUD];
         
         if (error) {
             
             NSLog(@"error:%@", error);
         }
         else {
             
             MKRoute *route = response.routes[0];
             
             [self.mapView addOverlay:route.polyline];
         }
     }];
}


#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = [UIColor purpleColor];
    return renderer;
}

@end
