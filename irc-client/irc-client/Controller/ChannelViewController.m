//
//  ChannelViewController.m
//  irc client
//
//  Created by derek on 13-10-25.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import "ChannelViewController.h"
#import "Message.h"
#import "IRCManager.h"
#import "Command.h"
#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ChannelViewController ()

@end

@implementation ChannelViewController
@synthesize channelList;
@synthesize manager;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
         self.channelList=[NSMutableArray arrayWithCapacity:1000];
        searchReultList=[NSMutableArray arrayWithCapacity:1000];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Channel";
    UISearchBar* searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.delegate=self;
    searchDisplayCtrl=[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayCtrl.delegate=self;
    searchDisplayCtrl.searchResultsDataSource=self;
    searchDisplayCtrl.searchResultsDelegate=self;
    self.tableView.tableHeaderView=searchBar;
    searchBar.placeholder=@"example:#ubuntu";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listItem:) name:@"RPL_LIST" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listEnd) name:@"RPL_LISTEND" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinedChannel:) name:@"JOIN" object:nil];
    [channelList removeAllObjects];
    [channelList addObjectsFromArray:manager.joinedChannelList];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)joinedChannel:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSString* userName=[dic[kMessagePrefix] componentsSeparatedByString:@"!"][0];
    if ([manager.nickName isEqualToString:userName]) {
        ChatViewController* ctrl=[[ChatViewController alloc] init];
        ctrl.manager=self.manager;
        NSArray* array=[dic[kMessageArges] componentsSeparatedByString:@" "];
        if ([array count]<=1)
            ctrl.title=[array lastObject];
        else
            ctrl.title=array[1];
        NSArray* cList=nil;
        if ([searchDisplayCtrl isActive]) {
            cList=searchReultList;
            [searchDisplayCtrl setActive:NO animated:YES];
        }
        else
        {
            cList=channelList;
        }
        for (NSDictionary* dic in cList) {
            if ([dic[@"name"] isEqualToString:ctrl.title]) {
                ctrl.topic=dic[@"topic"];
                break;
            }
        }
        ctrl.receiver=ctrl.title;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
 
}


- (void)getAllChannel
{
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"The whole channel list is very big!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)listItem:(NSNotification*)notification
{
    NSDictionary* dic=[notification userInfo];
    NSString* args=[dic objectForKey:kMessageArges];
    NSArray* arr=[args componentsSeparatedByString:@" "];
    NSLog(@"%@",dic);
    if ([arr count]>=2) {
        if ([self.searchDisplayController isActive]) {
            [searchReultList addObject:@{@"name": arr[1],@"topic":[dic objectForKey:kMessageTail]}];
        }
        else
        {
            [self.channelList addObject:@{@"name": arr[1],@"topic":[dic objectForKey:kMessageTail]}];
        }
    }
    if (![self.searchDisplayController isActive]) {
        [self.tableView reloadData];
     }
    else
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }

}

- (void)listEnd
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
    if (tableView==self.tableView) {
        return [channelList count];
    }
    return [searchReultList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelViewControllerCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (tableView==self.tableView) {
        cell.textLabel.text=channelList[indexPath.row][@"name"];
        cell.detailTextLabel.text=channelList[indexPath.row][@"topic"];
    }
    else
    {
        cell.textLabel.text=searchReultList[indexPath.row][@"name"];
        cell.detailTextLabel.text=searchReultList[indexPath.row][@"topic"];

    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [manager joinChannel:@"#19880702"];
//    return;
    if (tableView==self.tableView) {
        if ([manager.joinedChannelList count]!=0) {
            for (NSDictionary* dic in manager.joinedChannelList) {
                if ([dic[@"name"] isEqualToString:self.channelList[indexPath.row][@"name"]]) {
                    ChatViewController* ctrl=[[ChatViewController alloc] init];
                    ctrl.topic=dic[@"topic"];
                    ctrl.manager=self.manager;
                    ctrl.title=dic[@"name"];
                    ctrl.receiver=ctrl.title;
                    [self.navigationController pushViewController:ctrl animated:YES];
                    return;
                }
            }
        }
    }
    else
    {
        if ([manager.joinedChannelList count]!=0) {
            for (NSDictionary* dic in manager.joinedChannelList) {
                if ([dic[@"name"] isEqualToString:searchReultList[indexPath.row][@"name"]]) {
                    ChatViewController* ctrl=[[ChatViewController alloc] init];
                    ctrl.topic=dic[@"topic"];
                    ctrl.manager=self.manager;
                    ctrl.title=dic[@"name"];
                    ctrl.receiver=ctrl.title;
                    [self.navigationController pushViewController:ctrl animated:YES];
                    return;
                }
            }
        }
        [manager joinChannel:searchReultList[indexPath.row][@"name"]];
        [manager.joinedChannelList addObject:searchReultList[indexPath.row]];
        [self.channelList addObject:searchReultList[indexPath.row]];
        [self.tableView reloadData];
        
    }
}
#pragma mark - UISearchBarDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString* string=searchBar.text;
    [searchReultList removeAllObjects];
    Command* cmd=[Command listCommandWithChannelNames:string];
    [manager sendCommand:cmd];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self.searchDisplayController setActive:NO animated:YES];
        [manager getChannelList];

    }
}
@end
