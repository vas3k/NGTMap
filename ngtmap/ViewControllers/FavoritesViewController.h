//
//  FavoritesViewController.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <UIKit/UIKit.h>
#import "Transport.h"

@interface FavoritesViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *favoritesNgtObjects;
@property (nonatomic, retain) NSMutableArray *favoritesNgtStrings;

- (void)loadNgtFavorites;
- (void)addToFavorites:(Transport *)transport;
- (void)removeFromFavorites:(Transport *)transport;
- (void)addOrRemoveFromFavorites:(Transport *)transport;

@end
