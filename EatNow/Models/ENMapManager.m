//
//  ENMapManager.m
//  Pods
//
//  Created by Lee on 4/14/15.
//
//

#import "ENMapManager.h"
#import "ENUtil.h"
#import "ENLocationManager.h"
#import "NSTimer+BlocksKit.h"
@import AddressBook;

@interface ENMapManager()
@property (nonatomic, strong) NSTimer *repeatTimer;
@property (nonatomic, assign) BOOL firstTimeRoute;
@end

@implementation ENMapManager
- (instancetype)initWithMap:(MKMapView *)map{
    self = [super init];
    if (self) {
        self.map = map;
        self.firstTimeRoute = YES;
        
      
    }
    return self;
}

- (void)findDirectionsTo:(CLLocation *)location completion:(void (^)(MKDirectionsResponse *response, NSError *error))block{
    [[ENLocationManager sharedInstance] getLocationWithCompletion:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        
        NSLog(@"from = %f,%f to = %f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude,location.coordinate.latitude,location.coordinate.longitude);
        
        if (currentLocation) {
            MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:currentLocation.coordinate addressDictionary:nil];
            MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
            MKPlacemark *pm = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
            MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:pm];
            //routing
            [self findDirectionsFrom:fromItem to:toItem completion:block];
        }
        else{
            if (block) {
                NSError *err = [NSError errorWithDomain:@"EatNow" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Current location not availble"}];
                block(nil, err);
            }
        }
    }];
}

- (void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination completion:(void (^)(MKDirectionsResponse *response, NSError *error))block{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    NSLog(@"%f,%f,%f",source.placemark.location.horizontalAccuracy,source.placemark.location.course,source.placemark.location.speed);
    

    request.destination = destination;
    CLLocation *loc = destination.placemark.location;
    CLLocationDistance dist = [loc distanceFromLocation:source.placemark.location];
    if (dist < 1000) {
        request.transportType = MKDirectionsTransportTypeWalking;
    }
    request.requestsAlternateRoutes = YES;
    
    //TODO:只能判断误差不定路径规划
    if (source.placemark.location.horizontalAccuracy <= 0 || source.placemark.location.horizontalAccuracy > 50) {
        NSLog(@"%f,%f",source.placemark.location.coordinate.latitude,source.placemark.location.coordinate.longitude);
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(source.placemark.location.coordinate.latitude, source.placemark.location.coordinate.longitude);
        CLLocation *myloc = [[CLLocation alloc]initWithCoordinate:coordinate altitude:dist horizontalAccuracy:50 verticalAccuracy:0.00000 course:-1.000000 speed:0.00000 timestamp:[NSDate date]];
        MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:myloc.coordinate addressDictionary:nil];
        MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
        request.source = fromItem;
    }
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if(block) block(response, error);
    }];
}

- (void)estimatedWalkingTimeToLocation:(CLLocation *)location completion:(ENRestaurantDirection)block{
    [self findDirectionsTo:location completion:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            DDLogError(@"error:%@", error);
            if (block) {
                block(nil, error);
            }
        }
        else {
            
            MKRoute *route = response.routes[0];
            if (block) {
                block(route, error);
            }
        }
    }];
}

#pragma mark - MAP management
- (void)routeToRestaurant:(ENRestaurant *)restaurant repeat:(NSTimeInterval)updateInterval completion:(void (^)(NSTimeInterval length, NSError *error))block{
    [_repeatTimer invalidate];
    if (!_map) {
        DDLogWarn(@"No map exists, abord routing to restaurant %@", restaurant.name);
        [_repeatTimer invalidate];
        return;
    }
    CLLocation *destination = restaurant.location;
    
    if (self.map.annotations.count == 0) {
        [self addAnnotationForRestaurant:restaurant];
    }
    
    [self findDirectionsTo:destination completion:^(MKDirectionsResponse *response, NSError *error) {
        [[ENLocationManager sharedInstance] getLocationWithCompletion:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
            CLLocation *origin = currentLocation;
            if (!response) {
                //[ENUtil showFailureHUBWithString:@"Please retry"];
                DDLogError(@"error:%@", error);
                if (block) {
                    block(-1, error);
                }
            }
            else {
                
                //add overlay
                MKRoute *route = response.routes[0];
                [self.map removeOverlays:_map.overlays];
                [self.map addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
                
                if (self.firstTimeRoute) {
                    self.firstTimeRoute = NO;
                    //change region
                    CLLocationCoordinate2D from = origin.coordinate;
                    CLLocation *center = [[CLLocation alloc] initWithLatitude:(from.latitude + destination.coordinate.latitude)/2 longitude:(from.longitude + destination.coordinate.longitude)/2];
                    MKCoordinateSpan span = MKCoordinateSpanMake(fabs(from.latitude - destination.coordinate.latitude)*1.5, fabs(from.longitude - destination.coordinate.longitude)*1.5);
                    [self.map setRegion:MKCoordinateRegionMake(center.coordinate, span) animated:YES];
                }
                
                if (block) {
                    block(route.expectedTravelTime, error);
                }
                
                if (updateInterval > 0) {
                    _repeatTimer = [NSTimer bk_scheduledTimerWithTimeInterval:updateInterval block:^(NSTimer *timer) {
                        [[ENLocationManager shared] getLocationWithCompletion:^(CLLocation *loc, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                            [self routeToRestaurant:restaurant repeat:updateInterval completion:block];
                        }];
                    } repeats:NO];
                }
            }
        }];
        
    }];
}

- (void)addAnnotationForRestaurant:(ENRestaurant *)restaurant{
	//add annotation
	[self.map removeAnnotations:_map.annotations];
	MKPointAnnotation *destinationAnnotation = [[MKPointAnnotation alloc] init];
	destinationAnnotation.coordinate = restaurant.location.coordinate;
	destinationAnnotation.title = restaurant.name;
	destinationAnnotation.subtitle = restaurant.placemark.addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
	[self.map addAnnotation:destinationAnnotation];
	[self.map selectAnnotation:destinationAnnotation animated:YES];
}

- (void)cancelRouting{
    [_repeatTimer invalidate];
    self.map = nil;
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
