//
//  IRCManager.m
//  irc-client
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "IRCManager.h"
#import "Message.h"
#import "Command.h"
#import "Interlocutor.h"

@implementation IRCManager
@synthesize serverName;
@synthesize nickName;
@synthesize port;
@synthesize delegate;
@synthesize joinedChannelList;
@synthesize messages;
@synthesize realName;
@synthesize userName;

- (id)init
{
    self=[super init];
    if (self) {
        joinedChannelList=[NSMutableArray array];
        channelList=[NSMutableArray array];
        messages=[NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responsePing:) name:@"PING" object:nil];
    }
    return self;
}

- (void)dealloc
{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)responsePing:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSString* serverHost=dic[kMessageTail];
    Command* cmd=[Command pongCommandWithServerHost:serverHost];
    [self sendCommand:cmd];
}

- (void)joinChannel:(NSString*)channelName
{
    Command* command=[Command joinCommandWithChannel:channelName];
    [self sendCommand:command];
}

- (BOOL)sendCommand:(Command*)cmd
{
    NSData* data=[cmd genericData];
    BOOL isConnected=[self isConnected];
    [outputStream write:[data bytes] maxLength:[data length]];

    return isConnected;
}

- (BOOL)isConnected
{
    return [outputStream streamStatus]==NSStreamStatusOpen&&[inputStream streamStatus]==NSStreamStatusOpen;
}

- (void)connect
{
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)serverName, (UInt32)port, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
    
    if ([self.realName length]==0) {
        self.realName=@":Ronnie Reagan";
    }
    
    if ([self.userName length]==0) {
        self.userName=self.nickName;
    }
    
    NSArray* arr=@[[Command passCommandWithPassword:nickName],
                   [Command nickCommandWithNickName:nickName],
                   [Command userCommandWithUserName:userName
                                           hostName:@"tolmoon"
                                         serverName:@"tolsun"
                                           realName:self.realName]];

    
    for (Command* command in arr) {
        [self sendCommand:command];
    }
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSInteger length=0;
    NSMutableString* tempString=[NSMutableString string];
    while ([inputStream hasBytesAvailable]) {
        Byte bytes[1024]={0};
        
        length=[inputStream read:bytes maxLength:1024];
        if (length==0) {
            return;
        }
        
        NSString* string=[[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        if ([string length]!=0) {
            [tempString appendString:string];
        }
    }
    
    if ([tempString length]!=0) {
        NSArray* array=[tempString componentsSeparatedByString:@"\r\n"];
        NSMutableArray* result=[NSMutableArray array];
        for (NSString* message in array) {
            if ([message length]!=0) {
                NSDictionary* dic=[Message parseMessage:message];
                if (dic!=nil) {
                       [result addObject:dic];
                }
            }
            
        }
        if (self.delegate) {
            [self.delegate responseWithArray:result];
        }
        for (NSDictionary* dic in result) {
            NSLog(@"%@",dic);
            [[NSNotificationCenter defaultCenter] postNotificationName:dic[kMessageCommand] object:nil userInfo:dic];
        }
    }
    
}

- (void)disconnect
{
    Command* cmd=[Command quitCommandWithMessage:@""];
    [self sendCommand:cmd];
}

- (void)sendMessage:(NSString*)message channelName:(NSString*)channelName
{
    Command* msg=[Command sendCommandWithMessage:message receive:channelName];
    [self sendCommand:msg];
}

- (void)getChannelList
{
    Command* cmd=[Command listCommand];
    [self sendCommand:cmd];
}
@end
