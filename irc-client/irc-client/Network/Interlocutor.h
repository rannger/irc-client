//
//  Interlocutor.h
//  irc-client
//
//  Created by rannger on 13-10-29.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IRCManager;
@class Interlocutor;
@protocol InterlocutorDelegate <NSObject>
- (void)dataHasArrival:(Interlocutor*)interlocutor;
@end

@interface Interlocutor : NSObject <UITableViewDataSource>
{
    NSMutableArray* messages;
    __weak IRCManager* ircmgr;
    __weak id<InterlocutorDelegate> delegate;
    NSString* receiver;
}

@property (nonatomic,weak) IRCManager* ircmgr;
@property (nonatomic,weak) id<InterlocutorDelegate> delegate;
@property (nonatomic,copy) NSString* receiver;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (void)addObject:(NSObject*)object;
- (void)sendMessage:(NSString*)msg;
@end
