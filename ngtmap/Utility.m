//
//  Utility.m
//  ngtmap
//
//  Created by ReDetection on 3/2/13.
//

#import "Utility.h"

@implementation Utility


+ (UIImage *)resizableImageNamed: (NSString *)filename {
    UIImage *image = [UIImage imageNamed:filename];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)];
    } else {
        image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:15];
    }
    return image;
}

@end
