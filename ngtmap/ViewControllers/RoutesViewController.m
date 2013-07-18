//
//  RoutesViewController.m
//  ngtmap
//
//  Created by vas3k on 13.01.13.
//
//

#import "RoutesViewController.h"
#import "AppDelegate.h"
#import "Utility.h"

@implementation RoutesViewController

@synthesize locationManager;
@synthesize startButton, stopButton, searchButton, topCell, activityIndicator;
@synthesize startCoordinates, stopCoordinates;
@synthesize transportDataSource, routes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Поиск проезда";
        self.tabBarItem.title = @"Проезд";
        self.transportDataSource = [[NGTDataSource alloc] init];
        self.routes = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    [self.startButton release];
    [self.stopButton release];
    [self.searchButton release];
    [self.topCell release];
    [self.activityIndicator release];
    [self.transportDataSource release];
    [self.routes release];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    UIImage *resizableWhiteButton = [Utility resizableImageNamed:@"button_white.png"];
    UIImage *resizableWhiteButtonHighlighted = [Utility resizableImageNamed:@"button_white_press.png"];
    [self.startButton setBackgroundImage:resizableWhiteButton forState:UIControlStateNormal];
    [self.startButton setBackgroundImage:resizableWhiteButtonHighlighted forState:UIControlStateHighlighted];
    [self.stopButton setBackgroundImage:resizableWhiteButton forState:UIControlStateNormal];
    [self.stopButton setBackgroundImage:resizableWhiteButtonHighlighted forState:UIControlStateHighlighted];
    
    UIImage *resizableGreenButton = [Utility resizableImageNamed:@"button_green.png"];
    UIImage *resizableGreenButtonHighlighted = [Utility resizableImageNamed:@"button_green_press.png"];
    [self.searchButton setBackgroundImage:resizableGreenButton forState:UIControlStateNormal];
    [self.searchButton setBackgroundImage:resizableGreenButtonHighlighted forState:UIControlStateHighlighted];
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)appendResult:(Route *)route
{
    [self.routes addObject:route];
    [(UITableView *)self.view reloadData];
    [self.activityIndicator stopAnimating];
}

