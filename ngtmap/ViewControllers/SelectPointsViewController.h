//
//  SelectPointsViewController.h
//  ngtmap
//
//  Created by vas3k on 15.01.13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class RoutesViewController;

@interface SelectPointsViewController : UIViewController <MKMapViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(RoutesViewController *)theParent pointNumber:(NSInteger)thePointNumber;
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)okButtonPressed:(id)sender;

@property (nonatomic, assign) RoutesViewController *parent;
@property (nonatomic) NSInteger pointNumber;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIButton *okButton;

@end
