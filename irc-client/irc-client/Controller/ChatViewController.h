//
//  ChatViewController.h
//  irc-client
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Interlocutor.h"



typedef enum ChatViewControllerStyle
{
    ChatViewControllerStyleChannel = 0,
    ChatViewControllerStyleUser
}ChatViewControllerStyle;

@class MessageManager;
@class IRCManager;


@interface ChatViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UIActionSheetDelegate,InterlocutorDelegate>
{
    NSString* topic;
    UIToolbar* toolbar;
    UITextField* textField;
    IRCManager* manager;
    UITableView* tableView;
    NSString* receiver;
    MessageManager* msgMgr;
    ChatViewControllerStyle style;
    NSMutableDictionary* heightList;
}
@property (nonatomic,copy) NSString* topic;
@property (nonatomic,copy) NSString* receiver;
@property (nonatomic,strong) IRCManager* manager;
@property (nonatomic,strong) UITableView* tableView;
- (id)initWithStyle:(ChatViewControllerStyle)style;
@end
