//
//  SearchViewController.m
//  ngtmap
//
//  Created by Vasily Zubarev on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailsViewController.h"
#import "InfoViewController.h"
#import "SearchCell.h"
#import "Transport.h"
#import "AppDelegate.h"

@implementation SearchViewController

@synthesize transportDataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = @"Все маршруты";
        self.tabBarItem.title = @"Поиск";
        
        self.transportDataSource = [[NGTDataSource alloc] init];
        
        // Кнопочка инфо
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info.png"] 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self 
                                                                      action:@selector(showInfoController)];
        self.navigationItem.rightBarButtonItem = infoButton;
        [infoButton release];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self.transportDataSource release];  
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{      
    [self tryToLoadData];
    [super viewDidLoad];  
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

- (void)tryToLoadData
{    
    [self.transportDataSource loadTransportDataTo:self];
}

- (void)transportLoaded
{
    if (self.transportDataSource.transportList == nil)
    {
        [self transportLoadError];
    }
    UITableView *tableView = (UITableView *)self.view;
    [tableView reloadData];    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.favoritesViewController loadNgtFavorites];
}

- (void)transportLoadError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ой" 
                                                    message:@"Проблема при соединении с сервером. Либо у вас отсутствует интернет-соединение, либо что-то сломалось у нас" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Еще раз" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

- (void)showInfoController
{
    InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:infoViewController animated:YES];
    [infoViewController release];
}



#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) 
    {
        [self tryToLoadData];
    }
}




#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.transportDataSource numberOfSections];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL filtered = (tableView == self.searchDisplayController.searchResultsTableView);
    return [self.transportDataSource numberOfRowsInSection:section isFiltered:filtered];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"SearchCell";    
    SearchCell *cell = (SearchCell *) [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil)
    {        
        NSArray *cellBundle = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:nil options:nil];
        cell = (SearchCell *) [cellBundle objectAtIndex:0];
    }
    
    
    BOOL filtered = (tableView == self.searchDisplayController.searchResultsTableView);
    Transport *transport = [self.transportDataSource itemForIndexPath:indexPath isFiltered:filtered];  
    
    [cell fillWithTransport:transport];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    BOOL filtered = (tableView == self.searchDisplayController.searchResultsTableView);
    Transport *transport = [self.transportDataSource itemForIndexPath:indexPath 
                                                           isFiltered:filtered];
    
    DetailsViewController *detailsViewController = 
        [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" 
                                                bundle:nil 
                                             transport:transport];
    [self.navigationController pushViewController:detailsViewController 
                                         animated:YES];
    [detailsViewController release];    
}





#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.transportDataSource filterList:searchText scope:scope];
}




#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}







@end
