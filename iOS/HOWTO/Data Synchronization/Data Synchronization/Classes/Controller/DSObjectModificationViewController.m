//
//  DSObjectModificationViewController.m
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/28/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "DSObjectModificationViewController.h"
#import <PubNub/PNImports.h>


#pragma mark - Private interface declaration

@interface DSObjectModificationViewController () <UITextViewDelegate, UITextFieldDelegate>


#pragma mark - Properties

/**
 @brief Stores reference on text field which allow user to modify data location key-path at which
        modification will be done.
 */
@property (nonatomic, weak) IBOutlet UITextField *dataLocationKeyPathTextField;

/**
 @brief Stores reference on sorting key pre-field label.
 */
@property (nonatomic, weak) IBOutlet UILabel *entrySortingKeyLabel;

/**
 @brief Stores reference on text field which allow user specify sorting key which should be
        applied to the new entries which is pushed to the list in \b PubNub cloud.
 */
@property (nonatomic, weak) IBOutlet UITextField *entrySortingKeyTextField;

/**
 @brief Stores reference on text view which allow user to modify or specify data which should be
        used during modification process.
 */
@property (nonatomic, weak) IBOutlet UITextView *dataTextView;

/**
 @brief During data input this property stores reference on active text field frame for further
        calculation during interface updated for keyboard.
 */
@property (nonatomic, assign) CGRect activeFieldFrame;


#pragma mark - Instance methods

/**
 @brief Called to update existing interface using last state information.
 */
- (void)updateInterface;

/**
 @brief Method allow to update navigation bar elements for data editing / browsing.
 
 @param forDataEditing Whether navigation bar should be updated for data editing or viewing.
 */
- (void)updateNavigationItems:(BOOL)forDataEditing;


#pragma mark - Handler methods

/**
 @brief Handle data editing cancel button tap.
 
 @param sender Reference on button at which user tapped.
 */
- (IBAction)handleEditingCancelButtonTouch:(id)sender;

/**
 @brief Handle data editing completion button tap.
 
 @param sender Reference on button at which user tapped.
 */
- (void)handleEditingCompleteButtonTouch:(id)sender;

/**
 @brief Handle data modification completion button tap.
 
 @param sender Reference on button at which user tapped.
 */
- (void)handleModificationCompleteButtonTouch:(id)sender;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation DSObjectModificationViewController


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    __block __pn_desired_weak __typeof(self) weakSelf = self;
    self.scrollOffsetChangeBlock = ^CGRect { return weakSelf.activeFieldFrame; };
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward methods call to the super class.
    [super viewWillAppear:animated];
    
    [self updateInterface];
}

- (void)updateInterface {
    
    if (![self.title length]) {
        
        switch (self.modificationType) {
            case DSObjectMergeModificationType:
                
                self.title = @"Merge";
                break;
            case DSObjectPushModificationType:
                
                self.title = @"Push";
                break;
            case DSObjectReplaceModificationType:
                
                self.title = @"Replace";
                break;
                
            default:
                break;
        }
    }
    
    self.dataLocationKeyPathTextField.text = self.modificationLocation;
    
    NSString *dataForEdition = nil;
    if ([self.data respondsToSelector:@selector(count)]) {
        
        NSError *convertionError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.data options:NSJSONWritingPrettyPrinted
                                                             error:&convertionError];
        if (!convertionError) {
            
            dataForEdition = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        else {
            
            dataForEdition = @"";
        }
    }
    else if ([self.data isKindOfClass:[NSString class]]) {
        
        dataForEdition = [NSString stringWithFormat:@"\"%@\"", self.data];
    }
    else {
        
        dataForEdition = self.data;
    }
    self.dataTextView.text = dataForEdition;
    
    self.entrySortingKeyLabel.enabled = (self.modificationType == DSObjectPushModificationType);
    self.entrySortingKeyTextField.enabled = (self.modificationType == DSObjectPushModificationType);
    
    [self updateNavigationItems:NO];
}

- (void)updateNavigationItems:(BOOL)forDataEditing {
    
    UIBarButtonItem *button = nil;
    if (forDataEditing) {
        
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                               target:self
                                                               action:@selector(handleEditingCompleteButtonTouch:)];
    }
    else {
        
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                               target:self
                                                               action:@selector(handleModificationCompleteButtonTouch:)];
    }
    
    [self.navigationItem setRightBarButtonItem:button animated:YES];
}


#pragma mark - Handler methods

- (IBAction)handleEditingCancelButtonTouch:(id)sender {
    
    [self completeUserInput];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handleEditingCompleteButtonTouch:(id)sender {
    
    [self completeUserInput];
}

- (void)handleModificationCompleteButtonTouch:(id)sender {
    
    if ([self.dataTextView.text length]) {
        
        id dataForModification = nil;
        NSString *trimmedData = [self.dataTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSError *serializationError;
        dataForModification = [NSJSONSerialization JSONObjectWithData:[trimmedData dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:NSJSONReadingAllowFragments
                                                                error:&serializationError];
        
        if (!serializationError) {
            
            NSString *modificationLocation = self.dataLocationKeyPathTextField.text;
            modificationLocation = ([modificationLocation length] ? modificationLocation : nil);
            if (self.modificationType == DSObjectPushModificationType &&
                ![dataForModification isKindOfClass:[NSArray class]]) {
                    
                dataForModification = [NSArray arrayWithObject:dataForModification];
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                switch (self.modificationType) {
                    case DSObjectMergeModificationType:
                        
                        [self.modificationDelegate mergeDataAtLocation:modificationLocation
                                                              withData:dataForModification];
                        break;
                    case DSObjectPushModificationType:
                        {
                            
                            NSString *sortingKey = self.entrySortingKeyTextField.text;
                            sortingKey = ([sortingKey length] ? sortingKey : nil);
                            
                            [self.modificationDelegate pushData:dataForModification
                                                     toLocation:modificationLocation withSortingKey:sortingKey];
                        }
                        break;
                    case DSObjectReplaceModificationType:
                        
                        [self.modificationDelegate replaceDataAtLocation:modificationLocation
                                                                withData:dataForModification];
                        break;
                        
                    default:
                        break;
                }
            }];
        }
        else {
            
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Malformed JSON"
                                                           message:[serializationError description]
                                                          delegate:self
                                                 cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [view show];
        }
    }
}


#pragma mark - UITextField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.activeFieldFrame = textField.frame;
    [self updateNavigationItems:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self completeUserInput];
    
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self updateNavigationItems:NO];
}

#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    self.activeFieldFrame = textView.frame;
    [self updateNavigationItems:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self updateNavigationItems:NO];
}

#pragma mark -


@end
