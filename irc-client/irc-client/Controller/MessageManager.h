//
//  MessageManager.h
//  irc-client
//
//  Created by rannger on 13-10-28.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IRCManager;

@interface MessageManager : NSObject
{
    IRCManager* ircmgr;
    NSArray* msgs;
    __weak UIViewController* viewController;
}

@property (nonatomic,strong) IRCManager* ircmgr;
@property (nonatomic,weak) UIViewController* viewController;

- (BOOL)parseMessage:(NSString*)messageString;
@end
