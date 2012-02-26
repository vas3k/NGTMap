//
//  FavoritesViewController.h
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transport.h"

@interface FavoritesViewController : UITableViewController  <UISearchBarDelegate>

@property (nonatomic, retain) NSMutableArray *favoritesNgtObjects;
@property (nonatomic, retain) NSMutableArray *favoritesNgtStrings;

- (void)loadNgtFavorites;
- (void)addToFavorites:(Transport *)transport;
- (void)removeFromFavorites:(Transport *)transport;
- (void)addOrRemoveFromFavorites:(Transport *)transport;

@end
