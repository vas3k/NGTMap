//
//  NGTDataSource.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "NGTDataSource.h"

NSString * const transportAllURL = @"http://maps.nskgortrans.ru/listmarsh.php?r";
NSString * const transportCoordinatesURL = @"http://maps.nskgortrans.ru/markers.php?r=";
NSString * const transportTrassesURL = @"http://maps.nskgortrans.ru/trasses.php?r=";
NSString * const transportRoutesURL = @"http://maps.nskgortrans.ru/calculate.php?";
NSString * const mainUrl = @"http://maps.nskgortrans.ru/";

@implementation NGTDataSource

@synthesize cookieConnection, transportConnection, carsConnection, receivedTransportData, receivedCarsData, trassesConnection, receivedTrassesData, receivedRoutesData;
@synthesize magicCookie;
@synthesize carsLoadObject, trassesLoadObject, routesLoadObject, transportLoadObject;

- (id)init
{
    if (self = [super init])
    {
        [self loadPeriodicalData];
    }
    return self;
}

- (void)cancelAllConnections
{
    if (self.carsConnection != nil)
    {
        [self.carsConnection cancel];
        [self.carsConnection release];
        self.carsConnection = nil;
    }
    self.carsLoadObject = nil;
    
    if (self.transportConnection != nil)
    {
        [self.transportConnection cancel];
        [self.transportConnection release];
        self.transportConnection = nil;
    }
    self.transportLoadObject = nil;
    
    if (self.trassesConnection != nil)
    {
        [self.trassesConnection cancel];
        [self.trassesConnection release];
        self.trassesConnection = nil;
    }
    self.trassesLoadObject = nil;
    
    if (self.transportConnection != nil)
    {
        [self.transportConnection cancel];
        [self.transportConnection release];
        self.transportConnection = nil;
    }
    self.transportLoadObject = nil;
}

- (void)loadPeriodicalData
{
    // Для получения волшебной куки
    NSURLRequest *cookieRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:mainUrl]
                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:30.0];
    
    self.cookieConnection = [[NSURLConnection alloc] initWithRequest:cookieRequest
                                                            delegate:self
                                                    startImmediately:YES];    
}

- (void)loadTransportDataTo:(id)callbackObject
{
    // Если уже есть активные соединения, явно надо их закрыть и начать заново
    if (transportLoadObject != nil)
    {
        [self.transportConnection cancel];
        transportLoadObject = nil;
    }
    
    // Загрузить данные по маршрутам
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Делаем асинхронный запрос    
    self.receivedTransportData = [NSMutableData dataWithCapacity:500];
    NSURL *url = [NSURL URLWithString:transportAllURL];        
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                timeoutInterval:60.0];   
    
    transportLoadObject = callbackObject;
    self.transportConnection = [[NSURLConnection alloc] initWithRequest:request
                                                               delegate:self
                                                       startImmediately:YES];
}

- (NSArray *)processTransportResponse:(NSData *)jsonData
{
    if (jsonData == nil)
    {
        return nil;
    }
    
    // Типы    
    typeNames = [NSDictionary dictionaryWithObjectsAndKeys:@"Bus", @"0", @"Troll", @"1", @"Tram", @"2", @"MT", @"7", nil];
    
    // Обрабатываем ответ в JSON
    JSONDecoder *jsonKitDecoder = [JSONDecoder decoder];
    NSDictionary *items = [jsonKitDecoder objectWithData:jsonData];
    
    NSString *identificator, *number, *type, *stopA, *stopB;
    Transport *newTransport;
    NSDictionary *ways;
    NSString *typeId;
    
    // Заполняем массив маршрутов
    NSMutableArray *newTransportList = [NSMutableArray arrayWithCapacity:200];
    for (id transport in items) 
    {
        ways = (NSDictionary *) [transport objectForKey:@"ways"];
        typeId = [NSString stringWithFormat:@"%@", [transport objectForKey:@"type"]];
        type = [typeNames valueForKey:typeId];
        for (id item in ways)
        {
            number = (NSString *)[item valueForKey:@"name"];
            stopA = (NSString *)[item valueForKey:@"stopb"];
            stopB = (NSString *)[item valueForKey:@"stope"]; 
            identificator = [NSString stringWithFormat:@"%d-%@-W-%@", ([typeId integerValue]+1), 
                             [item valueForKey:@"marsh"], 
                             number];  
                        
            newTransport = [[Transport alloc] initWithDatasource:self identificator:identificator type:type number:number stopA:stopA stopB:stopB inFavorites:NO];
            [newTransportList addObject:newTransport];
            [newTransport release];
        }
    }
    NSArray *sortedTransportList = [newTransportList sortedArrayUsingComparator:^NSComparisonResult(Transport *a, Transport *b) {
        return [a.number compare:b.number];
    }];
    return sortedTransportList;
}

