//
//  AppDelegate.h
//  ngtmap
//
//  Created by Vasily Zubarev on 12.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "SearchViewController.h"
#import "FavoritesViewController.h"
#import "MapViewController.h"


@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) FavoritesViewController *favoritesViewController;

@end
