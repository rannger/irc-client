//
//  Command.h
//  core
//
//  Created by derek on 13-10-25.
//  Copyright (c) 2013年 ijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Command : NSObject
{
    NSString* commandName;
    NSArray* params;
}
@property (nonatomic,copy) NSString* commandName;
@property (nonatomic,strong) NSArray* params;

- (NSData*)genericData;
@end

/**
 Password message
 
 Commmand: PASS
 Parameters: <password>
 
 The PASS command is used to set a 'connection password'. The
 password can and must be set before any attempt to register the
 connection is made. Currently this requires that clients send a PASS
 command before sending the NICK/USER combination and servers *must*
 send a PASS command before any SERVER command. The password supplied
 must match the one contained in the C/N lines (for servers) or I
 lines (for clients). It is possible to send multiple PASS commands
 before registering but only the last one sent is used for
 verification and it may not be changed once registered.
 Numeric replies:
 
 ERR_NEEDMOREPARAMS
 ERR_ALREADYREGISTRED
*/

@interface Command (PASS)

+ (Command*)passCommandWithPassword:(NSString*)password;

@end

/**
 Nick message
 
 Commmand: NICK
 Parameters: <nickname> [ <hopcount> ]
 
 NICK message is used to give user a nickname or change the previous
 one. The <hopcount> parameter is only used by servers to indicate
 how far away a nick is from its home server. A local connection has
 a hopcount of 0. If supplied by a client, it must be ignored.
 
 If a NICK message arrives at a server which already knows about an
 identical nickname for another client, a nickname collision occurs.
 As a result of a nickname collision, all instances of the nickname
 are removed from the server's database, and a KILL command is issued
 to remove the nickname from all other server's database. If the NICK
 message causing the collision was a nickname change, then the
 original (old) nick must be removed as well.
 
 If the server recieves an identical NICK from a client which is
 directly connected, it may issue an ERR_NICKCOLLISION to the local
 client, drop the NICK command, and not generate any kills.
 Numeric replies:
 
 ERR_NONICKNAMEGIVEN
 ERR_ERRONEUSNICKNAME
 ERR_NICKNAMEINUSE
 ERR_NICKCOLLISION

*/
@interface Command (NICK)

+ (Command*)nickCommandWithNickName:(NSString*)nickName;

@end

/**
 User message
 
 Commmand: USER
 Parameters: <username> <hostname> <servername> <realname>
 
 The USER message is used at the beginning of connection to specify
 the username, hostname, servername and realname of s new user. It is
 also used in communication between servers to indicate new user
 arriving on IRC, since only after both USER and NICK have been
 received from a client does a user become registered.
 
 Between servers USER must to be prefixed with client's NICKname.
 Note that hostname and servername are normally ignored by the IRC
 server when the USER command comes from a directly connected client
 (for security reasons), but they are used in server to server
 communication. This means that a NICK must always be sent to a
 remote server when a new user is being introduced to the rest of the
 network before the accompanying USER is sent.
 
 It must be noted that realname parameter must be the last parameter,
 because it may contain space characters and must be prefixed with a
 colon (':') to make sure this is recognised as such.
 
 Since it is easy for a client to lie about its username by relying
 solely on the USER message, the use of an "Identity Server" is
 recommended. If the host which a user connects from has such a
 server enabled the username is set to that as in the reply from the
 "Identity Server".
 Numeric replies:
 
 ERR_NEEDMOREPARAMS
 ERR_ALREADYREGISTRED
 
*/

@interface Command (USER)

+ (Command*)userCommandWithUserName:(NSString*)userName
                           hostName:(NSString*)hostName
                         serverName:(NSString*)serverName
                           realName:(NSString*)realName;

@end

/**Whois query
 
 Commmand: WHOIS
 Parameters: [<server>] <nickmask>[,<nickmask>[,...]]
 
 This message is used to query information about particular user. The
 server will answer this message with several numeric messages
 indicating different statuses of each user which matches the nickmask
 (if you are entitled to see them). If no wildcard is present in the
 <nickmask>, any information about that nick which you are allowed to
 see is presented. A comma (',') separated list of nicknames may be
 given.
 
 The latter version sends the query to a specific server. It is
 useful if you want to know how long the user in question has been
 idle as only local server (ie. the server the user is directly
 connected to) knows that information, while everything else is
 globally known.
 Numeric replies:
 
 RPL_AWAY
 RPL_WHOISUSER
 RPL_WHOISSERVER
 RPL_WHOISOPERATOR
 RPL_WHOISIDLE
 RPL_ENDOFWHOIS
 RPL_WHOISCHANNELS
 RPL_WHOISCHANNELS
 ERR_NOSUCHNICK
 ERR_NOSUCHSERVER
 ERR_NONICKNAMEGIVEN
*/

