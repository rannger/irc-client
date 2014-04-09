//
//  ChatViewController.m
//  irc client
//
//  Created by derek on 13-10-25.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import "MainViewController.h"
#import "Command.h"
#import "ChannelViewController.h"
#import "Message.h"
#import "MessageManager.h"
#import "ChatViewController.h"
#import "NSString+Height.h"

@interface MainViewController ()
- (void)keyboardWillChange:(NSNotification*)notification;
- (void)keyboardWillhide:(NSNotification *)notification;
@end

@implementation MainViewController
@synthesize serverName;
@synthesize nickName;
@synthesize userName;
@synthesize realName;
@synthesize password;
@synthesize port;
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    resultArr=[NSMutableArray arrayWithCapacity:100];
    self.title=manager.nickName;
    manager=[[IRCManager alloc] init];
    self.title=@"Plz wait...";
    manager.nickName=self.nickName;
    manager.serverName=self.serverName;
    manager.port=self.port;
    manager.delegate=self;
    
    msgManager=[[MessageManager alloc] init];
    msgManager.ircmgr=manager;
    msgManager.viewController=self;
    
    CGRect frame=self.view.bounds;
    frame.size.height-=44.0f;
    self.tableView=[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    toolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 44)];
    toolbar.barStyle=UIBarStyleDefault;
    [self.view addSubview:toolbar];

    textField=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
    textField.borderStyle=UITextBorderStyleRoundedRect;
    textField.returnKeyType=UIReturnKeySend;
    textField.delegate=self;
    textField.placeholder=@"Plz wait...";
    UIBarButtonItem* editItem=[[UIBarButtonItem alloc] initWithCustomView:textField];
    [toolbar setItems:@[editItem]];
    
    UIActivityIndicatorView *ai=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [ai startAnimating];
    UIBarButtonItem* rightItem=[[UIBarButtonItem alloc] initWithCustomView:ai];
    self.navigationItem.rightBarButtonItem=rightItem;
    rightItem.enabled=NO;
    
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc] initWithTitle:@"Quit" style:UIBarButtonItemStylePlain target:self action:@selector(quit)];
    self.navigationItem.leftBarButtonItem=leftItem;
    
    [toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger idx, BOOL *stop) {
        item.enabled=NO;
    }];
    
    UITapGestureRecognizer* gr=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.tableView addGestureRecognizer:gr];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quit) name:@"MainViewController_QUIT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:@"ApplicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:@"ApplicationDidBecomeActive" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hasBeenQuit:) name:@"QUIT" object:nil];
    
}

- (void)resignActive
{
    isBackground=YES;
}

- (void)becomeActive
{
    isBackground=NO;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MainViewController_QUIT" object:nil];
}
- (void)tapView
{
    [textField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RPL_WELCOME" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ERR_NICKNAMEINUSE" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JOIN" object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotification];
    if (![manager isConnected]) {
     [manager connect];
    }
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillhide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyWelcome) name:@"RPL_WELCOME" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameHasBeenUsed:) name:@"ERR_NICKNAMEINUSE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedChannel:) name:@"JOIN" object:nil];
   
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - Keyboard notification

- (void)keyboardWillChange:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    
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

#pragma mark - Notification handle
- (void)hasBeenQuit:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSString* name=[dic[kMessagePrefix] componentsSeparatedByString:@"!"][0];
    if ([manager.nickName isEqualToString:name]) {
        if (isBackground) {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Connect Time out" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            isBackground=NO;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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


- (void)replyWelcome
{
    [toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger idx, BOOL *stop) {
        item.enabled=YES;
    }];
    textField.placeholder=@"Message...";
    self.title=self.nickName;
    
    UIBarButtonItem* rightItem=[[UIBarButtonItem alloc] initWithTitle:@"Channel" style:UIBarButtonItemStylePlain target:self action:@selector(channel)];
    self.navigationItem.rightBarButtonItem=rightItem;
}

- (void)nameHasBeenUsed:(NSNotification*)notification
{
    [manager disconnect];
    NSDictionary* dic=[notification userInfo];
    if (count++<1) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:dic[kMessageTail] message:dic[kMessageTail] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)quit
{
    [manager disconnect];
  
}


- (void)send
{

}

- (void)channel
{
    [textField resignFirstResponder];
    ChannelViewController* channelViewController=[[ChannelViewController alloc] init];
    [channelViewController.channelList addObjectsFromArray:manager.joinedChannelList];
    channelViewController.manager=manager;
    
	[self.navigationController pushViewController:channelViewController animated:YES];
    
}


#pragma mark - IRCManagerDelegate

- (void)responseWithArray:(NSArray*)array
{
    [array enumerateObjectsUsingBlock:^(NSDictionary* dic, NSUInteger idx, BOOL *stop) {
        [resultArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"message":dic[kMessageTail],@"height":@(0)}]];
    }];
    [self.tableView reloadData];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[resultArr count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [msgManager parseMessage:aTextField.text];
    [aTextField resignFirstResponder];
    textField.text=nil;
    return YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [resultArr count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* Identifier=@"MainViewControllerCell";
    UITableViewCell* cell=[aTableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.textLabel.numberOfLines=0;
        cell.textLabel.lineBreakMode=NSLineBreakByWordWrapping;
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text=resultArr[indexPath.row][@"message"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height=[resultArr[indexPath.row][@"height"] floatValue];
    if (height<=0.0f) {
        NSString* string=resultArr[indexPath.row][@"message"];
        height=[string heightWithFont:[UIFont systemFontOfSize:14] constrainedToWidth:280.0f lineBreakMode:NSLineBreakByWordWrapping];
        height=height>20.0?height:20.0;
        resultArr[indexPath.row][@"height"]=@(height);
        return height;
    }
    return height;
}
    
@end
