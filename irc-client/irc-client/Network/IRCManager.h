//
//  IRCManager.h
//  irc-client
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Command;

@protocol IRCManagerDelegate <NSObject>
- (void)responseWithArray:(NSArray*)array;
@end

@interface IRCManager : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableArray* joinedChannelList;
    NSMutableArray* channelList;
    NSInteger port;
    NSString* nickName;
    NSString* realName;
    NSString* serverName;
    NSString* userName;
    
    NSMutableDictionary* messages;
    __weak id<IRCManagerDelegate> delegate;
}
@property (nonatomic,strong) NSMutableArray* joinedChannelList;
@property (nonatomic,strong) NSMutableDictionary* messages;
@property (nonatomic,copy) NSString* nickName;
@property (nonatomic,copy) NSString* serverName;
@property (nonatomic,copy) NSString* realName;
@property (nonatomic,copy) NSString* userName;
@property (nonatomic) NSInteger port;
@property (nonatomic,weak) id<IRCManagerDelegate> delegate;

- (BOOL)isConnected;
- (BOOL)sendCommand:(Command*)cmd;
- (void)joinChannel:(NSString*)channelName;
- (void)connect;
- (void)disconnect;
- (void)sendMessage:(NSString*)message channelName:(NSString*)channelName;
- (void)getChannelList;
@end