- (NSArray *) getCarsForTransport:(Transport *)transport
{
    // Информация об одном транспорте
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
    // Делаем запрос
    NSString *urlString = [NSString stringWithFormat:@"%@%@|", transportCoordinatesURL, transport.identificator];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:60.0];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.224 Safari/534.10" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://maps.nskgortrans.ru/" forHTTPHeaderField:@"Referer"];
    [request setValue:self.magicCookie forHTTPHeaderField:@"Cookie"];
    
    NSData* jsonData = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:nil 
                                                         error:nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (jsonData == nil)
    {
        return nil;
    }
    
    
    return [self processMarkersResponse:jsonData forTransport:transport];
}

- (void)getCarsForTransport:(Transport *)transport to:(id)callbackObject
{
    // Если уже есть активные соединения, явно надо их закрыть и начать заново
    if (carsLoadObject != nil)
    {
        [self.carsConnection cancel];
        carsLoadObject = nil;
    }
    
    // Информация об одном транспорте
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Делаем запрос
    NSString *urlString = [NSString stringWithFormat:@"%@%@|", transportCoordinatesURL, transport.identificator];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                       timeoutInterval:60.0];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.224 Safari/534.10" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://maps.nskgortrans.ru/" forHTTPHeaderField:@"Referer"];
    [request setValue:self.magicCookie forHTTPHeaderField:@"Cookie"];
    
    // Делаем асинхронный запрос    
    self.receivedCarsData = [NSMutableData dataWithCapacity:500];
    
    carsLoadObject = callbackObject;
    carsLoadTransportObject = transport;
    self.carsConnection = [[NSURLConnection alloc] initWithRequest:request
                                                          delegate:self
                                                  startImmediately:YES];    
}


- (NSArray *)processMarkersResponse:(NSData *)jsonData forTransport:(Transport *)forTransport
{
    
    // Обрабатываем ответ в JSON
    JSONDecoder *jsonKitDecoder = [JSONDecoder decoder];
    NSDictionary *items = [jsonKitDecoder objectWithData:jsonData];
    
    // Заполняем массив меток для этого маршрута
    NSMutableArray *cars = [[[NSMutableArray alloc] initWithCapacity:100] autorelease];    
    Car *car = nil;
    for (id carDict in [items objectForKey:@"markers"]) 
    {
        car = [[Car alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:forTransport, @"transport", 
                                               [carDict valueForKey:@"lat"], @"lat", 
                                               [carDict valueForKey:@"lng"], @"lon", 
                                               [carDict valueForKey:@"rasp"], @"timetable",
                                               [carDict valueForKey:@"azimuth"], @"azimuth",
                                               [carDict valueForKey:@"speed"], @"speed",
                                               nil]];
        [cars addObject:car];
        [car release];
    }
    return cars;
}









- (void)getTrassesForTransport:(Transport *)transport to:(id)callbackObject
{    
    // Если уже есть активные соединения, явно надо их закрыть и начать заново
    if (trassesLoadObject != nil)
    {
        [self.trassesConnection cancel];
        trassesLoadObject = nil;
    }
    
    // Информация об одном транспорте
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Делаем запрос
    NSString *urlString = [NSString stringWithFormat:@"%@%@|", transportTrassesURL, transport.identificator];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.224 Safari/534.10" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://maps.nskgortrans.ru/" forHTTPHeaderField:@"Referer"];
    [request setValue:self.magicCookie forHTTPHeaderField:@"Cookie"];
    
    // Делаем асинхронный запрос
    self.receivedTrassesData = [NSMutableData dataWithCapacity:1000];
    
    trassesLoadObject = callbackObject;
    trassesLoadTransportObject = transport;
    self.trassesConnection = [[NSURLConnection alloc] initWithRequest:request
                                                          delegate:self
                                                  startImmediately:YES];
}


- (void)processTrassesResponse:(NSData *)jsonData forTransport:(Transport *)forTransport
{
    
    // Обрабатываем ответ в JSON
    JSONDecoder *jsonKitDecoder = [JSONDecoder decoder];
    NSDictionary *items = [jsonKitDecoder objectWithData:jsonData];
    
    // Заполняем массив точек маршрута
    NSArray *allCoordinatesArray = [[[[items valueForKey:@"trasses"] objectAtIndex:0] valueForKey:@"r"] valueForKey:@"u"]; // FUUUUCK :(
    for (NSArray *coordinatesArray in allCoordinatesArray)
    {
        int count = [coordinatesArray count];
        CLLocationCoordinate2D coordinates[count];
        int i = 0;
        for (NSDictionary *trassDict in coordinatesArray)
        {
            coordinates[i] = CLLocationCoordinate2DMake([[trassDict valueForKey:@"lat"] doubleValue],
                                                        [[trassDict valueForKey:@"lng"] doubleValue]);
            i++;
        }
        forTransport.routeLine = [MKPolyline polylineWithCoordinates:coordinates count:count];
    }
}









