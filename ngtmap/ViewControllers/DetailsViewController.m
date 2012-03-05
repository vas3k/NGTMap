//
//  DetailsViewController.m
//  ngtmap
//
//  Created by Vasily Zubarev on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailsViewController.h"
#import "AppDelegate.h"

typedef enum { SectionHeader, SectionButtons, SectionTimetable } Sections;

@implementation DetailsViewController

@synthesize transport;
@synthesize titleCell, buttonsCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.transport = newTransport;
        [self.transport loadCarsTo:self];
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)carsLoaded
{
    [(UITableView *)self.view reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.transport)
    {
        self.title = [[NSString stringWithFormat:@"%@ %@", self.transport.canonicalType, self.transport.number] capitalizedString];
    }
    else
    {
        self.title = @"Подробности";
    }
    
    if ([self.transport.lastUpdate timeIntervalSinceNow] < -200)
    {
        [self.transport loadCarsTo:self];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.transport.cars release];
    [self.transport release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) 
    {
        case SectionHeader:
            return 1;
            break;
        case SectionButtons:
            return 1;
            break;
        case SectionTimetable:
            return [self.transport.cars count];
            break;
        default:
            return 1;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) 
    {
        case SectionTimetable:
            return @"На маршруте";
            break;
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) 
    {
        case SectionHeader:
            return 60;
            break;
        default:
            return 44;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{            
    static NSString *titleCellID = @"BusTitleCell";
    static NSString *timetableCellID = @"TimetableCell";
    static NSString *buttonsCellID = @"BusButtonsCell";
    UITableViewCell *cell = nil;
    
    switch (indexPath.section)
    {
        case SectionHeader:
            cell = [tableView dequeueReusableCellWithIdentifier:titleCellID];
            if (cell == nil) 
            {
                cell = self.titleCell;
                cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
                
                UIImageView *icon = (UIImageView *) [cell viewWithTag:1];
                icon.image = [UIImage imageNamed:@"Bus.png"];
                
                UILabel *numberLabel = (UILabel *) [cell viewWithTag:2];
                numberLabel.text = transport.number;
                
                UILabel *typeLabel = (UILabel *) [cell viewWithTag:3];
                typeLabel.text = [transport.canonicalType lowercaseString];
                
                UILabel *stopALabel = (UILabel *) [cell viewWithTag:4];
                stopALabel.text = [transport.stopA capitalizedString];
                
                UILabel *stopBLabel = (UILabel *) [cell viewWithTag:5];
                stopBLabel.text = [transport.stopB capitalizedString];
            }
            break;
        case SectionButtons:
            cell = [tableView dequeueReusableCellWithIdentifier:buttonsCellID];
            if (cell == nil) 
            {
                cell = self.buttonsCell;
                cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
            }
            
            UIButton *favoritesButton = (UIButton *)[cell viewWithTag:10];
            if (transport.inFavorites)
            {
                favoritesButton.titleLabel.text = @"Разлюбить";
            }
            else
            {
                favoritesButton.titleLabel.text = @"В избранное";                    
            }
            
            break;    
        case SectionTimetable:
            cell = [tableView dequeueReusableCellWithIdentifier:timetableCellID];
            if (cell == nil) 
            {                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:timetableCellID];
            }
            Car *car = [self.transport.cars objectAtIndex:indexPath.row];
            cell.textLabel.text = car.timetableNearTime;
            cell.detailTextLabel.text = car.timetableNearPoint;
            
            break;        
        default:
            return nil;
            break;
    }
    
    return cell;
}


#pragma mark - IBActions
- (IBAction)showTransportOnMap:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.mapViewController addTransport:self.transport];
    [appDelegate.mapViewController.tabBarController setSelectedIndex:2];
}

- (IBAction)addToFavorites:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.favoritesViewController addOrRemoveFromFavorites:self.transport]; 
    [(UITableView*)self.view reloadData];
    [appDelegate.favoritesViewController.tabBarController setSelectedIndex:1];  
}

@end
