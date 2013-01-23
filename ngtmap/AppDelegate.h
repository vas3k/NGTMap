//
//  AppDelegate.h
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "SearchViewController.h"
#import "RoutesViewController.h"
#import "FavoritesViewController.h"
#import "MapViewController.h"


@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) RoutesViewController *routesViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) FavoritesViewController *favoritesViewController;

@end
