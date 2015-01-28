//
//  ViewController.m
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/27/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "ViewController.h"
#import <PubNub/PNImports.h>
#import "DSDataModificationDelegate.h"


#pragma mark Private interface declaration

@interface ViewController () <DSDataModificationDelegate, UITextFieldDelegate,
                              UIAlertViewDelegate, PNDelegate>


#pragma mark - Properties

/**
 @brief Stores reference on client instance which will be used to communicate with \b PubNub 
        service and provide access to API.
 */
@property (nonatomic, strong) PubNub *client;

/**
 @brief Stores reference on local copy of remote object from \b PubNub cloud.
 */
@property (nonatomic, strong) PNObject *object;

/**
 @brief Stores reference on text field which allow user to input name of remote "database" to 
        which client should connect and synchronize.
 */
@property (nonatomic, weak) IBOutlet UITextField *databaseNameTextField;

/**
 @brief Stores reference on text field which allow user to input desired \b PubNub service host 
        name.
 */
@property (nonatomic, weak) IBOutlet UITextField *originTextField;

/**
 @brief Stores reference on text field which allow user to input subscreibe key from hist account
        on https://admin.pubnub.com.
 */
@property (nonatomic, weak) IBOutlet UITextField *subscribeKeyTextField;

/**
 @brief Stores reference on text field which allow user to input publish key from hist account
        on https://admin.pubnub.com.
 */
@property (nonatomic, weak) IBOutlet UITextField *publishKeyTextField;

/**
 @brief Stores reference on text field which allow user to input secret key from hist account
        on https://admin.pubnub.com.
 */
@property (nonatomic, weak) IBOutlet UITextField *secretKeyTextField;

/**
 @brief Stores reference on text field which allow user to input unique identifier which will be 
        used by service to calculate access rights to database (in case if PAM enabled).
 */
@property (nonatomic, weak) IBOutlet UITextField *authorizationKeyTextField;

/**
 @brief Stores reference on alert view which has been presented to the user to describe issue.
 */
@property (nonatomic, strong) UIAlertView *errorAlertView;

/**
 @brief Stores reference on alert view which has been presented to the user request processing
        process.
 */
@property (nonatomic, strong) UIAlertView *processingAlertView;

/**
 @brief During data input this property stores reference on active text field frame for further
        calculation during interface updated for keyboard.
 */
@property (nonatomic, assign) CGRect activeFieldFrame;


#pragma mark - Instance methods

/**
 @brief Complete user interface initialization process.
 */
- (void)prepareInterface;

/**
 @brief Update view toolbar and display "Connect" button.
 */
- (void)showConnectButton;

/**
 @brief Update view toolbar and show "activity" indicator there for the time while client 
        connects and prepare to show data browser.
 */
- (void)showConnectionProgress;

/**
 @brief Construct and display UIAlertView to present user with information about error.
 
 @param error       Reference on error which should be used for description.
 @param canBeClosed If \c NO is set alert view can't be closed directly (used for intermediate 
                    state when client is waiting for connection restore).
 */
- (void)showErrorAlertViewFor:(PNError *)error closable:(BOOL)canBeClosed;

/**
 @brief Using reference on last alert view which has been shown, close it.
 */
- (void)closeErrorAlertView;

/**
 @brief Display alert view to lock interface and notify user about active operation.
 
 @param operationName Name of the operatino for which this progress has been shown.
 */
- (void)showProgressAlertView:(NSString *)operationName;

/**
 @brief Dismiss progress alert view and clean up.
 */
- (void)closeProgressAlertView;


#pragma mark - Handler methods

/**
 @brief Handle user tap action on "connect" button to initiate connection with remote \b PubNub 
        service.
 
 @param sender Reference on button instance on which user tapped.
 */
- (IBAction)handleConnectButtonTouch:(id)sender;

#pragma mark -


@end


#pragma mark - Public interfce implementation

@implementation ViewController


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    
    [self prepareInterface];
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    self.scrollOffsetChangeBlock = ^CGRect { return weakSelf.activeFieldFrame; };
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewWillAppear:animated];
    
    if (self.client) {
        
        [self.client disconnect];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *objectBrowser = [(UINavigationController *)segue.destinationViewController topViewController];
    [objectBrowser setValue:sender forKey:@"object"];
    [objectBrowser setValue:self forKey:@"modificationDelegate"];
}

- (void)prepareInterface {
    
    [self showConnectButton];
}

- (void)showConnectButton {
    
    UIBarButtonItem *leftFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil action:nil];
    UIBarButtonItem *rightFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil action:nil];
    UIBarButtonItem *connectItem = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(handleConnectButtonTouch:)];
    BOOL shouldAnimate = ([self.toolbarItems count] > 0);
    [self setToolbarItems:@[leftFlexibleItem, connectItem, rightFlexibleItem] animated:shouldAnimate];
}

- (void)showConnectionProgress {
    
    UIBarButtonItem *leftFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil action:nil];
    UIBarButtonItem *rightFlexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil action:nil];
    UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [progress startAnimating];
    UIBarButtonItem *progressItem = [[UIBarButtonItem alloc] initWithCustomView:progress];
    [self setToolbarItems:@[leftFlexibleItem, progressItem, rightFlexibleItem] animated:YES];
}

- (void)showErrorAlertViewFor:(PNError *)error closable:(BOOL)canBeClosed {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                        message:error.localizedFailureReason
                                                       delegate:self
                                              cancelButtonTitle:(canBeClosed ? @"OK" : nil)
                                              otherButtonTitles:nil];

    [self closeProgressAlertView];
    [self closeErrorAlertView];
    
    self.errorAlertView = alertView;
    [self.errorAlertView show];
}

