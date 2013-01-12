//
//  InfoViewController.h
//  ngtmap
//
//  Created by Vasily Zubarev on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface InfoViewController : UIViewController <SKProductsRequestDelegate> {
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
}

- (IBAction)hideMe;
- (IBAction)donate:(id)sender;

@end
