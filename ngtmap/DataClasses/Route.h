//
//  Route.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface RoutePolyline: MKPolyline
{
}
@end

@interface Route : NSObject

@property (nonatomic) NSInteger totalPrice;
@property (nonatomic, retain) NSMutableArray *transport;
@property (nonatomic, retain) NSMutableArray *polylines;

@end
