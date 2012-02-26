//
//  SearchCell.m
//  ngtmap
//
//  Created by Vasily Zubarev on 13.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchCell.h"
#import "AppDelegate.h"

@implementation SearchCell

@synthesize trans, icon, numberLabel, typeLabel, stopALabel, stopBLabel, favoritesButton;

- (void)fillWithTransport:(Transport *)transport
{
    self.trans = transport;
    self.icon.image = transport.icon;
    self.numberLabel.text =  transport.number;
    self.typeLabel.text =  transport.canonicalType;
    self.stopALabel.text = transport.stopA;
    self.stopBLabel.text = transport.stopB;
    [self.favoritesButton setHidden:(!transport.inFavorites)];
}

- (IBAction)toggleFavorites:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.favoritesViewController addOrRemoveFromFavorites:self.trans];
    [appDelegate.favoritesViewController.tabBarController setSelectedIndex:1];      
}

@end
