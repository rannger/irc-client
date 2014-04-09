//
//  MessageManager.m
//  irc-client
//
//  Created by rannger on 13-10-28.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "MessageManager.h"
#import "IRCManager.h"
#import "ChatViewController.h"
#import "MainViewController.h"
#import "Command.h"
#import "Interlocutor.h"
/**
    the warning is noisy!!!
 */
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0);

@implementation MessageManager
@synthesize viewController;
@synthesize ircmgr;

- (id)init
{
    self=[super init];
    if (self) {
        msgs=@[@"join",@"me",@"msg",@"nick",@"notice",@"part",@"ping",@"query",@"quit",@"whois",@"help"];
    }
    return self;
}

- (BOOL)parseMessage:(NSString*)messageString
{
    if ([messageString hasPrefix:@"/"]) {
        NSArray* list=[messageString componentsSeparatedByString:@" "];
        NSString* msg=[list[0] substringFromIndex:1];
        
        for (NSString* obj in msgs) {
            if ([msg isEqualToString:obj]) {
                SEL selector=NSSelectorFromString([msg stringByAppendingString:@":"]);
                NSArray* params=nil;
                if ([list count]>1) {
                    params=[list subarrayWithRange:NSMakeRange(1, [list count]-1)];
                }
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:params]);
                return YES;
            }
        }
        
    }
    return NO;
}

- (void)join:(NSArray*)params
{
    if ([params count]>0) {
        BOOL joined=NO;
        for (NSDictionary* dic in ircmgr.joinedChannelList) {
            if ([dic[@"name"] isEqualToString:params[0]]) {
                joined=YES;
                break;
            }
        }
        if (joined) {
            ChatViewController* ctrl=[[ChatViewController alloc] initWithStyle:ChatViewControllerStyleChannel];
            ctrl.manager=ircmgr;
            ctrl.receiver=params[0];
            ctrl.title=ctrl.receiver;
            [viewController.navigationController pushViewController:ctrl animated:YES];
            
        }
        else
        {
            [ircmgr joinChannel:params[0]];
        }
    }
}

- (void)me:(NSArray*)params
{
    if ([viewController respondsToSelector:@selector(receiver)]) {
        NSString* receiver=[viewController performSelector:@selector(receiver) withObject:nil];
        NSString* msg=[NSString stringWithFormat:@"%cACTION %@%c",0x01,[params componentsJoinedByString:@" "],0x01];
        [ircmgr sendMessage:msg channelName:receiver];
    }
}

- (void)msg:(NSArray*)params
{
    if ([params count]>=2) {
        NSString* receiver=params[0];
        NSInteger count=[params count]-1;
        
        NSString* text2Send=[NSString stringWithFormat:@"%@说:%@",ircmgr.nickName,[[params subarrayWithRange:NSMakeRange(1, count)] componentsJoinedByString:@" "]];
        Interlocutor* interlocutor=nil;
        if (interlocutor==nil) {
            interlocutor=[[Interlocutor alloc] init];
            ircmgr.messages[receiver]=interlocutor;
            interlocutor.receiver=receiver;
            interlocutor.ircmgr=ircmgr;
        }
        [interlocutor sendMessage:text2Send];
    }
}

- (void)nick:(NSArray*)params
{
    if ([params count]>=1) {
        NSString* newNickname=params[0];
        Command* cmd=[Command nickCommandWithNickName:newNickname];
        [ircmgr sendCommand:cmd];
    }
}

- (void)notice:(NSArray*)params
{
    if ([params count]>=2) {
        NSString* receiver=params[0];
        NSInteger count=[params count]-1;
        
        NSString* text2Send=[[params subarrayWithRange:NSMakeRange(1, count)] componentsJoinedByString:@" "];
        Command* cmd=[Command noticeCommandWithNickName:receiver message:text2Send];
        [ircmgr sendCommand:cmd];
    }
}

- (void)part:(NSArray*)params
{
    BOOL joined=NO;
    BOOL popWhenFinish=NO;
    NSString* channelName=nil;
    if ([params count]!=0) {
        channelName=params[0];
    }
    else
    {
        if ([viewController respondsToSelector:@selector(receiver)]) {
            channelName=[viewController performSelector:@selector(receiver) withObject:nil];
            popWhenFinish=YES;
        }
        else
            return;
    }
    for (NSDictionary* channel in ircmgr.joinedChannelList) {
        if ([channel[@"name"] isEqualToString:channelName]) {
            joined=YES;
            break;
        }
    }
    if (joined) {
        Command* cmd=[Command partCommandWithChannelName:channelName];
        [ircmgr sendCommand:cmd];
        for (NSDictionary* dic in ircmgr.joinedChannelList) {
            if ([dic[@"name"] isEqualToString:channelName]) {
                [ircmgr.joinedChannelList removeObject:dic];
                break;
            }
        }
    }
    if (popWhenFinish) {
        [viewController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)ping:(NSArray*)params
{
    if ([params count]>=1) {
        Command* cmd=[Command pingCommandWithHosts:params];
        [ircmgr sendCommand:cmd];
    }
}

- (void)query:(NSArray*)params
{
    [self msg:params];
}

- (void)quit:(NSArray*)params
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainViewController_QUIT" object:nil];
}

- (void)whois:(NSArray*)params
{
    if ([params count]>1) {
        NSString* nickName=[params firstObject];
        Command* cmd=[Command whoisCommandWithNickName:nickName];
        [ircmgr sendCommand:cmd];
    }
}

- (void)help:(NSArray*)params
{
    
}

@end
