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

@import Cocoa;

#import "TWPRetweetOperationsPopover.h"

@class TWPReplyButton;
@class TWPRetweetSwitcher;
@class TWPFavSwitcher;
@class TWPTweetBoxController;

@class TWPRetweetOperationsPopover;

@interface TWPTweetOperationsPanelView : NSView <TWPRetweetOperationsPopoverDelegate>
    {
@private
    OTCTweet __strong* _tweet;
    TWPRetweetOperationsPopover __strong* _popover;
    TWPTweetBoxController __strong* _tweetBoxController;

    BOOL _isShowingRetweetOperationsPopover;
    }

@property ( strong, readwrite ) OTCTweet* tweet;

@property ( weak ) IBOutlet TWPReplyButton* replyButton;
@property ( weak ) IBOutlet TWPRetweetSwitcher* retweetSwitcher;
@property ( weak ) IBOutlet TWPFavSwitcher* favSwitcher;

@property ( assign, readonly ) BOOL isShowingRetweetOperationsPopover;

#pragma mark Initializations
+ ( instancetype ) panelWithTweet: ( OTCTweet* )_Tweet;
- ( instancetype ) initWithTweet: ( OTCTweet* )_Tweet;

#pragma mark IBActions
- ( IBAction ) showRetweetPopoverAction: ( id )_Sender;
- ( IBAction ) favOrUnfavAction: ( id )_Sender;
- ( IBAction ) replyCurrentTweetAction: ( id )_Sender;

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