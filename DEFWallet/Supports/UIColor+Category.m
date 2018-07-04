//
//  UIColor+Category.m
//  DEFWallet
//
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

/**
init color with hex value
 
 @param hex 1d2d3d
 @return color
 */
+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

@end
