//
//  SelectPointsViewController.m
//  ngtmap
//
//  Created by vas3k on 15.01.13.
//
//

#import "SelectPointsViewController.h"
#import "RoutesViewController.h"
#import "Utility.h"

@interface SelectPointsViewController ()

@end

@implementation SelectPointsViewController

@synthesize mapView, okButton, pointNumber, parent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(RoutesViewController *)theParent pointNumber:(NSInteger)thePointNumber
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parent = theParent;
        self.pointNumber = thePointNumber;
    }
    return self;
}

- (void)dealloc
{
    self.mapView.delegate = nil;
    [self.mapView release];
    [self.okButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(55.033333, 82.916667), MKCoordinateSpanMake(0.1, 0.1))];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:lpgr];
    [lpgr release];
        
    if (self.pointNumber == 0) // стартовая точка
    {
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.coordinate = self.parent.startCoordinates;
        [self.mapView addAnnotation:annot];
        [annot release];
    }
    else if (self.pointNumber == 1) // конечная точка
    {
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        annot.coordinate = self.parent.stopCoordinates;
        [self.mapView addAnnotation:annot];
        [annot release];
    }    
    
    UIImage *resizableYellowButton = [Utility resizableImageNamed:@"button_yellow.png"];
    UIImage *resizableYellowButtonHighlighted = [Utility resizableImageNamed:@"button_yellow_press.png"];
    [self.okButton setBackgroundImage:resizableYellowButton forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:resizableYellowButtonHighlighted forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
    if (self.pointNumber == 1)
        self.parent.stopCoordinates = touchMapCoordinate;
    else
        self.parent.startCoordinates = touchMapCoordinate;
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:annot];
    [annot release];
}

- (IBAction)okButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
