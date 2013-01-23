//
//  SearchCell.m
//  ngtmap
//
//  Created by vas3k on 12.02.12.
//

#import "SearchCell.h"
#import "AppDelegate.h"

@implementation SearchCell

@synthesize trans, icon, numberLabel, stopALabel, favoritesButton;

- (void)fillWithTransport:(Transport *)transport
{
    // Установка кастомного бекграунда
    UIImageView *av = [[[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)] autorelease];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    av.image = [UIImage imageNamed:@"bg_search_cell.png"];
    self.backgroundView = av;
    
    // Заполнение инфы
    self.trans = transport;
    self.icon.image = transport.icon;
    self.numberLabel.text =  [NSString stringWithFormat:@"%@ %@", transport.number, transport.canonicalType];
    self.stopALabel.text = [NSString stringWithFormat:@"%@ — %@", transport.stopA, transport.stopB];
    [self.favoritesButton setHidden:(!transport.inFavorites)];
}

- (IBAction)toggleFavorites:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.favoritesViewController addOrRemoveFromFavorites:self.trans];
    [appDelegate.favoritesViewController.tabBarController setSelectedIndex:1];      
}

@end
