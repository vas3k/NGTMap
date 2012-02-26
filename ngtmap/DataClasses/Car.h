//
//  Car.h
//  ngtmap
//
//  Created by Vasily Zubarev on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Transport;

@interface Car : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSString *timetable;
@property (nonatomic, retain) NSString *timetableNearTime;
@property (nonatomic, retain) NSString *timetableNearPoint;
@property (nonatomic, retain) NSString *speed;
@property (nonatomic) CGFloat azimuth;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) Transport *transport;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (int)normalizeAzimuth:(CGFloat)az;

@end
