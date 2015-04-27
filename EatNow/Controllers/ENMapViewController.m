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
#import "extobjc.h"

@import AddressBook;

@interface ENMapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView; //this is not connected? can we delete it
@property (nonatomic, strong) MKPlacemark *destination;
@property (nonatomic, strong) ENMapManager *mapManager;
@end

@implementation ENMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.destination = self.restaurant.placemark;
	self.title = self.restaurant.name;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];

    CLLocationCoordinate2D centerCoordinate = [ENLocationManager cachedCurrentLocation].coordinate;
    
    self.mapView.region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 1000, 1000);
    self.mapView.showsUserLocation = YES;
    
    self.mapManager = [[ENMapManager alloc] initWithMap:self.mapView];
    self.mapView.delegate = self.mapManager;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	//add annotation
	MKPointAnnotation *destinationAnnotation = [[MKPointAnnotation alloc] init];
	destinationAnnotation.coordinate = self.destination.coordinate;
	destinationAnnotation.title = self.restaurant.name;
	destinationAnnotation.subtitle = self.restaurant.placemark.addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
	[self.mapView addAnnotation:destinationAnnotation];
	[self.mapView selectAnnotation:destinationAnnotation animated:YES];
    // ---- Start searching ----
    
    [self startRoute];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[self.mapManager cancelRouting];
}

- (void)startRoute{
    @weakify(self);
	[self.mapManager routeToRestaurant:self.restaurant repeat:15 completion:^(NSTimeInterval length, NSError *error) {
        @strongify(self);
        if (error) {
            ENLogError(@"Failed to route to restaurant %@", self.restaurant.name);
        }
    }];
}

//ZITAO: is this method being using?
- (IBAction)cancel:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

//ZITAO: didiUnload is deprecated, should be moved into didDisapplear?
- (void)viewDidUnload{
    [self.mapManager cancelRouting];
}
@end
