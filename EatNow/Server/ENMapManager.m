//
//  ENMapManager.m
//  Pods
//
//  Created by Lee on 4/14/15.
//
//

#import "ENMapManager.h"
#import "ENUtil.h"
//#import "ENServerManager.h"
//#import "INTULocationManager.h"
#import "ENLocationManager.h"
//@import AddressBook;


@implementation ENMapManager
- (void)findDirectionsTo:(CLLocation *)location completion:(void (^)(MKDirectionsResponse *response, NSError *error))block{
	CLLocation *currentLocation = [ENLocationManager cachedCurrentLocation];
	if (currentLocation) {
		MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:currentLocation.coordinate addressDictionary:nil];
		MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
		MKPlacemark *pm = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
		MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:pm];
		//routing
		[self findDirectionsFrom:fromItem to:toItem completion:block];
	}else{
		if (block) {
			NSError *err = [NSError errorWithDomain:@"EatNow" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Current location not availble"}];
			block(nil, err);
		}
	}
}

- (void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination completion:(void (^)(MKDirectionsResponse *response, NSError *error))block{
	MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
	request.source = source;
	request.destination = destination;
	request.transportType = MKDirectionsTransportTypeWalking;
	request.requestsAlternateRoutes = NO;
	
	MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
	
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		block(response, error);
	}];
}

- (void)estimatedWalkingTimeToLocation:(CLLocation *)location completion:(void (^)(NSTimeInterval length, NSError *error))block{
	[self findDirectionsTo:location completion:^(MKDirectionsResponse *response, NSError *error) {
		
		if (error) {
			DDLogError(@"error:%@", error);
			if (block) {
				block(-1, error);
			}
		}
		else {
			
			MKRoute *route = response.routes[0];
			if (block) {
				block(route.expectedTravelTime, error);
			}
		}
	}];
}
@end
