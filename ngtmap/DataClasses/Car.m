//
//  Car.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "Car.h"
#import "Transport.h"

@implementation Car

@synthesize transport, timetable, timetableNearPoint, timetableNearTime, speed;
@synthesize title, subtitle, coordinate;
@synthesize azimuth;
@synthesize icon;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        self.transport = [dictionary valueForKey:@"transport"];
        self.timetable = [dictionary valueForKey:@"timetable"];
        self.azimuth = [[dictionary valueForKey:@"azimuth"] floatValue];
        self.speed = [dictionary valueForKey:@"speed"];
        icon = [UIImage imageNamed:[NSString stringWithFormat:@"Bus_arrow-%d.png", [self normalizeAzimuth:self.azimuth]]];

        // Определение ближайшей остановки
        NSUInteger splitterPos = [self.timetable rangeOfString:@"|"].location;
        if (splitterPos <= [self.timetable length]) 
        {
            NSArray *timetableNear = [[self.timetable substringToIndex:splitterPos] componentsSeparatedByString:@"+"];
            if ([timetableNear count] == 2) 
            {
                self.timetableNearTime = [timetableNear objectAtIndex:0];
                self.timetableNearPoint = [timetableNear objectAtIndex:1];
            }
            else
            {
                self.timetableNearTime = @"XX:XX";
                self.timetableNearPoint = [self.timetable substringToIndex:splitterPos];
            }            
        }
        else
        {
            self.timetableNearTime = @"XX:XX";
            self.timetableNearPoint = @"Остановка неизвестна";
        }
        coordinate = CLLocationCoordinate2DMake([[dictionary valueForKey:@"lat"] doubleValue], [[dictionary valueForKey:@"lon"] doubleValue]);
        title = self.transport.number;
        subtitle = self.transport.canonicalType;
    }
    return self;
}

- (int)normalizeAzimuth:(CGFloat)az
{
    int i = 0;
    while (i < 9)
    {
        int a45 = i * 45;
        if ((az > (a45 - 22.5)) && (az < (a45 + 22.5)))
        {
            return (i * a45 == 360) ? 0 : i * 45;
        }
        i++;
    }
    return 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", self.transport];
}

- (void)dealloc
{
    [self.timetable release];
    [self.timetableNearPoint release];
    [self.timetableNearTime release];
    [self.speed release];
    [self.transport release];
    [super dealloc];
}

@end
