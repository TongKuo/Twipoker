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

#import "TWPCurrentUserAvatarWellController.h"

// Private Interfaces
@interface TWPCurrentUserAvatarWellController ()
- ( TWPUserAvatarWell* ) _userAvatarWell;
@end // Private Interfaces

// TWPCurrentUserAvatarWellController class
@implementation TWPCurrentUserAvatarWellController

@dynamic twitterUser;

#pragma mark Initializations
- ( void ) awakeFromNib
    {
    // TODO:
    }

#pragma mark Dynamic Accessors
- ( void ) setTwitterUser: ( OTCTwitterUser* )_TwitterUser
    {
    if ( !self->_currentLoginUserOperationsPopover )
        self->_currentLoginUserOperationsPopover = [ TWPCurrentLoginUserOperationsPopover popoverWithTwitterUser: nil delegate: self ];

    [ self->_currentLoginUserOperationsPopover setTwitterUser: _TwitterUser ];
    [ [ self _userAvatarWell ] setTwitterUser: _TwitterUser ];
    }

- ( OTCTwitterUser* ) twitterUser
    {
    return [ [ self _userAvatarWell ] twitterUser ];
    }

#pragma mark IBActions
- ( IBAction ) currentLoginUserAvatarClickedAction: ( id )_Sender
    {
    [ self->_currentLoginUserOperationsPopover showRelativeToRect: [ self _userAvatarWell ].bounds
                                                           ofView: [ self _userAvatarWell ]
                                                    preferredEdge: NSMaxXEdge ];
    }

#pragma mark Private Interfaces
- ( TWPUserAvatarWell* ) _userAvatarWell
    {
    return ( TWPUserAvatarWell* )( [ self view ] );
    }

@end // TWPCurrentUserAvatarWellController class

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