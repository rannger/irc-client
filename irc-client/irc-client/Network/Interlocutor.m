//
//  Interlocutor.m
//  irc-client
//
//  Created by rannger on 13-10-29.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "Interlocutor.h"
#import "IRCManager.h"
#import "Message.h"

@implementation Interlocutor
@synthesize ircmgr;
@synthesize delegate;
@synthesize receiver;

- (id)init
{
    self=[super init];
    if (self) {
        messages=[NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(message:) name:@"PRIVMSG" object:nil];
    }
    
    return self;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObject:(NSObject*)object
{
    if (![messages containsObject:object]) {
        [messages addObject:object];
    }
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [NSDictionary dictionaryWithDictionary:messages[indexPath.row]];
}

- (void)message:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSLog(@"%@",dic);
    NSString* userName=[dic[kMessagePrefix] componentsSeparatedByString:@"!"][0];
    NSString* message=dic[kMessageTail];
    if ([self.receiver isEqualToString:dic[kMessageArges]]) {
        [messages addObject:@{@"userName": userName,@"message":message}];
        if (self.delegate) {
            [self.delegate dataHasArrival:self];
        }
    }
    
}

- (void)sendMessage:(NSString*)msg
{
    [ircmgr sendMessage:msg channelName:self.receiver];
    [self addObject:@{@"userName":ircmgr.nickName,@"message":msg}];
    if (self.delegate) {
        [self.delegate dataHasArrival:self];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InterlocutorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines=0;
        cell.textLabel.lineBreakMode=NSLineBreakByWordWrapping;
        cell.textLabel.font=[UIFont systemFontOfSize:14];
    }
    if ([ircmgr.nickName isEqualToString:messages[indexPath.row][@"userName"]]) {
        cell.textLabel.textColor=[UIColor redColor];
    }
    else{
        cell.textLabel.textColor=[UIColor blackColor];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%@说：%@",messages[indexPath.row][@"userName"],messages[indexPath.row][@"message"]];
    return cell;
}

@end
