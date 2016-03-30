//
//  ENLocationModel.h
//  Pods
//
//  Created by Veracruz on 16/3/30.
//
//

#import "JSONModel.h"

@import MapKit;

@interface ENLocationModel : JSONModel

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *countryCode; // cc
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSArray <NSString *> *formattedAddress;
@property (nonatomic) CLLocationDegrees longitude; // lng
@property (nonatomic) CLLocationDegrees latitude; // lat
// TODO: crossStreet
// TODO: geoJSONLocation

@end
