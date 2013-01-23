//
//  DetailsViewController.m
//  ngtmap
//
//  Created by vas3k on 15.02.12.
//

#import "DetailsViewController.h"
#import "AppDelegate.h"

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
    [self.transport release];
    [self.icon release];
    [self.numberLabel release];
    [self.stopALabel release];
    [self.stopBLabel release];
    [self.countLabel release];
    [self.favoritesButton release];
    [self.addToMapButton release];
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
    if (self.mapView != nil)
    {
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addOverlay:self.transport.routeLine];
        
        //Union
        MKMapRect mapRect = MKMapRectNull;
        mapRect = ((id<MKOverlay>)self.mapView.overlays.lastObject).boundingMapRect;
        
        //Inset
        CGFloat inset = (CGFloat)(mapRect.size.width * 0.1);
        mapRect = [self.mapView mapRectThatFits:MKMapRectInset(mapRect, inset, inset)];
        
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
    UIImage *resizableGreenButton = [[UIImage imageNamed:@"button_green.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)];
    UIImage *resizableGreenButtonHighlighted = [[UIImage imageNamed:@"button_green_press.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)];
    [self.addToMapButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.addToMapButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    [self.favoritesButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.favoritesButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    
    if (self.transport)
    {
        self.title = [[NSString stringWithFormat:@"%@ %@", self.transport.canonicalType, self.transport.number] capitalizedString];
    }
    else
    {
        self.title = @"Подробности";
    }
    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(55.033333, 82.916667), MKCoordinateSpanMake(0.5, 0.5))];
    
    icon.image = transport.detailsIcon;
    numberLabel.text = transport.number;
    stopALabel.text = [transport.stopA capitalizedString];
    stopBLabel.text = [transport.stopB capitalizedString];
    
    if (transport.inFavorites)
    {
        self.favoritesButton.titleLabel.text = @"Разлюбить";
    }
    else
    {
        self.favoritesButton.titleLabel.text = @"В избранное";
    } 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    if (transport.inFavorites)
    {
        self.favoritesButton.titleLabel.text = @"Разлюбить";
    }
    else
    {
        self.favoritesButton.titleLabel.text = @"В избранное";
    }
}


#pragma mark - MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	if ([overlay isKindOfClass:[MKPolyline class]])
    {
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor colorWithRed:0.98 green:0.49 blue:0.25 alpha:1.0];
		polylineView.lineWidth = 10;
		return polylineView;
	}
	
	return [[MKOverlayView alloc] initWithOverlay:overlay];	
}

@end
