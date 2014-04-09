//
//  ChannelViewController.h
//  irc client
//
//  Created by derek on 13-10-25.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IRCManager;

@interface ChannelViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate,UIAlertViewDelegate>
{
    NSMutableArray* channelList;
    NSMutableArray* searchReultList;
    IRCManager* manager;
    UISearchDisplayController* searchDisplayCtrl;
}

@property (nonatomic,strong) NSMutableArray* channelList;
@property (nonatomic,strong) IRCManager* manager;
@end