- (void)emptyResults
{
    [self.activityIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Не удалось найти способы проезда между указанными точками на общественном транспорте. Пора покупать комфортный десятибальный личный транспорт."
                                                   delegate:self
                                          cancelButtonTitle:@"Ок"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.routes count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        Route *route = [self.routes objectAtIndex:section-1];
        return [route.transport count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section > 0)
    {
        Route *route = [self.routes objectAtIndex:section-1];
        return [NSString stringWithFormat:@"Вариант %d, стоимость: %d руб.", section, route.totalPrice];
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 250;
    }
    else
    {
        return 85;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *topCellID = @"TopCell";
    static NSString *routeCellID = @"RouteCell";

    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:topCellID];
        if (cell == nil)
        {
            cell = self.topCell;
        }
//        cell.userInteractionEnabled = NO;
        return cell;
    }
    else
    {
        RouteCell *cell = (RouteCell *)[tableView dequeueReusableCellWithIdentifier:routeCellID];
        if (cell == nil)
        {
            NSArray *cellBundle = [[NSBundle mainBundle] loadNibNamed:@"RouteCell" owner:nil options:nil];
            cell = (RouteCell *)[cellBundle objectAtIndex:0];
        }
        Route *route = [self.routes objectAtIndex:indexPath.section-1];
        Transport *transport = [route.transport objectAtIndex:indexPath.row];
        
        [cell fillWithRoute:route atIndex:indexPath.row];        
        
        cell.busNameLabel.text = [NSString stringWithFormat:@"%@ %@", transport.canonicalType, transport.number];
        cell.stopALabel.text = transport.stopA;
        cell.stopBLabel.text = transport.stopB;
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Сделаем первую ячейку с формой поиска не выделяемой
    if (indexPath.section == 0)
    {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
    {
        Route *route = [self.routes objectAtIndex:indexPath.section-1];
        Transport *selectedTransport = [route.transport objectAtIndex:indexPath.row];        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [selectedTransport loadCarsTo:appDelegate.mapViewController];
        [appDelegate.mapViewController addRoute:route];
        [appDelegate.mapViewController.tabBarController setSelectedIndex:3];
    }
}

#pragma mark IBActions

- (IBAction)selectStartPoint:(id)sender
{
    SelectPointsViewController *selectPointsViewController = [[SelectPointsViewController alloc] initWithNibName:@"SelectPointsViewController" bundle:nil];
    selectPointsViewController.parent = self;
    selectPointsViewController.pointNumber = 0;
    [self.navigationController pushViewController:selectPointsViewController animated:YES];
    [selectPointsViewController release];
}

- (IBAction)selectStopPoint:(id)sender
{
    SelectPointsViewController *selectPointsViewController = [[SelectPointsViewController alloc] initWithNibName:@"SelectPointsViewController" bundle:nil];
    selectPointsViewController.parent = self;
    selectPointsViewController.pointNumber = 1;
    [self.navigationController pushViewController:selectPointsViewController animated:YES];
    [selectPointsViewController release];
}

- (IBAction)startSearch:(id)sender
{
//    self.startCoordinates = CLLocationCoordinate2DMake(55.058512, 82.912102);
//    self.stopCoordinates = CLLocationCoordinate2DMake(54.993373, 82.911415);
    [self.routes removeAllObjects];
    [self.tableView reloadData];
    
    NSLog(@"Searching from %f : %f to %f : %f", self.startCoordinates.latitude, self.startCoordinates.longitude, self.stopCoordinates.latitude, self.stopCoordinates.longitude);
    
    if (!(self.startCoordinates.latitude < 55.14 && self.startCoordinates.latitude > 54.77 && self.startCoordinates.longitude < 83.3 && self.startCoordinates.longitude > 82.5))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Выберите стартовую точку в пределах Новосибирска"
                                                       delegate:self
                                              cancelButtonTitle:@"Ой"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if (!(self.stopCoordinates.latitude < 55.14 && self.stopCoordinates.latitude > 54.77 && self.stopCoordinates.longitude < 83.3 && self.stopCoordinates.longitude > 82.5))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Выберите конечную точку в пределах Новосибирска"
                                                       delegate:self
                                              cancelButtonTitle:@"Ой"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    [self.activityIndicator startAnimating];
    [self.transportDataSource searchRoutesBetweenCoordinate:self.startCoordinates andCoordinate:self.stopCoordinates forObject:self];
}

- (void)setStartCoordinates:(CLLocationCoordinate2D)theStartCoordinates
{
    startCoordinates = theStartCoordinates;
    
    [self.startButton setTitle:@"Выбранной начальной точки" forState:UIControlStateNormal];
    UIImage *resizableYellowButton = [Utility resizableImageNamed:@"button_yellow.png"];
    UIImage *resizableYellowButtonHighlighted = [Utility resizableImageNamed:@"button_yellow_press.png"];
    [self.startButton setBackgroundImage:resizableYellowButton forState:UIControlStateNormal];
    [self.startButton setBackgroundImage:resizableYellowButtonHighlighted forState:UIControlStateHighlighted];
}

- (void)setStopCoordinates:(CLLocationCoordinate2D)theStopCoordinates
{
    stopCoordinates = theStopCoordinates;
    
    [self.stopButton setTitle:@"Выбранной конечной точки" forState:UIControlStateNormal];
    UIImage *resizableYellowButton = [Utility resizableImageNamed:@"button_yellow.png"];
    UIImage *resizableYellowButtonHighlighted = [Utility resizableImageNamed:@"button_yellow_press.png"];
    [self.stopButton setBackgroundImage:resizableYellowButton forState:UIControlStateNormal];
    [self.stopButton setBackgroundImage:resizableYellowButtonHighlighted forState:UIControlStateHighlighted];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.startCoordinates = newLocation.coordinate;
    [self.locationManager stopUpdatingLocation];
    
    
    [self.startButton setTitle:@"Моего местоположения" forState:UIControlStateNormal];
    UIImage *resizableYellowButton = [Utility resizableImageNamed:@"button_yellow.png"];
    UIImage *resizableYellowButtonHighlighted = [Utility resizableImageNamed:@"button_yellow_press.png"];
    [self.startButton setBackgroundImage:resizableYellowButton forState:UIControlStateNormal];
    [self.startButton setBackgroundImage:resizableYellowButtonHighlighted forState:UIControlStateHighlighted];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    [self.startButton setBackgroundColor:[UIColor whiteColor]];
    [self.startButton setTitle:@"Выбрать точку отъезда" forState:UIControlStateNormal];
    [self.locationManager stopUpdatingLocation];
}

@end
