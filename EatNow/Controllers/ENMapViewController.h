//
//  ENMapViewController.h
//  EatNow
//
//  Created by Lei Zhang on 2/23/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface ENMapViewController : UIViewController
@property (nonatomic, strong) CLPlacemark *destination;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end
