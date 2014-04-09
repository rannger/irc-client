//
//  NamesViewController.m
//  irc-client
//
//  Created by rannger on 13-10-28.
//  Copyright (c) 2013年 rannger. All rights reserved.
//

#import "NamesViewController.h"
#import "Command.h"
#import "IRCManager.h"
#import "Message.h"
#import "ChatViewController.h"

@interface NamesViewController ()

@end

@implementation NamesViewController
@synthesize manager;
@synthesize channelName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Names";
    namelist=[NSMutableArray array];
    Command* cmd=[Command namesCommandWithChannelName:self.channelName];
    [manager performSelector:@selector(sendCommand:) withObject:cmd afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(names:) name:@"RPL_NAMREPLY" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameListEnd) name:@"RPL_ENDOFNAMES" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)names:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSLog(@"%@",dic);
    NSString* names=dic[kMessageTail];
    NSArray* nl=[names componentsSeparatedByString:@" "];
    [namelist addObjectsFromArray:nl];
    [self.tableView reloadData];
}

- (void)nameListEnd
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [namelist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NamesViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text=namelist[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* userName=namelist[indexPath.row];
    ChatViewController* ctrl=[[ChatViewController alloc] initWithStyle:ChatViewControllerStyleUser];
    ctrl.manager=self.manager;
    ctrl.title=userName;
    ctrl.receiver=userName;
    [self.navigationController pushViewController:ctrl animated:YES];
}
@end
