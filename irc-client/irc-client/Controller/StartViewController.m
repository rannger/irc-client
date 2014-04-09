//
//  StartViewController.m
//  irc-client
//
//  Created by rannger on 13-10-27.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "StartViewController.h"
#import "MainViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Start";
    CGRect frame=CGRectMake(100, 2, 200, 40);
    serverName=[[UITextField alloc] initWithFrame:frame];
    nickName=[[UITextField alloc] initWithFrame:frame];
    userName=[[UITextField alloc] initWithFrame:frame];
    realName=[[UITextField alloc] initWithFrame:frame];
    port=[[UITextField alloc] initWithFrame:frame];
    port.keyboardType=UIKeyboardTypeNumberPad;
    serverName.keyboardType=UIKeyboardTypeURL;
    textFields=@[serverName,nickName,userName,realName,port];
    NSArray* placeHolders=@[@"Server Name",@"Nickname",@"User Name",@"Real Name",@"Port"];
    [textFields enumerateObjectsUsingBlock:^(UITextField* textField, NSUInteger idx, BOOL *stop) {
        textField.delegate=self;
        textField.placeholder=placeHolders[idx];
        textField.returnKeyType=(idx==4?UIReturnKeyDone:UIReturnKeyNext);
    }];
    UIBarButtonItem* rightItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(start)];
    self.navigationItem.rightBarButtonItem=rightItem;
    
    UIBarButtonItem* leftItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(reset)];
    self.navigationItem.leftBarButtonItem=leftItem;
    
    [self reset];
}

- (void)reset
{
    srand((unsigned)time(NULL));
    serverName.text=@"irc.freenode.net";
    port.text=@"6667";
    NSString* name=[NSString stringWithFormat:@"guest%d",rand()];
    nickName.text=name;
    realName.text=name;
    userName.text=name;
}

- (void)start
{
    BOOL flag=[serverName.text length]!=0&&
        [realName.text length]!=0&&
        [nickName.text length]!=0&&
        [userName.text length]!=0&&
        [port.text length]!=0;
    if (flag) {
        MainViewController* mainViewController=[[MainViewController alloc] init];
        mainViewController.serverName=serverName.text;
        mainViewController.realName=realName.text;
        mainViewController.nickName=nickName.text;
        mainViewController.userName=userName.text;
        mainViewController.port=[port.text integerValue];
        UINavigationController* nav=[[UINavigationController alloc] initWithRootViewController:mainViewController];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Plz fill all fields right" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"StartViewControllerCell";
    NSString* CellIdentifier=[NSString stringWithFormat:@"%@%ld%ld",identifier,(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle=indexPath.section==1?UITableViewCellSelectionStyleDefault:UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:textFields[indexPath.row]];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(10, 2, 90, 40)];
        label.text=[[textFields[indexPath.row] placeholder] stringByAppendingString:@":"];
        label.font=[UIFont systemFontOfSize:13];
        [cell.contentView addSubview:label];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textFields lastObject]!=textField) {
        NSUInteger index=1+[textFields indexOfObject:textField];
        [textFields[index] becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        [self start];
    }
    return YES;
}
@end