- (void)searchRoutesBetweenCoordinate:(CLLocationCoordinate2D)start andCoordinate:(CLLocationCoordinate2D)stop forObject:(id)callbackObject
{
    // Если уже есть активные соединения, явно надо их закрыть и начать заново
    if (routesLoadObject != nil)
    {
        [self.routesConnection cancel];
        routesLoadObject = nil;
    }

    // Информация об одном транспорте
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    // Делаем запрос
    NSString *urlString = [NSString stringWithFormat:@"%@points[0][lat]=%f&points[0][lng]=%f&points[1][lat]=%f&points[1][lng]=%f&action=routes", transportRoutesURL,
                           start.latitude, start.longitude, stop.latitude, stop.longitude];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"Mozilla/5.0 (X11; U; Linux x86_64; en-US) AppleWebKit/534.10 (KHTML, like Gecko) Chrome/8.0.552.224 Safari/534.10" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://maps.nskgortrans.ru/" forHTTPHeaderField:@"Referer"];
    [request setValue:self.magicCookie forHTTPHeaderField:@"Cookie"];

    // Делаем асинхронный запрос
    self.receivedRoutesData = [NSMutableData dataWithCapacity:1000];
    
    routesLoadObject = callbackObject;
    self.routesConnection = [[NSURLConnection alloc] initWithRequest:request
                                                             delegate:self
                                                     startImmediately:YES];    
}

- (NSArray *)processRoutesResponse:(NSData *)jsonData forObject:(id)callbackObject
{
    // Константа
    const NSDictionary *canonicalTypes = [NSDictionary dictionaryWithObjectsAndKeys:@"Автобус", @"1", @"Троллейбус", @"2", @"Трамвай", @"3", @"Маршрутка", @"8", @"Метро", @"21", nil];
    
    // Обрабатываем ответ в JSON
    JSONDecoder *jsonKitDecoder = [JSONDecoder decoder];
    NSDictionary *items = [jsonKitDecoder objectWithData:jsonData];
        
    // Заполняем массив точек маршрута
    NSArray *allVariantsArray = [[[items valueForKey:@"response"] objectAtIndex:0] valueForKey:@"v"];
    if ([allVariantsArray count] < 1)
    {
        [callbackObject emptyResults];
        return nil;
    }
    
    for (NSDictionary *variantDict in allVariantsArray)
    {
        Route *route = [[Route alloc] init];        
        route.totalPrice = [[[[variantDict valueForKey:@"r"] valueForKey:@"options"] valueForKey:@"total_fare"] integerValue];
        
        NSMutableArray *transportArray = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *pointsArray = [NSMutableArray arrayWithCapacity:5];
        for (NSDictionary *transportDict in [[variantDict valueForKey:@"r"] valueForKey:@"l"])
        {
            Transport *transport = [[[Transport alloc] init] autorelease];
            transport.transportDataSource = self;
            transport.type = [transportDict valueForKey:@"type"];
            if ([transport.type isEqualToString:@"21"]) {
                transport.number = @"";
            } else {
                transport.number = [transportDict valueForKey:@"number"];
            }
            transport.cars = [NSArray array];
            transport.identificator = [NSString stringWithFormat:@"%d-%@-W-%@", [transport.type integerValue], [transportDict valueForKey:@"title"], transport.number];
            transport.canonicalType = [canonicalTypes valueForKey:transport.type];
            transport.stopA = [transportDict valueForKey:@"stop_from"];
            transport.stopB = [transportDict valueForKey:@"stop_to"];
            [route.transport addObject:transport];
            
            NSArray *coordinatesArray = [transportDict valueForKey:@"u"];
            int count = [coordinatesArray count];
            CLLocationCoordinate2D coordinates[count];
            int i = 0;
            for (NSDictionary *pointDict in coordinatesArray)
            {
                if ([[pointDict valueForKey:@"nam"] isEqualToString:transport.stopA])
                    transport.stopACoordinates = CLLocationCoordinate2DMake([[pointDict valueForKey:@"lat"] doubleValue],
                                                                            [[pointDict valueForKey:@"lng"] doubleValue]);
                
                if ([[pointDict valueForKey:@"nam"] isEqualToString:transport.stopB])
                    transport.stopBCoordinates = CLLocationCoordinate2DMake([[pointDict valueForKey:@"lat"] doubleValue],
                                                                            [[pointDict valueForKey:@"lng"] doubleValue]);
                
                coordinates[i] = CLLocationCoordinate2DMake([[pointDict valueForKey:@"lat"] doubleValue],
                                                            [[pointDict valueForKey:@"lng"] doubleValue]);
                i++;
            }
            RoutePolyline *polyline = [RoutePolyline polylineWithCoordinates:coordinates count:count];
            [route.polylines addObject:polyline];
        }
        [callbackObject appendResult:route];        
    }
    return nil;
}