@interface Command (Whois)
+ (Command*)whoisCommandWithNickName:(NSString*)nickName;
@end

/**
 Quit
 
 Commmand: QUIT
 Parameters: [<Quit message>]
 
 A client session is ended with a quit message. The server must close
 the connection to a client which sends a QUIT message. If a "Quit
 Message" is given, this will be sent instead of the default message,
 the nickname.
 
 When netsplits (disconnecting of two servers) occur, the quit message is composed of the names of two servers involved, separated by a
 space. The first name is that of the server which is still connected
 and the second name is that of the server that has become
 disconnected.
 
 If, for some other reason, a client connection is closed without the
 client issuing a QUIT command (e.g. client dies and EOF occurs
 on socket), the server is required to fill in the quit message with
 some sort of message reflecting the nature of the event which
 caused it to happen.
 Numeric replies:
 
 None
*/
@interface Command (QUIT)
+ (Command*)quitCommandWithMessage:(NSString*)message;
@end

/**
 Join message
 
 Commmand: JOIN
 Parameters: <channel>{,<channel>} [<key>{,<key>}]
 
 The JOIN command is used by client to start listening a specific
 channel. Whether or not a client is allowed to join a channel is
 checked only by the server the client is connected to; all other
 servers automatically add the user to the channel when it is received
 from other servers. The conditions which affect this are as follows:
 1. the user must be invited if the channel is invite-only;
 2. the user's nick/username/hostname must not match any
 active bans;
 3. the correct key (password) must be given if it is set.
 
 These are discussed in more detail under the MODE command (see
 section 4.2.3 for more details).
 
 Once a user has joined a channel, they receive notice about all
 commands their server receives which affect the channel. This
 includes MODE, KICK, PART, QUIT and of course PRIVMSG/NOTICE. The
 JOIN command needs to be broadcast to all servers so that each server
 knows where to find the users who are on the channel. This allows
 optimal delivery of PRIVMSG/NOTICE messages to the channel.
 
 If a JOIN is successful, the user is then sent the channel's topic
 (using RPL_TOPIC) and the list of users who are on the channel (using
 RPL_NAMREPLY), which must include the user joining.
 Numeric replies:
 
 RPL_TOPIC
 ERR_NOSUCHCHANNEL
 ERR_TOOMANYCHANNELS
 ERR_NEEDMOREPARAMS
 ERR_CHANNELISFULL
 ERR_INVITEONLYCHAN
 ERR_BANNEDFROMCHAN
 ERR_BADCHANNELKEY
 ERR_BADCHANMASK
*/

@interface Command (JOIN)
+ (Command*)joinCommandWithChannel:(NSString*)channel;
@end

/**
 Operwall message
 
 Command: WALLOPS
 Parameters: <Text to be sent>
 
 The WALLOPS command is used to send a message to all currently
 connected users who have set the 'w' user mode for themselves.  (See
 Section 3.1.5 "User modes").
 After implementing WALLOPS as a user command it was found that it was
 often and commonly abused as a means of sending a message to a lot of
 people.  Due to this, it is RECOMMENDED that the implementation of
 WALLOPS allows and recognizes only servers as the originators of
 WALLOPS.
 
 Numeric Replies:
 
 ERR_NEEDMOREPARAMS
*/
@interface Command (PRIVMSG)
+ (Command*)sendCommandWithMessage:(NSString*)message receive:(NSString*)receive;
@end
/**
 List message
 
 Commmand: LIST
 Parameters: [<channel>{,<channel>} [<server>]]
 
 The list message is used to list channels and their topics. If the
 <channel> parameter is used, only the status of that channel
 is displayed. Private channels are listed (without their
 topics) as channel "Prv" unless the client generating the query is
 actually on that channel. Likewise, secret channels are not listed at all unless the client is a member of the channel in question.
 Numeric replies:
 
 RPL_LISTSTART
 RPL_LIST
 RPL_LISTEND
 ERR_NOSUCHSERVER
 */
