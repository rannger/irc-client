//
//  Message.h
//  core
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* kMessagePrefix;
extern NSString* kMessageCommand;
extern NSString* kMessageArges;
extern NSString* kMessageTail;

@interface Message : NSObject

+ (NSDictionary*)parseMessage:(NSString*)messageString;
+ (NSDictionary*)ircFlags;
@end

