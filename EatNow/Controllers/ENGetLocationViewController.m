//
//  ENGetLocationViewController.m
//  EatNow
//
//  Created by Zitao Xiong on 5/5/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENGetLocationViewController.h"
#import "UIWindow+Extensions.h"
#import "ENMainViewController.h"
#import "ENLocationManager.h"
#import "FBKVOController+Binding.h"
#import "extobjc.h"
#import "EatNow-Swift.h"

@interface ENGetLocationViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet ApplicationButton *enableButton;
@property (nonatomic, assign) BOOL gettingLocation;
@end

@implementation ENGetLocationViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindKeypath:@keypath(self.gettingLocation) withChangeBlock:^(NSNumber *change) {
        if (change.boolValue) {
            self.enableButton.enabled = NO;
        }
        else {
            self.enableButton.enabled = YES;
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (IBAction)onEnableButton:(id)sender {
    self.gettingLocation = YES;
    [[ENLocationManager sharedInstance] getLocationWithCompletion:^(CLLocation *location, INTULocationAccuracy achievedAccuracy, ENLocationStatus status) {
        self.gettingLocation = NO;
        if (status == INTULocationStatusSuccess) {
            ENMainViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENMainViewController"];
            [UIWindow mainWindow].rootViewController = vc;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if ([ENLocationManager locationServicesState] == INTULocationServicesStateAvailable) {
        ENMainViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENMainViewController"];
        [UIWindow mainWindow].rootViewController = vc;
    }
}

@end
