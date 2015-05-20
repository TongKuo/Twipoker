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

#import "TWPBrain.h"
#import "TWPLoginUsersManager.h"

#import "_TWPMonitoringUserID.h"

// TWPBrain class
@implementation TWPBrain

#pragma mark Initializations
+ ( instancetype ) wiseBrain
    {
    return [ [ [ self class ] alloc ] init ];
    }

TWPBrain static __strong* sWiseBrain;
- ( instancetype ) init
    {
    if ( !sWiseBrain )
        {
        if ( self = [ super init ] )
            {
            // Home Timeline
            // Single-user stream, containing roughly all of the data corresponding with
            // the current authenticating user’s view of Twitter.
            self->_authingUserTimelineStream = [ [ TWPLoginUsersManager sharedManager ] currentLoginUser ].twitterAPI;
            self->_authingUserTimelineStream.delegate = self;

            [ self->_authingUserTimelineStream fetchUserStreamIncludeMessagesFromFollowedAccounts: @NO
                                                                                   includeReplies: @NO
                                                                                  keywordsToTrack: nil
                                                                            locationBoundingBoxes: nil ];
            // Global Timeline
            // Streams of the public data flowing through Twitter.
            self->_publicTimelineFilterStream = [ [ TWPLoginUsersManager sharedManager ] currentLoginUser ].twitterAPI;
            self->_publicTimelineFilterStream.delegate = self;
            [ self->_publicTimelineFilterStream fetchStatusesFilterKeyword: @"@NSTongG" users: nil locationBoundingBoxes: nil ];

            self->_friendsList = [ NSMutableSet set ];
            self->_monitoringUserIDs = [ NSMutableSet set ];

            sWiseBrain = self;
            }
        }

    return sWiseBrain;
    }

#pragma mark Registration of Limbs
- ( void ) registerLimb: ( NSObject <TWPLimb>* )_NewLimb
             forUserIDs: ( NSArray* )_UserIDs
            brainSignal: ( TWPBrainSignalTypeMask )_BrainSignals
    {
    NSParameterAssert( ( _NewLimb ) );

    if ( _UserIDs )
        {
        for ( NSString* _UserID in _UserIDs )
            {
            _TWPMonitoringUserID* monitoringUserID = [ _TWPMonitoringUserID IDWithUserID: _UserID signalMask: _BrainSignals limb: _NewLimb ];
            [ self->_monitoringUserIDs addObject: monitoringUserID ];
            }
        }
    else
        [ self->_monitoringUserIDs addObject: [ _TWPMonitoringUserID IDWithUserID: nil signalMask: _BrainSignals limb: _NewLimb ] ];
    }

- ( void ) removeLimb: ( NSObject <TWPLimb>* )_Limb
           forUserIDs: ( NSArray* )_UserIDs
          brainSignal: ( TWPBrainSignalTypeMask )_BrainSignals
    {
    if ( _UserIDs )
        {
        for ( NSString* _UserID in _UserIDs )
            {
            _TWPMonitoringUserID* monitoringUserID = [ _TWPMonitoringUserID IDWithUserID: _UserID signalMask: _BrainSignals limb: _Limb ];
            [ self->_monitoringUserIDs removeObject: monitoringUserID ];
            }
        }
    else
        [ self->_monitoringUserIDs removeObject: [ _TWPMonitoringUserID IDWithUserID: nil signalMask: _BrainSignals limb: _Limb ] ];
    }

#pragma mark Conforms to <OTCSTTwitterStreamingAPIDelegate> protocol
- ( void )      twitterAPI: ( STTwitterAPI* )_TwitterAPI
    didReceiveFriendsLists: ( NSArray* )_Friends
    {
    [ self->_friendsList addObjectsFromArray: _Friends ];
    }

- ( void ) twitterAPI: ( STTwitterAPI* )_TwitterAPI didReceiveTweet: ( OTCTweet* )_ReceivedTweet
    {
    NSString* authorID = _ReceivedTweet.author.IDString;

    for ( _TWPMonitoringUserID* _MntID in self->_monitoringUserIDs )
        {
        if ( [ _MntID.userID isEqualToString: authorID ] /* Specified user */
                || !_MntID.userID /* Current authenticating user */ )
            {
            if ( _MntID.signalMask & TWPBrainSignalTypeNewTweetMask
                    && [ _MntID.limb respondsToSelector: @selector( brain:didReceiveTweet: ) ] )
                [ _MntID.limb brain: self didReceiveTweet: _ReceivedTweet ];
        #if 0
            if ( !NSEqualRanges( [ _ReceivedTweet.tweetText rangeOfString: @"@NSTongG " ], NSMakeRange( NSNotFound, 0 ) )
                    && _MntID.signalMask & TWPBrainSignalTypeMentionedMeMask
                    && [ _MntID.limb respondsToSelector: @selector( brain:didReceiveMention: ) ] )
                [ _MntID.limb brain: self didReceiveMention: _ReceivedTweet ];
        #endif
            }
        }
    }

- ( void )             twitterAPI: ( STTwitterAPI* )_TwitterAPI
    streamingEventHasBeenDetected: ( OTCStreamingEvent* )_DetectedEvent
    {
    OTCTwitterUser* sourceUser = _DetectedEvent.sourceUser;
    OTCTwitterUser* targetUser = _DetectedEvent.targetUser;

    NSString* sourceUserID = sourceUser.IDString;
    NSString* targetUserID = targetUser.IDString;

    SEL friendsListOperation = nil;
    switch ( _DetectedEvent.eventType)
        {
        case OTCStreamingEventTypeFollow: friendsListOperation = @selector( addObject: ); break;
        case OTCStreamingEventTypeUnfollow: friendsListOperation = @selector( removeObject: ); break;

        default:;
        }

    if ( friendsListOperation && targetUserID )
        [ self->_friendsList performSelectorOnMainThread: friendsListOperation withObject: targetUserID waitUntilDone: YES ];

    for ( _TWPMonitoringUserID* _MntID in self->_monitoringUserIDs )
        {
        if ( [ _MntID.userID isEqualToString: sourceUserID ] /* Specified user */
                || !_MntID.userID /* Current authenticating user */ )
            {
            if ( _MntID.signalMask & TWPBrainSignalTypeTimelineEventMask
                    && [ _MntID.limb respondsToSelector: @selector( brain:didReceiveEvent: ) ] )
                [ _MntID.limb brain: self didReceiveEvent: _DetectedEvent ];
            }
        }
    }

- ( void )   twitterAPI: ( STTwitterAPI* )_TwitterAPI
    tweetHasBeenDeleted: ( NSString* )_DeletedTweetID
                 byUser: ( NSString* )_UserID
                     on: ( NSDate* )_DeletionDate
    {
    for ( _TWPMonitoringUserID* _MntID in self->_monitoringUserIDs )
        {
        if ( [ _MntID.userID isEqualToString: _UserID ] /* Specified user */
                || !_MntID.userID /* Current authenticating user */ )
            {
            if ( _MntID.signalMask & TWPBrainSignalTypeTweetDeletionMask
                    && [ _MntID.limb respondsToSelector: @selector( brain:didReceiveTweetDeletion:byUser:on: ) ] )
                [ _MntID.limb brain: self didReceiveTweetDeletion: _DeletedTweetID byUser: _UserID on: _DeletionDate ];
            }
        }
    }

@end // TWPBrain class

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