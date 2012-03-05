//
//  NGTDataSource.h
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDataSource.h"
#import "JSONKit.h"

@interface NGTDataSource : TransportDataSource <NSURLConnectionDelegate> {
    NSDictionary *typeNames;
    id transportLoadObject;
    id carsLoadObject;
    Transport *carsLoadTransportObject;
}

@property (nonatomic, retain) NSString *magicCookie;

@property (nonatomic, retain) NSURLConnection *cookieConnection;

@property (nonatomic, retain) NSURLConnection *transportConnection;
@property (nonatomic,retain) NSMutableData *receivedTransportData;

@property (nonatomic, retain) NSURLConnection *carsConnection;
@property (nonatomic,retain) NSMutableData *receivedCarsData;

- (void)loadTransportDataTo:(id)callbackObject;
- (void)loadPeriodicalData;
- (NSArray *)getCarsForTransport:(Transport *)transport;
- (void)getCarsForTransport:(Transport *)transport to:(id)callbackObject;

- (NSArray *)processTransportResponse:(NSData *)jsonData;
- (NSArray *)processMarkersResponse:(NSData *)jsonData forTransport:(Transport *)forTransport;

@end
