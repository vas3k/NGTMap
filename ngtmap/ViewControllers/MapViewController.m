//
//  MapViewController.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "MapViewController.h"
#import "Utility.h"
#import <QuartzCore/QuartzCore.h>

const float DEFAULT_LAT = 55.033333;
const float DEFAULT_LON = 82.916667;

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation MapViewController

@synthesize updateTimer, route;
@synthesize mapView, updateMapButton;
@synthesize selectedCar, detailsView, detailsNameLabel, detailsSpeedLabel, detailsTimetableLabel;
@synthesize transport;
@synthesize locationManager;
@synthesize refreshButton, locationButton, removeRouteButton, deleteTransportButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.transport addObject:newTransport];
        [self updateTransport:self];
    }
    return self;
}
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transport = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addTransport:(Transport *)newTransport
{
    if (self.route)
    {
        [self clearRoute:self];
    }
    
    if (![self.transport containsObject:newTransport])
    {
        [self.transport addObject:newTransport];
        [self updateTransport:self];
    }
    
    // Правильно зумим карту, чтобы все влезли    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(DEFAULT_LAT, DEFAULT_LON), MKCoordinateSpanMake(0.3, 0.3))];
    
    MKMapRect zoomRect = MKMapRectNull;
    for (Transport *trans in self.transport)
    {
        for (id <MKAnnotation> annotation in trans.cars)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            if (MKMapRectIsNull(zoomRect))
            {
                zoomRect = pointRect;
            }
            else
            {
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
        }
    }
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

- (void)removeTransport:(Transport *)oldTransport
{
    if ([self.transport containsObject:oldTransport])
    {
        [self.mapView removeOverlay:oldTransport.routeLine];
        [self.transport removeObject:oldTransport];
        
        // Отобразить заново
        [self.mapView removeAnnotations:mapView.annotations];
        for (Transport* trans in self.transport)
        {
            [self.mapView addAnnotations:trans.cars];
        }
    }
}

- (IBAction)updateTransport:(id)sender
{
    if ([self.transport count] < 1) 
    {
        return;
    }
    
    [self.updateMapButton setEnabled:NO];
    
    // Очистить
    [self.mapView removeOverlays:mapView.overlays];
    [self.mapView removeAnnotations:mapView.annotations];
    [self.updateTimer invalidate];
    
    // Загрузить
    for (Transport* trans in self.transport)
    {
        [trans loadCarsTo:self];
    }
    
    // Дальше все отобразит метод carsLoaded (асинхронно, после загрузки)
}

- (void)addRoute:(Route *)newRoute
{    
    self.route = newRoute;
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.transport removeAllObjects];
    [self.transport addObjectsFromArray:newRoute.transport];
    [self.updateTimer invalidate];
    [self.removeRouteButton setHidden:NO];
    [self showRoute];
}

- (void)showRoute
{    
    // Добавим остановки и пересадки
    for (Transport *trans in self.route.transport)
    {
        MKPointAnnotation *startAnnot = [[MKPointAnnotation alloc] init];
        startAnnot.coordinate = trans.stopACoordinates;
        startAnnot.title = trans.stopA;
        [self.mapView addAnnotation:startAnnot];
        [startAnnot release];
        
        MKPointAnnotation *stopAnnot = [[MKPointAnnotation alloc] init];
        stopAnnot.coordinate = trans.stopBCoordinates;
        stopAnnot.title = trans.stopB;
        [self.mapView addAnnotation:stopAnnot];
        [stopAnnot release];
    }
    
    // Добавим линию
    [self.mapView addOverlays:self.route.polylines];
    
    // Зумим карту
    MKMapRect mapRect = MKMapRectNull;
    mapRect = ((id<MKOverlay>)self.mapView.overlays.lastObject).boundingMapRect;
    
    //Inset
    CGFloat inset = (CGFloat)(mapRect.size.width * 0.1);
    mapRect = [self.mapView mapRectThatFits:MKMapRectInset(mapRect, inset, inset)];
    
    //Set
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    [self.mapView setRegion:region animated:YES];    
}

- (void)carsLoaded
{
    if (self.route != nil)
    {
        [self showRoute];
    }
    
    // Отобразить заново
    for (Transport* trans in self.transport)
    {
        [self.mapView addAnnotations:trans.cars];
//        NSLog(@"SHOW TRANSPORT: %@, cars: %@", trans, trans.cars);
        if (trans.routeLine != nil)
            [self.mapView addOverlay:trans.routeLine];
        
    }
    
    
    [self.mapView setShowsUserLocation:YES];
    
    // Ну и контролы
    [self.updateMapButton setEnabled:YES];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                               target:self 
                                             selector:@selector(updateTransport:) 
                                             userInfo:nil 
                                              repeats:YES];
}