- (void)dealloc
{
    [self.cookieConnection release];
    [self.transportConnection release];
    [self.carsConnection release];
    [self.trassesConnection release];
    [self.routesConnection release];
    [super dealloc];
}








#pragma mark NSURLConnection delegate methods

- (NSURLRequest *)connection:(NSURLConnection *)connection
 			 willSendRequest:(NSURLRequest *)request
 			redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    if (connection == self.cookieConnection)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        self.magicCookie = [[httpResponse allHeaderFields] valueForKey:@"Set-Cookie"];
        [self.cookieConnection cancel];
        [self.cookieConnection release];
    }
    
 	if (connection == self.transportConnection)
    {
        [self.receivedTransportData setLength:0];
    }
    
    if (connection == self.carsConnection)
    {
        [self.receivedCarsData setLength:0];
    }
    
    if (connection == self.trassesConnection)
    {
        [self.receivedCarsData setLength:0];
    }
    
    if (connection == self.routesConnection)
    {
        [self.receivedRoutesData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{    
 	if (connection == self.transportConnection)
    {        
        [self.receivedTransportData appendData:data];
    }
    
    if (connection == self.carsConnection)
    {
        [self.receivedCarsData appendData:data];
    }
    
    if (connection == self.trassesConnection)
    {
        [self.receivedTrassesData appendData:data];
    }
    
    if (connection == self.routesConnection)
    {
        [self.receivedRoutesData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (connection == self.cookieConnection)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Мде" 
                                                        message:@"Не удалось соединиться с сервером NskGorTrans. Ничего не можем поделать." 
                                                       delegate:self 
                                              cancelButtonTitle:@"Эх" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];     
        [self.cookieConnection release];   
    }
    
 	if (connection == self.transportConnection)
    {        
        [transportLoadObject transportLoadError];
        transportLoadObject = nil;
        [self.transportConnection release];
        self.transportConnection = nil;
    }
    
    if (connection == self.carsConnection)
    {
        carsLoadTransportObject = nil;
        [carsLoadObject carsLoadError];
        carsLoadObject = nil;
        [self.carsConnection release];
        self.carsConnection = nil;
    }
    
    if (connection == self.trassesConnection)
    {
        trassesLoadTransportObject = nil;
        [trassesLoadObject carsLoadError];
        trassesLoadObject = nil;
        [self.trassesConnection release];
        self.trassesConnection = nil;
    }
    
    if (connection == self.routesConnection)
    {
        [self.routesConnection release];
        self.routesConnection = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (connection == self.cookieConnection)
    {
        [self.cookieConnection release];
    }
    
 	if (connection == self.transportConnection)
    {
        self.transportList = [NSArray arrayWithArray:[self processTransportResponse:self.receivedTransportData]];
        [transportLoadObject transportLoaded];   
        transportLoadObject = nil;
        [self.transportConnection release];
        self.transportConnection = nil;
    }
    
    if (connection == self.carsConnection)
    {
        carsLoadTransportObject.cars = [self processMarkersResponse:self.receivedCarsData forTransport:carsLoadTransportObject];
        carsLoadTransportObject = nil;
        [carsLoadObject carsLoaded];
        carsLoadObject = nil;
        [self.carsConnection release];
        self.carsConnection = nil;
    }
    
    if (connection == self.trassesConnection)
    {
        [self processTrassesResponse:self.receivedTrassesData forTransport:trassesLoadTransportObject];
        trassesLoadTransportObject = nil;
        [trassesLoadObject trassesLoaded:trassesLoadTransportObject];
        trassesLoadObject = nil;
        [self.trassesConnection release];
        self.trassesConnection = nil;
    }
    
    if (connection == self.routesConnection)
    {
        [self processRoutesResponse:self.receivedRoutesData forObject:routesLoadObject];
        routesLoadObject = nil;
        [self.routesConnection release];
        self.routesConnection = nil;
    }
}
                                 
@end
