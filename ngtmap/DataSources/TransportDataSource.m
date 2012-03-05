//
//  TransportDataSource.m
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TransportDataSource.h"

@implementation TransportDataSource

@synthesize transportList;
@synthesize filteredTransportList;

- (id)init
{
    if (self = [super init])
    {                
        self.transportList = [NSMutableArray arrayWithCapacity:50];
        self.filteredTransportList = [NSMutableArray arrayWithCapacity:50];
    }
    return self;
}

- (void)loadPeriodicalData
{
}

- (NSInteger)numberOfSections
{
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section isFiltered:(BOOL)filtered
{
    if (filtered)
    {
        return [self.filteredTransportList count];
    }
    else
    {
        return [self.transportList count];
    }    
}

- (Transport *)itemForIndexPath:(NSIndexPath *)indexPath isFiltered:(BOOL)filtered
{
    if (filtered)
    {
        return [self.filteredTransportList objectAtIndex:indexPath.row];
    }
    else
    {
        return [self.transportList objectAtIndex:indexPath.row];
    }
}

- (NSInteger)filterList:(NSString *)searchText scope:(NSString *)scope
{	
	[self.filteredTransportList removeAllObjects];
    
    
	for (Transport *transport in self.transportList)
	{
		if ([scope isEqualToString:@"All"] || [transport.type isEqualToString:scope])
		{
			NSComparisonResult result = [transport.number compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredTransportList addObject:transport];
            }
		}
	}
    return [self.filteredTransportList count];    
}

- (NSArray *)getCarsForTransport:(Transport *)transport
{
    return nil;
}

- (void)loadTransportDataTo:(id)callbackObject
{
    return;
}

- (void)getCarsForTransport:(Transport *)transport to:(id)callbackObject
{
    return;
}

- (void)dealloc
{
    [self.transportList release];
    [self.filteredTransportList release];
    [super dealloc];
}

@end
