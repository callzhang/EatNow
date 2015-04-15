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
@property (nonatomic, strong) ENMapManager *mapManager;
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
    _mapManager = [[ENMapManager alloc] initWithMap:self.mapView];
    self.mapView.delegate = _mapManager;
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
    [self startRoute];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[_mapManager cancelRouting];
}

- (void)startRoute{
	[self.mapManager routeToLocation:_restaurant.location repeat:15 completion:^(NSTimeInterval length, NSError *error) {
        if (error) {
            ENLogError(@"Failed to route to restaurant %@", _restaurant.name);
        }
    }];
}

- (IBAction)cancel:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload{
    [self.mapManager cancelRouting];
}

@end
