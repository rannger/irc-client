//
//  NamesViewController.h
//  irc-client
//
//  Created by rannger on 13-10-28.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IRCManager;
@interface NamesViewController : UITableViewController
{
    IRCManager* manager;
    NSMutableArray* namelist;
    NSString* channelName;
}

@property (nonatomic,strong) IRCManager* manager;
@property (nonatomic,copy) NSString* channelName;
@end
