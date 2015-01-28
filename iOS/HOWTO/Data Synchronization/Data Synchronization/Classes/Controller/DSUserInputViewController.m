#import "DSUserInputViewController.h"


#pragma mark Private interface declaration

@interface DSUserInputViewController ()


#pragma mark - Properties

/**
 @brief Assigned on interface appear and stored for application life time. Used to restore 
        content holding scroll view size.
 */
@property (nonatomic, assign) CGFloat originalHolderHeight;


#pragma mark - Instance methods

#pragma mark - Handler methods

/**
 @brief Handle every time when iOS keyboard will change it's frame (appear / disappear or
 additional actions menu show up/hide).
 
 @param notification Reference on notification which hold all information required to calculate
 current keyboard and how interface should react on it.
 */
- (void)handleKeyboardFrameChange:(NSNotification *)notification;


#pragma mark - Misc methods

/**
 @brief Launch observation on events which is triggered by keyboard on frame change.
 */
- (void)registerForKeyboardNotifications;

/**
 @brief Unsubscribe from observation on events which is triggered by keyboard on frame change.
 */
- (void)unregisterFromKeyboardNotifications;


#pragma mark -


@end


/**
 @author Sergey Mamontov
 @copyright © 2009-2015 PubNub, Inc.
 */
@implementation DSUserInputViewController


#pragma mark - Instance methods

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewWillAppear:animated];
    
    if (self.originalHolderHeight <= 1.0f) {
        
        self.originalHolderHeight = self.contentHolder.frame.size.height;
    }
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self unregisterFromKeyboardNotifications];
    
    // Forward method call to the super class.
    [super viewDidDisappear:animated];
}

- (void)completeUserInput {
    
    [self.view endEditing:YES];
}

#pragma mark - Handler methods

- (void)handleKeyboardFrameChange:(NSNotification *)notification {
    
    CGRect keyboardTargetRect;
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardTargetRect];
    CGRect intersection = CGRectIntersection(self.contentHolder.frame, keyboardTargetRect);
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    if (intersection.size.height > 0.0f) {
        
        CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat targetIntersectionHeight = (intersection.size.height + navigationBarHeight + statusBarHeight);
        
        insets.bottom = targetIntersectionHeight;
    }
    self.contentHolder.contentInset = insets;
    self.contentHolder.scrollIndicatorInsets = insets;
}


#pragma mark - Misc methods

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardFrameChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)unregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
}


#pragma mark -


@end
