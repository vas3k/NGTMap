//
//  NGTDataSource.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TransportDataSource.h"
#import "Route.h"
#import "JSONKit.h"

@interface NGTDataSource : TransportDataSource <NSURLConnectionDelegate> {
    NSDictionary *typeNames;    
    Transport *carsLoadTransportObject;
    Transport *trassesLoadTransportObject;    
}

@property (nonatomic, retain) NSString *magicCookie;

@property (nonatomic, retain) NSURLConnection *cookieConnection;

@property (nonatomic, retain) NSURLConnection *transportConnection;
@property (nonatomic, assign) id transportLoadObject;
@property (nonatomic,retain) NSMutableData *receivedTransportData;

@property (nonatomic, retain) NSURLConnection *carsConnection;
@property (nonatomic, assign) id carsLoadObject;
@property (nonatomic,retain) NSMutableData *receivedCarsData;

@property (nonatomic, retain) NSURLConnection *trassesConnection;
@property (nonatomic, assign) id trassesLoadObject;
@property (nonatomic,retain) NSMutableData *receivedTrassesData;

@property (nonatomic, retain) NSURLConnection *routesConnection;
@property (nonatomic, assign) id routesLoadObject;
@property (nonatomic,retain) NSMutableData *receivedRoutesData;

- (void)cancelAllConnections;

- (void)loadTransportDataTo:(id)callbackObject;
- (void)loadPeriodicalData;
- (NSArray *)getCarsForTransport:(Transport *)transport;
- (void)getCarsForTransport:(Transport *)transport to:(id)callbackObject;
- (void)getTrassesForTransport:(Transport *)transport to:(id)callbackObject;

- (NSArray *)processTransportResponse:(NSData *)jsonData;
- (NSArray *)processMarkersResponse:(NSData *)jsonData forTransport:(Transport *)forTransport;
- (void)processTrassesResponse:(NSData *)jsonData forTransport:(Transport *)forTransport;

- (void)searchRoutesBetweenCoordinate:(CLLocationCoordinate2D)start andCoordinate:(CLLocationCoordinate2D)stop forObject:(id)callbackObject;
- (NSArray *)processRoutesResponse:(NSData *)jsonData forObject:(id)callbackObject;

@end
