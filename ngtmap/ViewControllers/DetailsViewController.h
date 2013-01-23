//
//  DetailsViewController.h
//  ngtmap
//
//  Created by vas3k on 15.02.12.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Transport.h"
#import "Car.h"

@interface DetailsViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) Transport *transport;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *stopALabel;
@property (nonatomic, retain) IBOutlet UILabel *stopBLabel;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UIButton *favoritesButton;
@property (nonatomic, retain) IBOutlet UIButton *addToMapButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport;
- (void)carsLoaded;
- (void)carsLoadError;
- (void)trassesLoaded:(Transport *)transport;

- (IBAction)showTransportOnMap:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
