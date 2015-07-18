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
|                         Copyright (c) 2015 Tong Guo                          |██
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

// Notification Names
NSString* const TWPTweetCellViewShouldDisplayDetailOfTweet = @"TweetCellView.Notif.ShouldDisplayDetailOfTweet";

// User Info Keys
NSString* const TWPTweetCellViewTweetUserInfoKey = @"TweetCellView.UserInfoKey.Tweet";

// Private Interfaces
@interface TWPTweetCellView ()

@property ( assign, readwrite, setter = setShowingTweetOperationsPanel: ) BOOL isShowingTweetOperationsPanel;

- ( void ) _postNotifForShowingUserProfile;
- ( BOOL ) _isShowingRetweetOperationsPopover;

@end // Private Interfaces

// TWPTweetCellView class
@implementation TWPTweetCellView

@synthesize authorAvatarWell;
@synthesize userNameLabel;
@synthesize dateIndicatorView;
@synthesize tweetTextView;

@dynamic tweet;
@dynamic author;

@dynamic isShowingTweetOperationsPanel;

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

- ( void ) awakeFromNib
    {
    // The self->_trackingArea will be created with `NSTrackingInVisibleRect` option,
    // in which case the Application Kit handles the re-computation of self->_trackingArea
    self->_trackingAreaOptions = NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp
                                    | NSTrackingInVisibleRect | NSTrackingAssumeInside | NSTrackingMouseMoved;
    self->_trackingArea =
        [ [ NSTrackingArea alloc ] initWithRect: self.bounds options: self->_trackingAreaOptions owner: self userInfo: nil ];

    [ self addTrackingArea: self->_trackingArea ];
    }

#pragma mark Dynamic Accessors
- ( void ) setTweet: ( OTCTweet* )_Tweet
    {
    self->_tweet = _Tweet;

    [ [ self authorAvatarWell ] setTwitterUser: self->_tweet.author ];
    [ [ self userNameLabel ] setTwitterUser: self->_tweet.author ];
    [ [ self tweetTextView ] setTweet: self->_tweet ];
    [ [ self dateIndicatorView ] setTweet: self->_tweet ];
    [ [ self tweetOperationsPanelView ] setTweet: self->_tweet ];

    if ( _Tweet.media )
        {
        if ( self->_tweetMediaWell )
            self->_tweetMediaWell = [ TWPTweetMediaWell tweetMediaWellWithTweet: _Tweet ];
        else
            self->_tweetMediaWell.tweet = _Tweet;
        }

    self.isShowingTweetOperationsPanel = NO;
    }

- ( OTCTweet* ) tweet
    {
    return self->_tweet;
    }

- ( OTCTwitterUser* ) author
    {
    return self.tweet.author;
    }

- ( CGFloat ) dynamicHeightAccordingToTweetTextBlockHeight: ( CGFloat )_TweetTextBlockHeight
    {
    CGFloat height0 = self.userNameLabelTop_equal_cellViewTop_constraint.constant;
    CGFloat height1 = self.tweetTextViewTop_equal_userNameLabelBottom_constraint.constant;
    CGFloat height2 = self.dateIndicatorTop_equal_tweetTextViewBottom_constraint.constant;
    CGFloat height3 = self.tweetOperationsPanelViewTop_equal_dateIndicatorBottom_constraint.constant;
    CGFloat height4 = self.cellViewBottom_equal_tweetOperationsPanelView_constraint.constant;

    CGFloat tweetTextViewHeight = ( _TweetTextBlockHeight > [ TWPTweetTextView defaultSize ].height ) ? _TweetTextBlockHeight : [ TWPTweetTextView defaultSize ].height;
    CGFloat userNameLabelHeight = NSHeight( self.userNameLabel.frame );
    CGFloat dateIndicatorHeight = NSHeight( self.dateIndicatorView.frame );
    CGFloat tweetOperationsPanelViewHeight = NSHeight( self.tweetOperationsPanelView.frame );

    return height0 + height1 + height2 + height3 + height4
                + tweetTextViewHeight + userNameLabelHeight + dateIndicatorHeight + tweetOperationsPanelViewHeight;
    }

- ( void ) setShowingTweetOperationsPanel: ( BOOL )_IsShowingExpandButton
    {
    self->_isShowingTweetOperationsPanel = _IsShowingExpandButton;
    [ self setNeedsUpdateConstraints: YES ];
    }

- ( BOOL ) isShowingExpandButton
    {
    return self->_isShowingTweetOperationsPanel;
    }

