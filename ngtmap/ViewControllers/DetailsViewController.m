//
//  DetailsViewController.m
//  ngtmap
//
//  Created by vas3k on 15.02.12.
//

#import "DetailsViewController.h"
#import "AppDelegate.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

typedef enum { SectionHeader, SectionButtons, SectionTimetable } Sections;

@implementation DetailsViewController

@synthesize transport;
@synthesize icon, numberLabel, stopALabel, stopBLabel, mapView, countLabel;
@synthesize favoritesButton, addToMapButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.transport = newTransport;
        [self.transport loadCarsTo:self];
        [self.transport loadTrassesTo:self];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.favoritesViewController loadNgtFavorites];
    }
    return self;
}

- (void)dealloc
{
    [(NGTDataSource *)self.transport.transportDataSource cancelAllConnections];
    self.mapView.delegate = nil;
    self.transport = nil;
    self.icon = nil;
    self.numberLabel = nil;
    self.stopALabel = nil;
    self.stopBLabel = nil;
    self.countLabel = nil;
    self.favoritesButton = nil;
    self.addToMapButton = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)carsLoaded
{
    self.countLabel.text = [NSString stringWithFormat:@"На маршруте: %d шт.", [self.transport.cars count]];
    [self.mapView addAnnotations:self.transport.cars];
}

- (void)carsLoadError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ой" 
                                                    message:@"Проблема при загрузке данных об остановках этого транспорта. Извините :(" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Да все ок" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)trassesLoaded:(Transport *)transport
{
    if (self.mapView != nil && self.transport.routeLine.pointCount > 0 ) {
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addOverlay:self.transport.routeLine];
        
        //Union
        MKMapRect mapRect = MKMapRectNull;
        mapRect = ((id<MKOverlay>)self.mapView.overlays.lastObject).boundingMapRect;
        
        //Set
        MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
        [self.mapView setRegion:region animated:YES];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Разукрасим кнопочки
    UIImage *resizableGreenButton = [Utility resizableImageNamed:@"button_green.png"];
    UIImage *resizableGreenButtonHighlighted = [Utility resizableImageNamed:@"button_green_press.png"];
    
    [self.addToMapButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.addToMapButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    [self.favoritesButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.favoritesButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(55.033333, 82.916667), MKCoordinateSpanMake(0.5, 0.5))];
    
    self.mapView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.mapView.layer.borderWidth = 1.0;
    self.mapView.layer.cornerRadius = 8.0;
}

- (void)refreshControls { 
    self.title = [[NSString stringWithFormat:@"%@ %@", self.transport.canonicalType, self.transport.number] capitalizedString];
    icon.image = transport.detailsIcon;
    numberLabel.text = transport.number;
    stopALabel.text = [transport.stopA capitalizedString];
    stopBLabel.text = [transport.stopB capitalizedString];
    
    self.favoritesButton.titleLabel.text = transport.inFavorites ? @"Разлюбить" : @"В избранное";
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshControls];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - IBActions
- (IBAction)showTransportOnMap:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mapViewController addTransport:self.transport];
    [appDelegate.mapViewController.tabBarController setSelectedIndex:3];
}

- (IBAction)addToFavorites:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.favoritesViewController addOrRemoveFromFavorites:self.transport];
    [appDelegate.favoritesViewController.tabBarController setSelectedIndex:1];
    [self refreshControls];
}


#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]])
    {
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor colorWithRed:0.98 green:0.49 blue:0.25 alpha:1.0];
		polylineView.lineWidth = 10;
		return [polylineView autorelease];
	}
	
	return [[[MKOverlayView alloc] initWithOverlay:overlay] autorelease];	
}

@end
