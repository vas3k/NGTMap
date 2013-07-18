//
//  Transport.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "Transport.h"

@implementation Transport

@synthesize transportDataSource;
@synthesize stopACoordinates, stopBCoordinates;
@synthesize identificator, type, number, stopA, stopB, canonicalType, inFavorites;
@synthesize routeLine;
@synthesize canonicalTypes;
@synthesize icon;
@synthesize detailsIcon;
@synthesize cars;
@synthesize lastUpdate;
@synthesize numberInt;

- (id)init
{
    self = [super init];
    if (self)
    {        
        self.canonicalTypes = [NSDictionary dictionaryWithObjectsAndKeys:@"автобус", @"Bus", @"троллейбус", @"Troll", @"трамвай", @"Tram", @"маршрутка", @"MT", nil];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) 
    {        
        self.identificator = [dictionary valueForKey:@"id"];
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
    self = [self init];
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
        self.icon = [UIImage imageNamed:[[NSString stringWithFormat:@"%@_search.png", self.type] lowercaseString]];
        self.detailsIcon = [UIImage imageNamed:[[NSString stringWithFormat:@"%@_details.png", self.type] lowercaseString]];
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

- (void)loadTrassesTo:(id)callbackObject
{
    if (self.transportDataSource != nil)
    {
        lastCallbackObject = callbackObject;
        [self.transportDataSource getTrassesForTransport:self to:callbackObject];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Type: %@, number: %@, id: %@", type, number, identificator];
}

- (void)dealloc {
    self.transportDataSource = nil;
    self.cars = nil;
    self.type = nil;
    self.number = nil;
    self.lastUpdate = nil;
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
