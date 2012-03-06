//
//  NGTDataSource.m
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NGTDataSource.h"

NSString * const transportAllURL = @"http://maps.nskgortrans.ru/listmarsh.php?r";
NSString * const transportCoordinatesURL = @"http://maps.nskgortrans.ru/markers.php?r=";
NSString * const mainUrl = @"http://maps.nskgortrans.ru/";

@implementation NGTDataSource

@synthesize cookieConnection, transportConnection, carsConnection, receivedTransportData, receivedCarsData;
@synthesize magicCookie;

- (id)init
{
    if (self = [super init])
    {
        [self loadPeriodicalData];
    }
    return self;
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
    NSMutableArray *newTransportList = [NSMutableArray arrayWithCapacity:100];
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
    return newTransportList;    
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

- (void)dealloc
{
    [self.cookieConnection release];
    [self.transportConnection release];
    [self.carsConnection release];
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
    }
    
    if (connection == self.carsConnection)
    {
        carsLoadTransportObject = nil;
        [carsLoadObject carsLoadError];
        carsLoadObject = nil;
        [self.carsConnection release];        
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
    }
    
    if (connection == self.carsConnection)
    {
        carsLoadTransportObject.cars = [self processMarkersResponse:self.receivedCarsData forTransport:carsLoadTransportObject];
        carsLoadTransportObject = nil;
        [carsLoadObject carsLoaded];
        carsLoadObject = nil;
        [self.carsConnection release];
    }
}
                                 
@end
