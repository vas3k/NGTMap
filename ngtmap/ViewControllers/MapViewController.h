//
//  MapViewController.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#include "Transport.h"
#import "Car.h"
#import "Route.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) Route *route;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIButton *updateMapButton;
@property (nonatomic, retain) NSMutableArray *transport;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) Car *selectedCar;
@property (nonatomic, retain) IBOutlet UIView *detailsView;
@property (nonatomic, retain) IBOutlet UILabel *detailsNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailsSpeedLabel;
@property (nonatomic, retain) IBOutlet UILabel *detailsTimetableLabel;

@property (nonatomic, retain) IBOutlet UIButton *deleteTransportButton;
@property (nonatomic, retain) IBOutlet UIButton *refreshButton;
@property (nonatomic, retain) IBOutlet UIButton *locationButton;
@property (nonatomic, retain) IBOutlet UIButton *removeRouteButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport;
- (void)addTransport:(Transport *)newTransport;
- (void)removeTransport:(Transport *)oldTransport;
- (void)addRoute:(Route *)newRoute;
- (void)showRoute;

- (IBAction)clearRoute:(id)sender;
- (IBAction)removeMe:(id)sender;
- (IBAction)updateTransport:(id)sender;
- (IBAction)updateLocation:(id)sender;

- (void)carsLoaded;
- (void)carsLoadError;

@end
