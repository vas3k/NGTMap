//
//  Transport.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class TransportDataSource;

@interface Transport : NSObject <NSCoding>
{
    id lastCallbackObject;
}

@property (nonatomic, retain) NSString *identificator, *type, *number, *stopA, *stopB, *canonicalType;
@property (nonatomic) CLLocationCoordinate2D stopACoordinates, stopBCoordinates;
@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) UIImage *detailsIcon;
@property (nonatomic, retain) NSArray *cars;
@property (nonatomic) BOOL inFavorites;
@property (nonatomic, retain) NSDictionary *canonicalTypes;
@property (nonatomic, retain) TransportDataSource *transportDataSource; 
@property (nonatomic, retain) NSDate *lastUpdate;

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
- (void)loadTrassesTo:(id)callbackObject;

@end
