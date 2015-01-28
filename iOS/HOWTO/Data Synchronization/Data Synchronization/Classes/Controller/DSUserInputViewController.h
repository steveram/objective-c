#import <UIKit/UIKit.h>

/**
 @brief Extension of the native view controller behaviour and allow to adjust interface to be
        shown in compressed space (because of keyboard).
 
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface DSUserInputViewController : UIViewController


#pragma mark - Properties

/**
 @brief Reference on content holding scroll view. Controller will modify it's content offset to
        show required portion of interface (in case if content will be overlayed by keyboard).
 */
@property (nonatomic, weak) IBOutlet UIScrollView *contentHolder;

/**
 @brief Block which is called by subclasses to calculate offset which should be applied to
        content holding scroll view.
 */
@property (nonatomic, copy)CGRect (^scrollOffsetChangeBlock)(void);


#pragma mark - Instance methods

/**
 @brief Allow to terminate current user input and close input interface.
 */
- (void)completeUserInput;

#pragma mark -


@end