- (void)closeErrorAlertView {
    
    if (self.errorAlertView) {
        
        [self.errorAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void)showProgressAlertView:(NSString *)operationName {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:operationName message:nil
                                                       delegate:self cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    
    [self closeProgressAlertView];
    
    self.processingAlertView = alertView;
    [self.processingAlertView show];
}

- (void)closeProgressAlertView {
    
    if (self.processingAlertView) {
        
        [self.processingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}


#pragma mark - Handler methods

- (IBAction)handleConnectButtonTouch:(id)sender {
    
    [self completeUserInput];
    
    if ([self.databaseNameTextField.text length]) {
        
        [self showConnectionProgress];
        
        if (!self.client) {
            
            NSString *origin = ([self.originTextField.text length] ? self.originTextField.text : nil);
            NSString *subscribeKey = ([self.subscribeKeyTextField.text length] ? self.subscribeKeyTextField.text : nil);
            NSString *publishKey = ([self.publishKeyTextField.text length] ? self.publishKeyTextField.text : nil);
            NSString *secretKey = ([self.secretKeyTextField.text length] ? self.secretKeyTextField.text : nil);
            NSString *authorizationKey = ([self.authorizationKeyTextField.text length] ? self.authorizationKeyTextField.text : nil);
            
            PNConfiguration *configuration = [PNConfiguration configurationForOrigin:origin publishKey:publishKey subscribeKey:subscribeKey
                                                                           secretKey:secretKey authorizationKey:authorizationKey];
            self.client = [PubNub connectingClientWithConfiguration:configuration andDelegate:self];
        }
        else {
            
            [self.client connect];
        }
    }
    else {
        
        [self.databaseNameTextField becomeFirstResponder];
    }
}

#pragma mark - PNDelegate methods

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    [client synchronizeRemoteObject:self.databaseNameTextField.text withDataAtLocations:nil];
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    if (error) {
        
        [self showConnectButton];
        [self showErrorAlertViewFor:error closable:YES];
    }
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin
           withError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:NO];
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    [self showConnectButton];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void) pubnubClient:(PubNub *)client didStartObjectSynchronization:(PNObject *)object
  withDataAtLocations:(NSArray *)locations {
    
    [self closeErrorAlertView];
    [self showConnectButton];
    self.object = object;
    [self performSegueWithIdentifier:@"showObjectBrowser" sender:object];
}

- (void)   pubnubClient:(PubNub *)client
  objectSynchronization:(PNObjectInformation *)objectInformation
  startDidFailWithError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:YES];
}

- (void)  pubnubClient:(PubNub *)client
 objectSynchronization:(PNObjectInformation *)objectInformation
  stopDidFailWithError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:YES];
}

- (void)   pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
  fetchDidFailWithError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:YES];
}

- (void)      pubnubClient:(PubNub *)client remoteObject:(PNObjectInformation *)objectInformation
  dataPushDidFailWithError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:YES];
}

- (void)         pubnubClient:(PubNub *)client
                 remoteObject:(PNObjectInformation *)objectInformation
  dataReplaceDidFailWithError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:YES];
}

- (void)        pubnubClient:(PubNub *)client
                remoteObject:(PNObjectInformation *)objectInformation
  dataRemoveDidFailWithError:(PNError *)error {
    
    [self showErrorAlertViewFor:error closable:YES];
}


#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([alertView isEqual:self.errorAlertView]) {
        
        self.errorAlertView = nil;
    }
    else {
        
        self.processingAlertView = nil;
    }
}


#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.activeFieldFrame = textField.frame;
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    return YES;
}


#pragma mark - DSDataModification delegate methods

- (PNObservationCenter *)observer {
    
    return self.client.observationCenter;
}

- (void)mergeDataAtLocation:(NSString *)targetDataLocation withData:(id)data {
    
    [self showProgressAlertView:@"Merging"];
    [self.client pushData:data toRemoteObject:self.object.identifier atLocation:targetDataLocation
withCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error) {
    
        if (!error) {
            
            [self closeProgressAlertView];
        }
    }];
}

- (void)pushData:(id)data toLocation:(NSString *)targetDataLocation withSortingKey:(NSString *)sortKey {
    
    [self showProgressAlertView:@"Pushing"];
    [self.client pushObjects:data toRemoteObject:self.object.identifier atLocation:targetDataLocation
              withSortingKey:sortKey andCompletionHandlingBlock:^(PNObjectInformation *objectInformation,
                                                                  PNError *error) {
                  
                  if (!error) {
                      
                      [self closeProgressAlertView];
                  }
              }];
}

- (void)replaceDataAtLocation:(NSString *)targetDataLocation withData:(id)data {
    
    [self showProgressAlertView:@"Replacing"];
    [self.client replaceRemoteObjectData:self.object.identifier atLocation:targetDataLocation
                                 witData:data andCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error) {
                                     
                                     if (!error) {
                                         
                                         [self closeProgressAlertView];
                                     }
                                 }];
}

- (void)removeDataAtLocation:(NSString *)targetDataLocation {
    
    [self showProgressAlertView:@"Removing"];
    [self.client removeRemoteObjectData:self.object.identifier atLocation:targetDataLocation
            withCompletionHandlingBlock:^(PNObjectInformation *objectInformation, PNError *error) {
                
                if (!error) {
                    
                    [self closeProgressAlertView];
                }
    }];
}

#pragma mark -


@end
