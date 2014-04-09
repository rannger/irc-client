//
//  NSString+Height.m
//  irc-client
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "NSString+Height.h"

@implementation NSString (Height)

- (CGFloat)heightWithFont:(UIFont*)font
       constrainedToWidth:(CGFloat)width
            lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    return [self sizeWithFont:font
            constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                lineBreakMode:lineBreakMode].height;
}

@end
