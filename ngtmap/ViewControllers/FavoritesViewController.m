//
//  FavoritesViewController.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "FavoritesViewController.h"
#import "DetailsViewController.h"
#import "SearchCell.h"
#import "AppDelegate.h"

@implementation FavoritesViewController

@synthesize favoritesNgtObjects, favoritesNgtStrings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {      
        self.title = @"Избранное";
    }
    return self;
}

- (void)dealloc {
    self.favoritesNgtObjects = nil;
    self.favoritesNgtStrings = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)addToFavorites:(Transport *)transport
{
    if (![self.favoritesNgtObjects containsObject:transport])
    {
        transport.inFavorites = YES;
        
        [self.favoritesNgtStrings addObject:transport.identificator];
        [self.favoritesNgtObjects addObject:transport];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];         
        [userDefaults setObject:self.favoritesNgtStrings forKey:@"favorites_ngt"];
        
        [(UITableView *)self.view reloadData];
    }
}

- (void)removeFromFavorites:(Transport *)transport
{
    transport.inFavorites = NO;
    
    [self.favoritesNgtStrings removeObject:transport.identificator];
    [self.favoritesNgtObjects removeObject:transport];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];         
    [userDefaults setObject:self.favoritesNgtStrings forKey:@"favorites_ngt"];
    
    [(UITableView *)self.view reloadData];
}

- (void)addOrRemoveFromFavorites:(Transport *)transport 
{
    if ([self.favoritesNgtObjects containsObject:transport])
    {
        [self removeFromFavorites:transport];
    }
    else
    {
        [self addToFavorites:transport];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadNgtFavorites
{    
    // Загружаем избранное из настроек
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.favoritesNgtStrings = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"favorites_ngt"]];
    
    // Будем брать автобусы из уже загруженного списка        
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // И класть сюда
    self.favoritesNgtObjects = [NSMutableArray arrayWithCapacity:30];
    
    // Поехали (грязно, но что делать :()
    if (self.favoritesNgtStrings != nil && appDelegate.searchViewController.transportDataSource.transportList != nil)
    {
        for (NSString *transId in self.favoritesNgtStrings)
        {                
            for (Transport *trans in appDelegate.searchViewController.transportDataSource.transportList)
            {
                if ([trans.identificator compare:transId] == NSOrderedSame)
                {
                    [self.favoritesNgtObjects addObject:trans];
                    trans.inFavorites = YES;
                    break;
                }
            }
        }
    }
    else
    {
        self.favoritesNgtStrings = [NSMutableArray arrayWithCapacity:30];
    }    
    [(UITableView *)self.view reloadData];
}


#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favoritesNgtObjects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
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
    
    Transport *transport = (Transport *)[self.favoritesNgtObjects objectAtIndex:indexPath.row];    
    [cell fillWithTransport:transport];    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    Transport *transport = [self.favoritesNgtObjects objectAtIndex:indexPath.row];
    
    DetailsViewController *detailsViewController = 
    [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" 
                                            bundle:nil 
                                         transport:transport];
    [self.navigationController pushViewController:detailsViewController 
                                         animated:YES];
    [detailsViewController release];  
}


@end
