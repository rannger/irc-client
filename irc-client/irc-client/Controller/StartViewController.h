//
//  StartViewController.h
//  irc-client
//
//  Created by rannger on 13-10-27.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UITableViewController <UITextFieldDelegate>
{
    UITextField* serverName;
    UITextField* nickName;
    UITextField* userName;
    UITextField* realName;
    UITextField* port;
    NSArray* textFields;
}

@end
