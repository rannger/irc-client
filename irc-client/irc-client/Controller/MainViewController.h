//
//  ChatViewController.h
//  irc client
//
//  Created by derek on 13-10-25.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRCManager.h"

@class MessageManager;
@interface MainViewController : UIViewController <UITextFieldDelegate,IRCManagerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    IRCManager* manager;
    NSMutableArray* resultArr;
    UIToolbar* toolbar;
    UITextField* textField;
    UITableView* tableView;
    MessageManager* msgManager;
    BOOL isBackground;
    
    NSInteger count;
}
@property (nonatomic,copy) NSString* serverName;
@property (nonatomic,copy) NSString* nickName;
@property (nonatomic,copy) NSString* userName;
@property (nonatomic,copy) NSString* realName;
@property (nonatomic,copy) NSString* password;
@property (nonatomic) NSInteger port;
@property (nonatomic,strong) UITableView* tableView;

@end