- (void)carsLoadError
{
    [self.updateMapButton setEnabled:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                    message:@"Проблема при загрузке данных. Извините :(" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Да все нормально, не расстраивайся" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}


- (IBAction)clearRoute:(id)sender
{
    if (self.route) {
        [self.mapView removeOverlays:self.route.polylines];
        self.route = nil;
    }
    [self.removeRouteButton setHidden:YES];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateTransport:self];
}

- (IBAction)updateLocation:(id)sender
{
    // Запустим обновление геолокации, остальное делает делегат (см методы ниже)
    [self.locationManager startUpdatingLocation];
}

- (IBAction)removeMe:(id)sender
{
    if (self.selectedCar != nil)
    {
        [self removeTransport:self.selectedCar.transport];
    }
    [self.detailsView setHidden:YES];
}

- (void)dealloc {
    self.mapView.delegate = nil;
    self.refreshButton = nil;
    self.locationButton = nil;
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    self.route = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Карта";
    [self.detailsView setHidden:YES];
    
    // Настроить геопозиционирование    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager release]; //this property has retain attribute, so at this point it's retainCount will be 2 instead of 1
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
        
    // Установить положение центра карты. Если в городе - то текущее, если нет - то центр города    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(DEFAULT_LAT, DEFAULT_LON), MKCoordinateSpanMake(0.1, 0.1))];
    
    // Отобразить все автобусы из self.transport, если есть
    for (Transport* trans in self.transport)
    {
        [self.mapView addAnnotations:trans.cars];
    }
    [self.mapView setShowsUserLocation:YES];
    
    UIImage *resizableGreenButton = [Utility resizableImageNamed:@"button_green.png"];
    UIImage *resizableGreenButtonHighlighted = [Utility resizableImageNamed:@"button_green_press.png"];    
    [self.refreshButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.refreshButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    [self.locationButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.locationButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    [self.removeRouteButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.removeRouteButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    
    UIImage *resizableYellowButton = [Utility resizableImageNamed:@"button_yellow.png"];
    UIImage *resizableYellowButtonHighlighted = [Utility resizableImageNamed:@"button_yellow_press.png"];
    [self.deleteTransportButton setBackgroundImage:resizableYellowButton forState:UIControlStateNormal];
    [self.deleteTransportButton setBackgroundImage:resizableYellowButtonHighlighted forState:UIControlStateHighlighted];
    [self.removeRouteButton setHidden:YES];
    
    self.detailsView.layer.cornerRadius = 8.0;
    self.detailsView.layer.borderColor = [UIColor darkGrayColor].CGColor; 
    self.detailsView.layer.borderWidth = 1;
    
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

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)amapView viewForAnnotation:(id)annotation
{
    static NSString *annotationId = @"BusAnnotationIdentifier";
    
    if([annotation isKindOfClass:[Car class]])
    {
        MKAnnotationView *annotationView = [amapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
        if (!annotationView)
        {        
            annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId] autorelease];
        }
        
        // Отображаем кастомные иконки и поворачиваем по азимуту
        Car *annotationCar = (Car *)annotation;
        annotationView.image = annotationCar.icon;
        annotationView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(annotationCar.azimuth));
        [annotationView setCanShowCallout:NO];  
        
        return annotationView;
    }
    
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {
        // Для всех остальных аннотаций - простой пин
        MKPinAnnotationView *annView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"defaultPin"];
        if(!annView){
            annView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"defaultPin"] autorelease];
        }
        
        annView.animatesDrop = YES;
        annView.canShowCallout = YES;
        return annView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[Car class]])
    {
        self.selectedCar = (Car *)view.annotation;
        self.detailsNameLabel.text = [[NSString stringWithFormat:@"%@ №%@", self.selectedCar.transport.canonicalType, self.selectedCar.transport.number] capitalizedString];
        self.detailsTimetableLabel.text = [[self.selectedCar.timetable stringByReplacingOccurrencesOfString:@"|" withString:@"\n"] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        self.detailsSpeedLabel.text = [NSString stringWithFormat:@"Скорость: %@ км/ч", self.selectedCar.speed];
        [self.detailsView setHidden:NO];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    self.selectedCar = nil;
    [self.detailsView setHidden:YES];
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSArray *okColors = [NSArray arrayWithObjects:
                            [UIColor colorWithRed:0.38 green:0.66 blue:0.59 alpha:1.0],
                            [UIColor colorWithRed:0.98 green:0.49 blue:0.25 alpha:1.0],
                            [UIColor colorWithRed:0.26 green:0.25 blue:0.24 alpha:1.0],
                         nil];
    static int colorId = 0;
    
    if ([overlay isKindOfClass:[RoutePolyline class]])
    {
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [okColors objectAtIndex:colorId];
        colorId = (colorId + 1) % [okColors count];
		polylineView.lineWidth = 15;
		return [polylineView autorelease];
    } else if ([overlay isKindOfClass:[MKPolyline class]])
    {
		MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
		polylineView.strokeColor = [UIColor colorWithRed:1.0 green:0.49 blue:0.25 alpha:1.0];
		polylineView.lineWidth = 8;
		return [polylineView autorelease];
	}
	
	return [[[MKOverlayView alloc] initWithOverlay:overlay] autorelease];
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    const CLLocation *centerOfCity = [[CLLocation alloc] initWithLatitude:DEFAULT_LAT longitude:DEFAULT_LON];
    static BOOL alertShown = NO; // чтобы дважды не показывать сообщение
    
    if ([newLocation distanceFromLocation:centerOfCity] > 30000.0) // Да-да, в метрах
    {
        // Юзер не в городе
        if (alertShown == NO)
        {
            alertShown = YES;        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                            message:@"Кажется, вы не в Новосибирске. Так как сервис актуален только для его жителей, мы переместим вас в центр города." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Спасибо" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [self.mapView setRegion:MKCoordinateRegionMake([centerOfCity coordinate], MKCoordinateSpanMake(0.06, 0.06)) animated:YES];
    }
    else
    {
        // Юзер в городе
        [self.mapView setRegion:MKCoordinateRegionMake([newLocation coordinate], MKCoordinateSpanMake(0.03, 0.03)) animated:YES];
    }
    
    [self.mapView setShowsUserLocation:YES];
    [self.locationManager stopUpdatingLocation];
    [centerOfCity release];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    [self.locationManager stopUpdatingLocation];      
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                    message:@"Возникли проблемы с определением вашего местоположения. Может отключена геолокация?" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Ок, я проверю" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
