//
//  DetailsViewController.h
//  ngtmap
//
//  Created by Vasily Zubarev on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transport.h"
#import "Car.h"

@interface DetailsViewController : UITableViewController   <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, retain) Transport *transport;
@property (nonatomic, retain) IBOutlet UITableViewCell *titleCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *buttonsCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil transport:(Transport *)newTransport;
- (void)carsLoaded;
- (void)carsLoadError;

- (IBAction)showTransportOnMap:(id)sender;
- (IBAction)addToFavorites:(id)sender;

@end
