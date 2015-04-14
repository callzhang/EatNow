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

@interface RestaurantRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel* textLabel;
@end

@implementation RestaurantRowController

@end

@interface ResturantDetailInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *restaurantNameGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *resturantName;
@property (weak, nonatomic) IBOutlet WKInterfaceMap *resturantMap;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *resturantNameIMGoing;
@property (nonatomic, strong) Restaurant *restaurant;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *address;

@property (weak, nonatomic) IBOutlet WKInterfaceTable *detailTable;

@property (nonatomic, strong) NSArray *items;

@end


@implementation ResturantDetailInterfaceController

- (void)awakeWithContext:(Restaurant *)context {
    [self setTitle:@"Close"];
    
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:self.restaurant.imageUrls.firstObject];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *placeholder = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.restaurantNameGroup setBackgroundImage:placeholder];
        });
    });
    
    NSMutableArray *items = [self loadDetailRows];
    [items addObject:@"More Info"];

    [self loadTableWithArray:items];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (void)loadTableWithArray:(NSMutableArray *)items {
    [self.detailTable setNumberOfRows:items.count withRowType:@"RestaurantRowController"];
    NSInteger rowCount = [items count];
    
    for (NSInteger i = 0; i < rowCount; i++) {
        NSString* itemText = items[i];
        
        RestaurantRowController* row = [self.detailTable rowControllerAtIndex:i];
        [row.textLabel setText:itemText];
    }
    
    self.items = items;
}

- (NSMutableArray *)loadDetailRows {
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    if (self.restaurant.phone) {
        [mutableArray addObject:self.restaurant.phone];
    }
    
//    if (self.restaurant.opentil?) {
//        <#statements#>
//    }
    
    return mutableArray;
}

- (NSMutableArray *)loadMoreDetailRows {
    NSMutableArray *mutableArray = [self loadDetailRows];
    
    if (self.restaurant.phone) {
        [mutableArray addObject:self.restaurant.phone];
    }
    
    //    if (self.restaurant.opentil?) {
    //        <#statements#>
    //    }
    
    return mutableArray;
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSString *text = self.items[rowIndex];
    if ([text isEqualToString:@"More Info"]) {
        [self loadTableWithArray:[self loadMoreDetailRows]];
    }
}
@end



