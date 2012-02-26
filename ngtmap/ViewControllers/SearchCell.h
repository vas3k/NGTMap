//
//  SearchCell.h
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transport.h"

@interface SearchCell : UITableViewCell

@property (nonatomic, retain) Transport *trans;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *stopALabel;
@property (nonatomic, retain) IBOutlet UILabel *stopBLabel;
@property (nonatomic, retain) IBOutlet UIButton *favoritesButton;

- (void)fillWithTransport:(Transport *)transport;
- (IBAction)toggleFavorites:(id)sender;

@end
