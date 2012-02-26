//
//  SearchViewController.h
//  ngtmap
//
//  Created by Vasily Zubarev on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransportDataSource.h"
#import "NGTDataSource.h"

@interface SearchViewController : UITableViewController  <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>
{
    TransportDataSource *transportDataSource;
}

@property (nonatomic, retain) TransportDataSource *transportDataSource;

- (IBAction)tryToLoadData;
- (void)showInfoController;
- (void)transportLoaded;
- (void)transportLoadError;

@end
