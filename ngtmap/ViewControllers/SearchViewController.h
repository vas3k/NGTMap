//
//  SearchViewController.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <UIKit/UIKit.h>
#import "NGTDataSource.h"

@interface SearchViewController : UITableViewController  <UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>
{
}

@property (nonatomic, retain) NGTDataSource *transportDataSource;

- (IBAction)tryToLoadData;
- (void)showInfoController;
- (void)transportLoaded;
- (void)transportLoadError;

@end
