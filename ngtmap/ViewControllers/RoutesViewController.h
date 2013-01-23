//
//  RoutesViewController.h
//  ngtmap
//
//  Created by vas3k on 13.01.13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SelectPointsViewController.h"
#import "NGTDataSource.h"
#import "RouteCell.h"

@interface RoutesViewController : UITableViewController <CLLocationManagerDelegate>

- (IBAction)selectStartPoint:(id)sender;
- (IBAction)selectStopPoint:(id)sender;
- (IBAction)startSearch:(id)sender;
- (void)appendResult:(Route *)route;
- (void)emptyResults;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D startCoordinates;
@property (nonatomic) CLLocationCoordinate2D stopCoordinates;
@property (nonatomic, retain) NGTDataSource *transportDataSource;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *searchButton;
@property (nonatomic, retain) IBOutlet UITableViewCell *topCell;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSMutableArray *routes;

@end
