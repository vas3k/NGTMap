//
//  MapViewController.h
//  ngtmap
//
//  Created by Vasily Zubarev on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#include "Transport.h"
#import "Car.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIButton *updateMapButton;
@property (nonatomic, retain) NSMutableArray *transport;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) Car *selectedCar;
@property (nonatomic, retain) IBOutlet UIView *detailsView;
@property (nonatomic, retain) IBOutlet UILabel *detailsNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailsSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailsTimetableLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport;
- (void)addTransport:(Transport *)newTransport;
- (void)removeTransport:(Transport *)oldTransport;

- (IBAction)removeMe:(id)sender;
- (IBAction)updateTransport:(id)sender;
- (IBAction)updateLocation:(id)sender;

@end
