//
//  RouteCell.h
//  ngtmap
//
//  Created by vas3k on 15.01.13.
//
//

#import <UIKit/UIKit.h>
#import "Route.h"

@interface RouteCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *busNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *stopALabel;
@property (nonatomic, retain) IBOutlet UILabel *stopBLabel;

@property (nonatomic, retain) Route *route;
@property (nonatomic) NSInteger index;

- (void)fillWithRoute:(Route *)theroute atIndex:(NSInteger)theindex;

@end
