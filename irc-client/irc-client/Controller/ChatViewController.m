//
//  ChatViewController.m
//  irc-client
//
//  Created by rannger on 13-10-26.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "ChatViewController.h"
#import "NSString+Height.h"
#import "Message.h"
#import "IRCManager.h"
#import "Command.h"
#import "NamesViewController.h"
#import "MessageManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ChatViewController ()

@end

@implementation ChatViewController
@synthesize topic;
@synthesize manager;
@synthesize tableView;
@synthesize receiver;


- (id)initWithStyle:(ChatViewControllerStyle)aStyle
{
    self=[super init];
    if (self) {
        style=aStyle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Interlocutor* interlocutor=manager.messages[self.receiver];
    if (interlocutor==nil) {
        interlocutor=[[Interlocutor alloc] init];
        manager.messages[self.receiver]=interlocutor;
        interlocutor.receiver=self.receiver;
        interlocutor.ircmgr=manager;
    }
    interlocutor.delegate=self;
    CGFloat height=self.view.frame.size.height-44.0;
    msgMgr=[[MessageManager alloc] init];
    msgMgr.viewController=self;
    msgMgr.ircmgr=manager;
    heightList=[NSMutableDictionary dictionary];
    self.tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, height) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=interlocutor;
    [self.view addSubview:self.tableView];
    toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, height, 320, 44)];
    textField=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
    textField.borderStyle=UITextBorderStyleRoundedRect;
    textField.returnKeyType=UIReturnKeySend;
    textField.placeholder=@"Message...";
    textField.delegate=self;
    UIBarButtonItem* textItem=[[UIBarButtonItem alloc] initWithCustomView:textField];
    toolbar.items=@[textItem];
    [self.view addSubview:toolbar];
    UITapGestureRecognizer* gr=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.tableView addGestureRecognizer:gr];
    
    if (style==ChatViewControllerStyleChannel) {
        UIBarButtonItem* rightItem=[[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(menu)];
        self.navigationItem.rightBarButtonItem=rightItem;
    }
}

- (void)menu
{
    [textField resignFirstResponder];
    UIActionSheet* as=[[UIActionSheet alloc] initWithTitle:@"Menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Part",@"Names", nil];
    [as showFromToolbar:toolbar];
}

- (void)part
{
    Command* cmd=[Command partCommandWithChannelName:self.title];
    [manager sendCommand:cmd];
    for (NSDictionary* dic in manager.joinedChannelList) {
        if ([dic[@"name"] isEqualToString:self.receiver]) {
            [manager.joinedChannelList removeObject:dic];
            break;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapView
{
    [textField resignFirstResponder];
}

- (void)keyboardWillChange:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect frame=self.view.frame;
    frame.origin.y=-kbSize.height;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillhide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.15];
    
    CGRect frame=self.view.frame;
    
    frame.origin=CGPointZero;
    self.view.frame=frame;
    [UIView commitAnimations];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedChannel:) name:@"JOIN" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillhide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendMessage
{
    NSString* message=textField.text;
    if (![msgMgr parseMessage:message]) {
        Interlocutor* interlocutor=manager.messages[self.receiver];
        [interlocutor sendMessage:message];
    }
    textField.text=nil;
}

- (void)joinedChannel:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSString* name=[dic[kMessagePrefix] componentsSeparatedByString:@"!"][0];
    if ([manager.nickName isEqualToString:name]) {
        ChatViewController* ctrl=[[ChatViewController alloc] initWithStyle:ChatViewControllerStyleChannel];
        ctrl.manager=manager;
        NSArray* array=[dic[kMessageArges] componentsSeparatedByString:@" "];
        if ([array count]<=1)
            ctrl.title=[array lastObject];
        else
            ctrl.title=array[1];
        ctrl.receiver=ctrl.title;
        
        [manager.joinedChannelList addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name": ctrl.title}]];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (heightList[indexPath]!=nil) {
        return [heightList[indexPath] floatValue];
    }
    Interlocutor* interlocutor=manager.messages[self.receiver];
    NSDictionary* dic=[interlocutor objectAtIndexPath:indexPath];
    NSString* string=[NSString stringWithFormat:@"%@说：%@",dic[@"userName"],dic[@"message"]];
    CGFloat height=[string heightWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:280.0f lineBreakMode:NSLineBreakByWordWrapping]+10.0;
    height=height>44.0?height:44.0;
    heightList[indexPath]=@(height);
    return height;

}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.topic==nil||[self.topic length]==0) {
        return nil;
    }
    UITextView* label=[[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    label.text=self.topic;
    label.font=[UIFont systemFontOfSize:14];
    label.editable=NO;
    label.scrollEnabled=NO;
    CGFloat height=[self.topic heightWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:300 lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rect=label.frame;
    rect.size.height=height;
    label.frame=rect;
    label.layer.borderColor=[[UIColor grayColor] CGColor];
    label.layer.borderWidth=0.5;
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.topic==nil||[self.topic length]==0) {
        return 0.0f;
    }
    CGFloat height=[self.topic heightWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:300 lineBreakMode:NSLineBreakByWordWrapping];
    return height;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [self sendMessage];
    [aTextField resignFirstResponder];
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self part];
            break;
        case 1:
        {
            NamesViewController* ctrl=[[NamesViewController alloc] initWithStyle:UITableViewStylePlain];
            ctrl.manager=manager;
            ctrl.channelName=self.receiver;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)dataHasArrival:(Interlocutor*)interlocutor
{
    [self.tableView reloadData];

}

@end
