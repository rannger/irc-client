//
//  Command.m
//  core
//
//  Created by derek on 13-10-25.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import "Command.h"
#import <string.h>
@implementation Command
@synthesize commandName;
@synthesize params;

- (void)dealloc
{
    self.commandName=nil;
    self.params=nil;
}

- (NSData*)genericData
{
    static Byte byte=0x20;
    static Byte end[]={0x0d,0x0a};
    NSMutableData* data=[NSMutableData dataWithData:[self.commandName dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendBytes:&byte length:1];
    for (NSString* param in self.params) {
        [data appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendBytes:&byte length:1];
    }
    [data appendBytes:end length:2];
    return data;
}

@end

@implementation Command (PASS)

+ (Command*)passCommandWithPassword:(NSString*)password
{
    Command* command=[[Command alloc] init];
    command.commandName=@"PASS";
    command.params=@[password];
    return command;
}

@end

@implementation Command (NICK)

+ (Command*)nickCommandWithNickName:(NSString*)nickName
{
    Command* command=[[Command alloc] init];
    command.commandName=@"NICK";
    command.params=@[nickName];
    return command;

}

@end

@implementation Command (USER)

+ (Command*)userCommandWithUserName:(NSString*)userName
                           hostName:(NSString*)hostName
                         serverName:(NSString*)serverName
                           realName:(NSString*)realName
{
    Command* command=[[Command alloc] init];
    command.commandName=@"USER";
    command.params=@[userName,hostName,serverName,realName];
    return command;
}

@end

@implementation Command (Whois)

+ (Command*)whoisCommandWithNickName:(NSString*)nickName
{
    Command* command=[[Command alloc] init];
    command.commandName=@"WHOIS";
    command.params=@[nickName];
    return command;
}

@end

@implementation Command (QUIT)

+ (Command*)quitCommandWithMessage:(NSString*)message
{
    Command* command=[[Command alloc] init];
    command.commandName=@"QUIT";
    command.params=@[message];
    return command;
}

@end

@implementation Command (JOIN)

+ (Command*)joinCommandWithChannel:(NSString*)channel
{
    Command* command=[[Command alloc] init];
    command.commandName=@"JOIN";
    command.params=@[channel];
    return command;
}

@end

@implementation Command (PRIVMSG)

+ (Command*)sendCommandWithMessage:(NSString*)message receive:(NSString*)receive;
{
    Command* command=[[Command alloc] init];
    command.commandName=@"PRIVMSG";
    command.params=@[receive,[@":" stringByAppendingString:message]];
    return command;
}

@end

@implementation Command (LIST)

+ (Command*)listCommand
{
    Command* command=[[Command alloc] init];
    command.commandName=@"LIST";
    command.params=@[];
    return command;
}

+ (Command*)listCommandWithChannelNames:(NSString*)channelNameList
{
    Command* command=[[Command alloc] init];
    command.commandName=@"LIST";
    command.params=@[channelNameList];
    return command;
}
@end

@implementation Command (PING)

+ (Command*)pingCommandWithServerHost:(NSString*)serverHost
{
    Command* command=[[Command alloc] init];
    command.commandName=@"PING";
    command.params=@[serverHost];
    return command;
}

+ (Command*)pingCommandWithUserName:(NSString*)userName
{
    return [self pingCommandWithServerHost:userName];
}

+ (Command*)pingCommandWithHosts:(NSArray*)hosts
{
    Command* command=[[Command alloc] init];
    command.commandName=@"PING";
    command.params=hosts;
    return command;
}
@end

@implementation Command (PONG)

+ (Command*)pongCommandWithServerHost:(NSString*)serverHost
{
    Command* command=[[Command alloc] init];
    command.commandName=@"PONG";
    command.params=@[serverHost];
    return command;
}
@end

@implementation Command (NAMES)

+ (Command*)namesCommandWithChannelName:(NSString *)channelName
{
    Command* command=[[Command alloc] init];
    command.commandName=@"NAMES";
    command.params=@[channelName];
    return command;
}

@end

@implementation Command (Part)

+ (Command*)partCommandWithChannelName:(NSString*)channelName
{
    Command* command=[[Command alloc] init];
    command.commandName=@"PART";
    command.params=@[channelName];
    return command;

}

@end

@implementation Command (Notice)

+ (Command*)noticeCommandWithNickName:(NSString*)nickname message:(NSString*)message
{
    Command* command=[[Command alloc] init];
    command.commandName=@"NOTICE";
    command.params=@[nickname,message];
    return command;
}

@end