//
//  RouteCell.m
//  ngtmap
//
//  Created by vas3k on 15.01.13.
//
//

#import "RouteCell.h"

@implementation RouteCell

@synthesize route, index;
@synthesize busNameLabel, stopALabel, stopBLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [self.route release];
    [self.busNameLabel release];
    [self.stopALabel release];
    [self.stopBLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)fillWithRoute:(Route *)theroute atIndex:(NSInteger)theindex
{
    self.route = theroute;
    self.index = theindex;
}

@end
