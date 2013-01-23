//
//  SearchCell.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <UIKit/UIKit.h>
#import "Transport.h"

@interface SearchCell : UITableViewCell

@property (nonatomic, retain) Transport *trans;
@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *stopALabel;
@property (nonatomic, retain) IBOutlet UIButton *favoritesButton;

- (void)fillWithTransport:(Transport *)transport;
- (IBAction)toggleFavorites:(id)sender;

@end
