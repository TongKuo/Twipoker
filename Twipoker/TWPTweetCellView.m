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

#import "TWPTweetCellView.h"
#import "TWPTweetTextView.h"
#import "TWPUserAvatarWell.h"
#import "TWPTimelineUserNameButton.h"
#import "TWPTweetOperationsPanelView.h"
#import "TWPDateIndicatorView.h"
#import "TWPSharedUIElements.h"
#import "TWPTweetMediaWell.h"

#import "TWPTweetClearCellRepController.h"

// Notification Names
NSString* const TWPTweetCellViewShouldDisplayDetailOfTweet = @"TweetCellView.Notif.ShouldDisplayDetailOfTweet";

// User Info Keys
NSString* const TWPTweetCellViewTweetUserInfoKey = @"TweetCellView.UserInfoKey.Tweet";

// Private Interfaces
@interface TWPTweetCellView ()

- ( TWPTweetCellRepController* ) _currentCellRepController;
- ( void ) _updateCellRep;

@end // Private Interfaces

// TWPTweetCellView class
@implementation TWPTweetCellView

@dynamic tweet;
@dynamic author;

@dynamic currentTweetCellRepController;

#pragma mark Initialization
+ ( instancetype ) tweetCellViewWithTweet: ( OTCTweet* )_Tweet
    {
    return [ [ [ self class ] alloc ] initWithTweet: _Tweet ];
    }

- ( instancetype ) initWithTweet: ( OTCTweet* )_Tweet
    {
    if ( self = [ super init ] )
        [ self setTweet: _Tweet ];

    return self;
    }

#pragma mrak Time
- ( void ) updateTime
    {
    [ self.currentTweetCellRepController.rep updateTime ];
    }

#pragma mark Dynamic Accessors
- ( void ) setTweet: ( OTCTweet* )_Tweet
    {
    self->_tweet = _Tweet;

    switch ( self->_tweet.type )
        {
        // TODO: Waiting for other styles
        case OTCTweetTypeNormalTweet:
        case OTCTweetTypeRetweet:
        case OTCTweetTypeReply:
        case OTCTweetTypeDirectMessage:
        case OTCTweetTypeQuotedTweet:
            {
            self->_style = TWPTweetCellViewStyleClear;
            }; break;

        default:;
        }

    [ [ self _currentCellRepController ] setTweet: self->_tweet ];
    [ self _updateCellRep ];
    }

- ( OTCTweet* ) tweet
    {
    return self->_tweet;
    }

- ( OTCTwitterUser* ) author
    {
    return self.tweet.author;
    }

- ( TWPTweetCellRepController* ) currentTweetCellRepController
    {
    return [ self _currentCellRepController ];
    }

- ( CGFloat ) dynamicHeightAccordingToTweetTextBlockHeight: ( CGFloat )_TweetTextBlockHeight
    {
    return [ self.currentTweetCellRepController.rep heightWithTweetTextBlockHeight: _TweetTextBlockHeight ];
    }

#pragma mark Private Interfaces
- ( TWPTweetCellRepController* ) _currentCellRepController
    {
    TWPTweetCellRepController* controller = nil;

    switch ( self->_style )
        {
        case TWPTweetCellViewStyleClear:
            {
            // Lazy evaluation
            if ( !self->_clearCellRepController )
                self->_clearCellRepController = [ TWPTweetClearCellRepController repControllerWithTweet: self->_tweet ];

            controller = self->_clearCellRepController;
            } break;

        default:; // TODO: Waiting for other styles
        }

    return controller;
    }

- ( void ) _updateCellRep
    {
    NSView* cellView = self;
    NSView* cellRep = [ self _currentCellRepController ].rep;

    if ( cellRep.superview != self )
        [ self addSubview: cellRep ];

    NSDictionary* viewsDict = NSDictionaryOfVariableBindings( cellView, cellRep );

    NSArray* horizontalConstraints = [ NSLayoutConstraint constraintsWithVisualFormat: @"H:|[cellRep(==cellView)]|" options: 0 metrics: nil views: viewsDict ];
    NSArray* verticalConstraints = [ NSLayoutConstraint constraintsWithVisualFormat: @"V:|[cellRep(==cellView)]|" options: 0 metrics: nil views: viewsDict ];
    [ self addConstraints: horizontalConstraints ];
    [ self addConstraints: verticalConstraints ];
    }

@end // TWPTweetCellView class

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