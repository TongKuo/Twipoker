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

#import "TWPTimelineViewController.h"
#import "TWPTweetCellView.h"
#import "TWPTweetOperationsNotificationNames.h"
#import "TWPTextView.h"

// Private Interfaces
@interface TWPTimelineViewController ()
- ( CGFloat ) _calculateTweetTextBlockHeight: ( OTCTweet* )_Tweet width: ( CGFloat )_Width;
@end // Private Interfaces

// TWPTimelineViewController class
@implementation TWPTimelineViewController

@synthesize isLoadingOlderTweets = _isLoadingOlderTweets;
@synthesize numberOfTweetsWillBeLoadedOnce = _numberOfTweetsWillBeLoadedOnce;

- ( instancetype ) initWithNibName: ( NSString* )_NibNameOrNil
                            bundle: ( NSBundle* )_NibBundleOrNil
    {
    if ( self = [ super initWithNibName: _NibNameOrNil bundle: _NibBundleOrNil ] )
        {
        self->_isLoadingOlderTweets = NO;
        self->_numberOfTweetsWillBeLoadedOnce = 20;

        SEL delegateSel = @selector( tweetOperationShouldBeUnretweeted: );
        if ( [ self respondsToSelector: delegateSel ] )
            [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                        selector: delegateSel
                                                            name: TWPTweetOperationShouldBeUnretweeted
                                                          object: nil ];
        }

    return self;
    }

#pragma mark Conforms to <TWPTimelineTableViewDelegate>
- ( NSView* ) tableView: ( NSTableView* )_TableView
     viewForTableColumn: ( NSTableColumn* )_TableColumn
                    row: ( NSInteger )_Row
    {
    TWPTweetCellView* tweetCellView =
        ( TWPTweetCellView* )[ _TableView makeViewWithIdentifier: _TableColumn.identifier owner: self ];

    OTCTweet* tweet = ( OTCTweet* )( self->_data[ _Row ] );
    tweetCellView.tweet = tweet;

    return tweetCellView;
    }

- ( CGFloat ) tableView: ( nonnull NSTableView* )_TableView
            heightOfRow: ( NSInteger )_Row
    {
    TWPTweetCellView* tweetCellView = ( TWPTweetCellView* )[ self tableView: _TableView viewForTableColumn: _TableView.tableColumns.firstObject row: _Row ];

    CGFloat currentColumnWidth = _TableView.tableColumns.firstObject.width;
    OTCTweet* tweet = self->_data[ _Row ];
    CGFloat height = [ tweetCellView dynamicHeightAccordingToTweetTextBlockHeight: [ self _calculateTweetTextBlockHeight: tweet width: currentColumnWidth - 105 - 20 ] ];
    return height;
    }

- ( void ) tableViewColumnDidResize: ( nonnull NSNotification* )_Notif
    {
    NSMutableIndexSet* indexesChanged = [ NSMutableIndexSet indexSet ];

    CGFloat columnNewWidth = [ _Notif.userInfo[ @"NSTableColumn" ] width ];
    CGFloat columnOldWidth = [ _Notif.userInfo[ @"NSOldWidth" ] doubleValue ];

    for ( int _Index = 0; _Index < self->_data.count; _Index++ )
        {
        CGFloat textBlockNewHeight = [ self _calculateTweetTextBlockHeight: self->_data[ _Index ] width: columnNewWidth - 105 - 20 ];
        CGFloat textBlockOldHeight = [ self _calculateTweetTextBlockHeight: self->_data[ _Index ] width: columnOldWidth - 105 - 20 ];

        if ( textBlockNewHeight != textBlockOldHeight )
            [ indexesChanged addIndex: _Index ];
        }

    if ( indexesChanged.count > 0 )
        [ ( ( NSTableColumn* )_Notif.userInfo[ @"NSTableColumn" ] ).tableView noteHeightOfRowsWithIndexesChanged: indexesChanged ];
    }

#pragma mark Private Interfaces
- ( CGFloat ) _calculateTweetTextBlockHeight: ( OTCTweet* )_Tweet
                                       width: ( CGFloat )_Width
    {
    NSFont* font = [ [ NSFontManager sharedFontManager ] convertWeight: .5f ofFont: [ NSFont fontWithName: @"Lato" size: 14.f ] ];
    NSMutableParagraphStyle* paragraphStyle = [ [ NSParagraphStyle defaultParagraphStyle ] mutableCopy ];
    [ paragraphStyle setLineSpacing: 3.5f ];

    NSTextStorage* textStorage =
        [ [ NSTextStorage alloc ] initWithString: _Tweet.tweetText
                                      attributes: @{ NSFontAttributeName : font
                                                   , NSParagraphStyleAttributeName : paragraphStyle
                                                   } ];

    NSTextContainer* textContainer = [ [ NSTextContainer alloc ] initWithContainerSize: NSMakeSize( _Width, FLT_MAX ) ];
    NSLayoutManager* layoutManager = [ [ NSLayoutManager alloc ] init ];

    [ layoutManager addTextContainer: textContainer ];
    [ textStorage addLayoutManager: layoutManager ];

    ( void )[ layoutManager glyphRangeForTextContainer: textContainer ];
    CGFloat height = NSHeight( [ layoutManager usedRectForTextContainer: textContainer ] );

    return height;
    }

@end // TWPTimelineViewController class

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