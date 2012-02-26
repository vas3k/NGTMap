//
//  AppDelegate.m
//  ngtmap
//
//  Created by Vasily Zubarev on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize searchViewController = _searchViewController;
@synthesize mapViewController = _mapViewController;
@synthesize favoritesViewController = _favoritesViewController;

- (id)init
{
    if (self == [super init])
    {           
//        // Проверка доступности сети
//        static BOOL checkNetwork = YES;        
//        if (checkNetwork) 
//        {
//            checkNetwork = NO;
//            Boolean success;    
//            const char *host_name = "vas3k.ru";
//            
//            SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
//            SCNetworkReachabilityFlags flags;
//            success = SCNetworkReachabilityGetFlags(reachability, &flags);
//            BOOL isConnected = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
//            CFRelease(reachability);
//            if (isConnected == NO)
//            {
//                NSLog(@"NO DATA");
//            }
//        }      
    }
    return self;
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [_searchViewController release];
    [_mapViewController release];
    [_favoritesViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];        
    
    // Контроллер поиска
    _searchViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    _searchViewController.tabBarItem.image = [UIImage imageNamed:@"search.png"];
    
    // И его навигатор
    UINavigationController *searchNavigationViewController = [[UINavigationController alloc] initWithRootViewController:_searchViewController];
    searchNavigationViewController.title = @"Поиск";
    
    // Контроллер избранного
    _favoritesViewController = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
    _favoritesViewController.title = @"Избранное";
    _favoritesViewController.tabBarItem.image = [UIImage imageNamed:@"favorites.png"];
    
    // И его навигатор
    UINavigationController *favoritesNavigationViewController = [[UINavigationController alloc] initWithRootViewController:_favoritesViewController];
    favoritesNavigationViewController.title = @"Избранное";
    
    // Контроллер карты    
    _mapViewController = [[MapViewController alloc] init];
    _mapViewController.title = @"Карта";
    _mapViewController.tabBarItem.image = [UIImage imageNamed:@"map.png"];
    
    // Добавляем все в таббар
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.viewControllers = [NSArray arrayWithObjects: searchNavigationViewController, favoritesNavigationViewController, _mapViewController, nil];
    
    // Не забываем релизнуть навигаторы
    [searchNavigationViewController release];
    [favoritesNavigationViewController release];
    
    // И отображаем
    [self.window addSubview:_tabBarController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
