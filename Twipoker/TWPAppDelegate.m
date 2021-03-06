/*=============================================================================┐
|             _  _  _       _                                                  |  
|            (_)(_)(_)     | |                            _                    |██
|             _  _  _ _____| | ____ ___  ____  _____    _| |_ ___              |██
|            | || || | ___ | |/ ___) _ \|    \| ___ |  (_   _) _ \             |██
|            | || || | ____| ( (__| |_| | | | | ____|    | || |_| |            |██
|             \_____/|_____)\_)____)___/|_|_|_|_____)     \__)___/             |██
|                                                                              |██
|                 _______    _             _                 _                 |██
|                (_______)  (_)           | |               | |                |██
|                    _ _ _ _ _ ____   ___ | |  _ _____  ____| |                |██
|                   | | | | | |  _ \ / _ \| |_/ ) ___ |/ ___)_|                |██
|                   | | | | | | |_| | |_| |  _ (| ____| |    _                 |██
|                   |_|\___/|_|  __/ \___/|_| \_)_____)_|   |_|                |██
|                             |_|                                              |██
|                                                                              |██
|                         Copyright (c) 2015 Tong Kuo                          |██
|                                                                              |██
|                             ALL RIGHTS RESERVED.                             |██
|                                                                              |██
└==============================================================================┘██
  ████████████████████████████████████████████████████████████████████████████████
  ██████████████████████████████████████████████████████████████████████████████*/

#import "TWPAppDelegate.h"
#import "TWPLoginPanel.h"
#import "TWPLoginPanelController.h"
#import "TWPMainWindowController.h"
#import "TWPLoginUsersManager.h"

@implementation TWPAppDelegate

#pragma mark Initialization & Deallocation
- ( void ) awakeFromNib
    {
    self.loginPanelController = [ TWPLoginPanelController loginPanelController ];
    self.mainWindowController = [ TWPMainWindowController mainWindowController ];
    }

- ( void ) applicationWillFinishLaunching: ( NSNotification* )_Notif
    {
    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( twipokerDidFinishLogin: )
                                                    name: TWPTwipokerDidFinishLoginNotification
                                                  object: nil ];

    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( usersManagerDidFinishRemovingLoginUser: )
                                                    name: TWPLoginUsersManagerDidFinishRemovingLoginUser
                                                  object: nil ];

    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( usersManagerDidFinishRemovingAllLoginUsers: )
                                                    name: TWPLoginUsersManagerDidFinishRemovingAllLoginUsers
                                                  object: nil ];

    if ( [ [ TWPLoginUsersManager sharedManager ] currentLoginUser ] )
        [ self.mainWindowController showWindow: self ];
    else
        // If there is no current user,
        // we have to prompt user for authorization by showing them a beautiful login panel.
        [ self.loginPanelController showWindow: self ];
    }

- ( void ) dealloc
    {
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self name: TWPTwipokerDidFinishLoginNotification object: nil ];
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self name: TWPLoginUsersManagerDidFinishRemovingLoginUser object: nil ];
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self name: TWPLoginUsersManagerDidFinishRemovingAllLoginUsers object: nil ];
    }

#pragma mark Conforms to <TWPUesrManagerDelegate>
// Sent by the default notification center immediately after a successful login
- ( void ) twipokerDidFinishLogin: ( NSNotification* )_Notif
    {
    [ self.loginPanelController close ];
    [ self.mainWindowController showWindow: self ];
    }

- ( void ) usersManagerDidFinishRemovingLoginUser: ( NSNotification* )_Notif
    {
    NSNumber* numberOfRemainingLoginUsers = _Notif.userInfo[ TWPNumberOfRemainingLoginUsersUserInfoKey ];

    if ( numberOfRemainingLoginUsers.integerValue == 0 )
        {
        [ self.mainWindowController close ];
        [ self.loginPanelController showWindow: self ];
        }
    }

- ( void ) usersManagerDidFinishRemovingAllLoginUsers: ( NSNotification* )_Notif
    {
    [ self.mainWindowController close ];
    [ self.loginPanelController showWindow: self ];
    }

@end

/*=============================================================================┐
|                                                                              |
|                                        `-://++/:-`    ..                     |
|                    //.                :+++++++++++///+-                      |
|                    .++/-`            /++++++++++++++/:::`                    |
|                    `+++++/-`        -++++++++++++++++:.                      |
|                     -+++++++//:-.`` -+++++++++++++++/                        |
|                      ``./+++++++++++++++++++++++++++/                        |
|                   `++/++++++++++++++++++++++++++++++-                        |
|                    -++++++++++++++++++++++++++++++++`                        |
|                     `:+++++++++++++++++++++++++++++-                         |
|                      `.:/+++++++++++++++++++++++++-                          |
|                         :++++++++++++++++++++++++-                           |
|                           `.:++++++++++++++++++/.                            |
|                              ..-:++++++++++++/-                              |
|                             `../+++++++++++/.                                |
|                       `.:/+++++++++++++/:-`                                  |
|                          `--://+//::-.`                                      |
|                                                                              |
└=============================================================================*/