@interface Command (LIST)
+ (Command*)listCommand;
+ (Command*)listCommandWithChannelNames:(NSString*)channelNameList;
@end

/**
 Pong message
 
 Commmand:  []
 Parameters: PONG message is a reply to ping message. If parameter <daemon2> is
 given this message must be forwarded to given daemon. The <daemon>
 parameter is the name of the daemon who has responded to PING message
 and generated this message.
 
 Numeric replies:
 
 ERR_NOSUCHSERVER
 ERR_NOORIGIN
 */
@interface Command (PONG)
+ (Command*)pongCommandWithServerHost:(NSString*)serverHost;
@end

/**
 Ping message
 
 Commmand: PING
 Parameters: <server1> [<server2>]
 
 The PING message is used to test the presence of an active client at
 the other end of the connection. A PING message is sent at regular
 intervals if no other activity detected coming from a connection. If
 a connection fails to respond to a PING command within a set amount
 of time, that connection is closed.
 
 Any client which receives a PING message must respond to <server1>
 (server which sent the PING message out) as quickly as possible with
 an appropriate PONG message to indicate it is still there and alive.
 Servers should not respond to PING commands but rely on PINGs from
 the other end of the connection to indicate the connection is alive.
 If the <server2> parameter is specified, the PING message gets
 forwarded there.
 Numeric replies:
 
 ERR_NOSUCHSERVER
 ERR_NOORIGIN
 */
@interface Command (PING)
+ (Command*)pingCommandWithServerHost:(NSString*)serverHost;
+ (Command*)pingCommandWithUserName:(NSString*)userName;
+ (Command*)pingCommandWithHosts:(NSArray*)hosts;
@end

/**
 Names message
 
 Commmand: NAMES
 Parameters: [<channel>{,<channel>}]
 
 By using the NAMES command, a user can list all nicknames that are
 visible to them on any channel that they can see. Channel names
 which they can see are those which aren't private (+p) or secret (+s)
 or those which they are actually on. The <channel> parameter
 specifies which channel(s) to return information about if valid.
 There is no error reply for bad channel names.
 
 If no <channel> parameter is given, a list of all channels and their
 occupants is returned. At the end of this list, a list of users who
 are visible but either not on any channel or not on a visible channel
 are listed as being on `channel' "*".
 Numeric replies:
 
 RPL_NAMREPLY
 RPL_ENDOFNAMES
 */
@interface Command (NAMES)
+ (Command*)namesCommandWithChannelName:(NSString*)channelName;
@end

/**
 Part message
 
 Commmand: PART
 Parameters: <channel>{,<channel>}
 
 The PART message causes the client sending the message to be removed
 from the list of active users for all given channels listed in the
 parameter string.
 Numeric replies:
 
 ERR_NOSUCHCHANNEL
 ERR_NOTONCHANNEL
 ERR_NEEDMOREPARAMS
*/
@interface Command (Part)
+ (Command*)partCommandWithChannelName:(NSString*)channelName;
@end

/**
 Notice
 
 Commmand: NOTICE
 Parameters: <nickname> <text>
 
 The NOTICE message is used similarly to PRIVMSG. The difference
 between NOTICE and PRIVMSG is that automatic replies must never be
 sent in response to a NOTICE message. This rule applies to servers
 too - they must not send any error reply back to the client on
 receipt of a notice. The object of this rule is to avoid loops
 between a client automatically sending something in response to
 something it received. This is typically used by automatons (clients
 with either an AI or other interactive program controlling their
 actions) which are always seen to be replying lest they end up in a
 loop with another automaton.
 
 User based queries
 
 User queries are a group of commands which are primarily concerned
 with finding details on a particular user or group users. When using
 wildcards with any of these commands, if they match, they will only
 return information on users who are 'visible' to you. The visibility
 of a user is determined as a combination of the user's mode and the
 common set of channels you are both on.
 
 See PRIVMSG for more details on replies and examples.
*/
@interface Command (Notice)
+ (Command*)noticeCommandWithNickName:(NSString*)nickname message:(NSString*)message;
@end

