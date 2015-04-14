//
//  ENMapViewController.m
//  EatNow
//
//  Created by Lei Zhang on 2/23/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENMapViewController.h"
#import "ENUtil.h"
#import "ENMapManager.h"
#import "ENLocationManager.h"

@import AddressBook;

@interface ENMapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPlacemark *destination;
@property (nonatomic, strong) NSTimer *refreshtimer;
@property (nonatomic, assign) BOOL firstTimeShowRoute;
@property (nonatomic, strong) ENLocationManager *locationManager;
@end

@implementation ENMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.destination = self.restaurant.placemark;
	self.title = self.restaurant.name;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];

    CLLocationCoordinate2D centerCoordinate = [ENLocationManager cachedCurrentLocation].coordinate;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 1000, 1000);
    self.mapView.showsUserLocation = YES;
	_firstTimeShowRoute = YES;
	_locationManager = [ENLocationManager new];
	
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
	
	//add annotation
	MKPointAnnotation *destinationAnnotation = [[MKPointAnnotation alloc] init];
	destinationAnnotation.coordinate = _destination.coordinate;
	destinationAnnotation.title = _restaurant.name;
	destinationAnnotation.subtitle = _restaurant.placemark.addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
	[self.mapView addAnnotation:destinationAnnotation];
	[self.mapView selectAnnotation:destinationAnnotation animated:YES];
	
    // ---- Start searching ----
	//[ENUtil showWatingHUB];
    
    //request location
	[self requestRoute:nil];
	
    //schedule timer
	[_refreshtimer invalidate];
	_refreshtimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requestRoute:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[_refreshtimer invalidate];
}

- (void)requestRoute:(NSTimer *)timer{
	[_locationManager getLocationWithCompletion:^(CLLocation *location) {
		[[ENMapManager new] findDirectionsTo:location completion:^(MKDirectionsResponse *response, NSError *error) {
			//[ENUtil dismissHUD];
			
			if (!response) {
				//[ENUtil showFailureHUBWithString:@"Please retry"];
				DDLogError(@"error:%@", error);
			}
			else {
				
				//add overlay
				MKRoute *route = response.routes[0];
				[self.mapView removeOverlays:_mapView.overlays];
				[self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
			 
				//add ETA
				NSString *time = [ENUtil getStringFromTimeInterval:route.expectedTravelTime * 0.75];
				self.title = [NSString stringWithFormat:@"%@ (%@)", _restaurant.name, time];
				
				if (_firstTimeShowRoute) {
					//change region
					CLLocationCoordinate2D from = location.coordinate;
					CLLocation *center = [[CLLocation alloc] initWithLatitude:(from.latitude + _destination.coordinate.latitude)/2 longitude:(from.longitude + _destination.coordinate.longitude)/2];
					MKCoordinateSpan span = MKCoordinateSpanMake(fabs(from.latitude - _destination.coordinate.latitude)*1.5, fabs(from.longitude - _destination.coordinate.longitude)*1.5);
					[self.mapView setRegion:MKCoordinateRegionMake(center.coordinate, span) animated:YES];
				}
				_firstTimeShowRoute = NO;
			}
		}];
	}];
}

- (IBAction)cancel:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 10.0;
    renderer.strokeColor = [UIColor colorWithRed:0.224 green:0.724 blue:1.000 alpha:0.800];
	renderer.fillColor = [UIColor blueColor];
    return renderer;
}

@end