#pragma mark Handling Constraints-Based Auto Layout
//- ( void ) updateConstraints
//    {
//    [ super updateConstraints ];
//
//    TWPTweetOperationsPanelView* operationsPanel = [ [ TWPSharedUIElements sharedElements ] tweetOperationsPanelView ];
//
//    if ( self->_isShowingTweetOperationsPanel )
//        {
//        if ( operationsPanel.superview != self )
//            {
//            [ operationsPanel setTweet: self->_tweet ];
//            [ self addSubview: operationsPanel ];
//
//            NSDictionary* viewsDict = NSDictionaryOfVariableBindings( operationsPanel );
//            if ( !self->_expandButtonHorizontalConstraints )
//                {
//                self->_expandButtonHorizontalConstraints =
//                    [ NSLayoutConstraint constraintsWithVisualFormat: @"H:|-(>=leadingSpace)-[operationsPanel(==operationsPanelWidth)]-(==trailingSpace)-|"
//                                                             options: 0
//                                                             metrics: @{ @"leadingSpace" : @( 397.f - NSWidth( operationsPanel.frame ) - 20.f )
//                                                                       , @"operationsPanelWidth" : @( NSWidth( operationsPanel.frame ) )
//                                                                       , @"trailingSpace" : @( 20.f )
//                                                                       }
//                                                               views: viewsDict ];
//
//                [ self addConstraints: self->_expandButtonHorizontalConstraints ];
//                }
//
//            if ( !self->_expandButtonVerticalConstraints )
//                {
//                self->_expandButtonVerticalConstraints =
//                    [ NSLayoutConstraint constraintsWithVisualFormat: @"V:|-(==topSpace)-[operationsPanel(==operationsPanelHeight)]-(>=bottomSpace)-|"
//                                                             options: 0
//                                                             metrics: @{ @"operationsPanelHeight" : @( NSHeight( operationsPanel.frame ) )
//                                                                       , @"topSpace" : @( 15.f )
//                                                                       , @"bottomSpace" : @( 62.f )
//                                                                       }
//                                                               views: viewsDict ];
//
//                [ self addConstraints: self->_expandButtonVerticalConstraints ];
//                }
//
//            for ( NSLayoutConstraint* _Constraint in self->_expandButtonHorizontalConstraints )
//                _Constraint.active = YES;
//
//            for ( NSLayoutConstraint* _Constraint in self->_expandButtonVerticalConstraints )
//                _Constraint.active = YES;
//            }
//        }
//    else
//        {
//        if ( operationsPanel.superview == self )
//            {
//            for ( NSLayoutConstraint* _Constraint in self->_expandButtonHorizontalConstraints )
//                _Constraint.active = NO;
//
//            for ( NSLayoutConstraint* _Constraint in self->_expandButtonVerticalConstraints )
//                _Constraint.active = NO;
//
//            [ operationsPanel setTweet: nil ];
//            [ operationsPanel removeFromSuperview ];
//            }
//        }
//    }

#pragma mark Handling Events
- ( void ) mouseEntered: ( NSEvent* )_Event
    {
    [ super mouseEntered: _Event ];

    if ( ![ self _isShowingRetweetOperationsPopover ] )
        self.isShowingTweetOperationsPanel = YES;
    }

- ( void ) mouseExited: ( NSEvent* )_Event
    {
    [ super mouseExited: _Event ];

    if ( ![ self _isShowingRetweetOperationsPopover ] )
        self.isShowingTweetOperationsPanel = NO;
    }

- ( void ) scrollWheel: ( NSEvent* )_Event
    {
    if ( ![ self _isShowingRetweetOperationsPopover ] )
        {
        [ super scrollWheel: _Event ];
        self.isShowingTweetOperationsPanel = NO;
        }
    }

- ( void ) mouseMoved: ( nonnull NSEvent* )_TheEvent
    {
    [ super mouseMoved: _TheEvent ];

    if ( ![ self _isShowingRetweetOperationsPopover ] )
        self.isShowingTweetOperationsPanel = YES;
    }

#pragma mark IBAction
- ( IBAction ) userNameLabelClickedAction: ( id )_Sender
    {
    [ self _postNotifForShowingUserProfile ];
    }

- ( IBAction ) userAvatarClickedAction: ( id )_Sender
    {
    [ self _postNotifForShowingUserProfile ];
    }

#pragma mark Private Interfaces
- ( void ) _postNotifForShowingUserProfile
    {
    [ [ NSNotificationCenter defaultCenter ] postNotificationName: TWPTwipokerShouldShowUserProfile
                                                           object: self
                                                         userInfo: @{ kTwitterUser : self.author } ];
    }

- ( BOOL ) _isShowingRetweetOperationsPopover
    {
    TWPTweetOperationsPanelView* operationsPanel = [ [ TWPSharedUIElements sharedElements ] tweetOperationsPanelView ];
    return [ operationsPanel isShowingRetweetOperationsPopover ];
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