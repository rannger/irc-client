//
//  NSString+Height.h
//  irc-client
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Height)
- (CGFloat)heightWithFont:(UIFont*)font
       constrainedToWidth:(CGFloat)width
            lineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
