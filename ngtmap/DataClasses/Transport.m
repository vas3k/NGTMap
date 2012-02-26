//
//  Transport.m
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Transport.h"

@implementation Transport

@synthesize transportDataSource;
@synthesize identificator, type, number, stopA, stopB, canonicalType, inFavorites;
@synthesize canonicalTypes;
@synthesize icon;
@synthesize cars;
@synthesize lastUpdate;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {        
        self.identificator = [dictionary valueForKey:@"id"];
        self.canonicalTypes = [NSDictionary dictionaryWithObjectsAndKeys:@"автобус", @"Bus", @"троллейбус", @"Troll", @"трамвай", @"Tram", @"маршрутка", @"MT", nil];
        self.transportDataSource = [dictionary valueForKey:@"datasource"];
        self.number = [dictionary valueForKey:@"number"];
        self.type = [dictionary valueForKey:@"type"];
        self.canonicalType = [self.canonicalTypes valueForKey:type];
        self.stopA = [dictionary valueForKey:@"stopA"];
        self.stopB = [dictionary valueForKey:@"stopB"];
        self.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.type]];
        self.inFavorites = [[dictionary valueForKey:@"inFavorites"] boolValue];
    }
    return self;
}

- (id)initWithDatasource:(TransportDataSource *)datasource identificator:(NSString *)identificator type:(NSString *)type number:(NSString *)number stopA:(NSString *)stopA stopB:(NSString *)stopB inFavorites:(BOOL)inFavorites
{
    self = [super init];
    if (self) 
    {
        //NSLog(@"Id: %@, type: %@, number: %@, stopA: %@, stopB: %@", identificator, type, number, stopA, stopB);
        self.identificator = identificator;
        self.canonicalTypes = [NSDictionary dictionaryWithObjectsAndKeys:@"автобус", @"Bus", @"троллейбус", @"Troll", @"трамвай", @"Tram", @"маршрутка", @"MT", nil];
        self.transportDataSource = datasource;
        self.number = number;
        self.type = type;
        self.canonicalType = [self.canonicalTypes valueForKey:type];
        self.stopA = stopA;
        self.stopB = stopB;
        self.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.type]];
        self.inFavorites = inFavorites;
        self.lastUpdate = [NSDate date];
    }
    return self;
}

- (BOOL)loadCars
{
    if (self.transportDataSource != nil)
    {
        self.cars = [self.transportDataSource getCarsForTransport:self];
        self.lastUpdate = [NSDate date];
        return self.cars != nil;
    }
    return NO;
}

- (void)loadCarsTo:(id)callbackObject
{
    if (self.transportDataSource != nil)
    {
        lastCallbackObject = callbackObject;
        [self.transportDataSource getCarsForTransport:self to:callbackObject];
        self.lastUpdate = [NSDate date];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ : %@", type, number];
}

- (void)dealloc
{
    [type release];
    [number release];
    [super dealloc];
}



#pragma mark - NSCoding protocol

// Десериализация
- (id) initWithCoder: (NSCoder *)coder {
    if (self = [super init]) {
        self.number = [coder decodeObjectForKey:@"number"];
        self.type = [coder decodeObjectForKey:@"type"];
        self.canonicalType = [coder decodeObjectForKey:@"canonicalType"];
        self.stopA = [coder decodeObjectForKey:@"stopA"];
        self.stopB = [coder decodeObjectForKey:@"stopB"];
        self.icon = [UIImage imageNamed:[coder decodeObjectForKey:@"icon"]];
        self.inFavorites = YES;
    }
    return self;
}

// Сериализация
- (void) encodeWithCoder: (NSCoder *)coder {
    self.canonicalTypes = [NSDictionary dictionaryWithObjectsAndKeys:@"автобус", @"Bus", @"троллейбус", @"Troll", @"трамвай", @"Tram", @"маршрутка", @"MT", nil];
    [coder encodeObject:self.number forKey:@"number"];
    [coder encodeObject:self.type forKey:@"type"];    
    [coder encodeObject:self.canonicalType forKey:@"canonicalType"];
    [coder encodeObject:self.stopA forKey:@"stopA"];
    [coder encodeObject:self.stopB forKey:@"stopB"];
    [coder encodeObject:[NSString stringWithFormat:@"%@.png", self.type] forKey:@"icon"];
}

@end
