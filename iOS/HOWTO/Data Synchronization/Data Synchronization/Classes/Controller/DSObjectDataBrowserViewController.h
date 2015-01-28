#import <UIKit/UIKit.h>
#import "DSDataModificationDelegate.h"


#pragma mark Class forward

@class PNObject;


#pragma mark - Public interface declaration

@interface DSObjectDataBrowserViewController : UITableViewController


#pragma mark - Properties
/**
 @brief Reference on delegate which performs all modification actions and work with \b PubNub
        service.
 */
@property (nonatomic, weak) id <DSDataModificationDelegate> modificationDelegate;

/**
 @brief Passed after successfull remote object synchronization start and allow to get access to
        data stored in \b PubNub cloud locally.
 */
@property (nonatomic, strong) PNObject *object;

/**
 @brief Stores reference on current data location key-path (which should be presented in current)
        object data browser controller.
 */
@property (nonatomic, copy) NSString *dataKeyPath;

#pragma mark -


@end
