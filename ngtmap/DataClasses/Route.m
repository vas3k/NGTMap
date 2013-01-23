//
//  Route.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "Route.h"

@implementation RoutePolyline
@end

@implementation Route
@synthesize totalPrice;
@synthesize transport, polylines;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.transport = [NSMutableArray arrayWithCapacity:5];
        self.polylines = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    [self.transport release];
    [self.polylines release];
    [super dealloc];
}

@end
