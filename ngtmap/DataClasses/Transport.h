//
//  Transport.h
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TransportDataSource;

@interface Transport : NSObject <NSCoding>
{
    id lastCallbackObject;
}

@property (nonatomic, retain) NSString *identificator, *type, *number, *stopA, *stopB, *canonicalType;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSArray *cars;
@property (nonatomic) BOOL inFavorites;
@property (nonatomic, retain) NSDictionary *canonicalTypes;
@property (nonatomic, retain) TransportDataSource *transportDataSource; 
@property (nonatomic, retain) NSDate *lastUpdate;

//self, @"datasource", identificator, @"id", type, @"type", number, @"number", stopA, @"stopA", stopB, @"stopB", inFavorites, @"inFavorites"

- (id)initWithDatasource:(TransportDataSource*)datasource 
           identificator:(NSString*)identificator 
                    type:(NSString*)type 
                  number:(NSString*)number 
                   stopA:(NSString*)stopA 
                   stopB:(NSString*)stopB 
             inFavorites:(BOOL)inFavorites;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)loadCars;
- (void)loadCarsTo:(id)callbackObject;

@end
