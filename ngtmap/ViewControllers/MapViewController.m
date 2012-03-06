//
//  MapViewController.m
//  ngtmap
//
//  Created by Vasily Zubarev on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

const float DEFAULT_LAT = 55.033333;
const float DEFAULT_LON = 82.916667;

@implementation MapViewController

@synthesize updateTimer;
@synthesize mapView, updateMapButton;
@synthesize selectedCar, detailsView, detailsNameLabel, detailsSpeedLabel, detailsTimetableLabel;
@synthesize transport;
@synthesize locationManager;

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
    if (![self.transport containsObject:newTransport])
    {
        [self.transport addObject:newTransport];
        [self updateTransport:self];
    }
}

- (void)removeTransport:(Transport *)oldTransport
{
    if ([self.transport containsObject:oldTransport])
    {
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
    [self.mapView removeAnnotations:mapView.annotations];
    [self.updateTimer invalidate];
    
    // Загрузить
    for (Transport* trans in self.transport)
    {
        [trans loadCarsTo:self];
    }
    
    // Дальше все отобразит метод carsLoaded (асинхронно, после загрузки)
}

- (void)carsLoaded
{            
    // Отобразить заново
    for (Transport* trans in self.transport)
    {
        [self.mapView addAnnotations:trans.cars];
    }    
    [self.mapView setShowsUserLocation:YES];
    
    [self.updateMapButton setEnabled:YES];
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 
                                               target:self 
                                             selector:@selector(updateTransport:) 
                                             userInfo:nil 
                                              repeats:YES];
}

- (void)carsLoadError
{
    [self.updateMapButton setEnabled:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ой" 
                                                    message:@"Проблема при загрузке данных о расположении этого транспорта. Извините :(" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Да все нормально, не расстраивайся" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
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

- (void)dealloc
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager release];
    [self.updateTimer invalidate];
    [self.updateTimer release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Карта";
    [self.detailsView setHidden:YES];
    
    // Настроить геопозиционирование    
    self.locationManager = [[CLLocationManager alloc] init];
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
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        }
        
        // Отображаем кастомные иконки и поворачиваем по азимуту
        Car *annotationCar = (Car *)annotation;
        annotationView.image = annotationCar.icon;
        [annotationView setCanShowCallout:YES];  
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:Car.class])
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
