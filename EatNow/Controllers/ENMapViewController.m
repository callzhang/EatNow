//
//  ENMapViewController.m
//  EatNow
//
//  Created by Lei Zhang on 2/23/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENMapViewController.h"
#import "ENUtil.h"
#import "ENServerManager.h"
@import AddressBook;

@interface ENMapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPlacemark *destination;
@property (nonatomic, strong) NSTimer *refreshtimer;
@property (nonatomic, assign) BOOL firstTimeShowRoute;
@end

@implementation ENMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.destination = self.restaurant.placemark;
	self.title = self.restaurant.name;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
    CLLocationCoordinate2D centerCoordinate = [ENServerManager sharedInstance].currentLocation.coordinate;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 500, 500);
    self.mapView.showsUserLocation = YES;
	_firstTimeShowRoute = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // add mark for me
    //TODO
    
    // ---- Start searching ----
    [ENUtil showWatingHUB];
    
	[self requestRoute:nil];
	
	[_refreshtimer invalidate];
	_refreshtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requestRoute:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[_refreshtimer invalidate];
}

- (void)requestRoute:(NSTimer *)timer{
	MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:[ENServerManager sharedInstance].currentLocation.coordinate addressDictionary:nil];
	
	MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
	MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:self.destination];
	//routing
	[self findDirectionsFrom:fromItem to:toItem];
}


#pragma mark - Private

- (void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.destination = destination;
    request.transportType = MKDirectionsTransportTypeWalking;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
         
         [ENUtil dismissHUD];
         
         if (error) {
             
             DDLogError(@"error:%@", error);
         }
         else {
             DDLogInfo(@"Routing Successful");

             //add overlay
             MKRoute *route = response.routes[0];
             [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
			 
			 //add ETA
			 NSString *time = [ENUtil getStringFromTimeInterval:route.expectedTravelTime * 0.75];
			 self.title = [NSString stringWithFormat:@"%@ (%@)", _restaurant.name, time];
             
			if (_firstTimeShowRoute) {
				//add annotation
				 MKPointAnnotation *destinationAnnotation = [[MKPointAnnotation alloc] init];
				 destinationAnnotation.coordinate = _destination.coordinate;
				 destinationAnnotation.title = _restaurant.name;
				 destinationAnnotation.subtitle = _restaurant.placemark.addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
				 [self.mapView addAnnotation:destinationAnnotation];
				 [self.mapView selectAnnotation:destinationAnnotation animated:YES];
				
				//change region
				CLLocationCoordinate2D from = [ENServerManager sharedInstance].currentLocation.coordinate;
				CLLocation *center = [[CLLocation alloc] initWithLatitude:(from.latitude + _destination.coordinate.latitude)/2 longitude:(from.longitude + _destination.coordinate.longitude)/2];
				MKCoordinateSpan span = MKCoordinateSpanMake(abs(from.latitude - _destination.coordinate.latitude)*1.5, abs(from.longitude - _destination.coordinate.longitude)*1.5);
				[self.mapView setRegion:MKCoordinateRegionMake(center.coordinate, span) animated:YES];
			 }
			 _firstTimeShowRoute = NO;
         }
     }];
}


#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 10.0;
    renderer.strokeColor = [UIColor colorWithRed:0.224 green:0.724 blue:1.000 alpha:0.500];
	renderer.fillColor = [UIColor blueColor];
    return renderer;
}

@end
