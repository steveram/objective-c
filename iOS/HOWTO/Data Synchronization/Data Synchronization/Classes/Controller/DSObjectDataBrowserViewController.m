//
//  DSObjectDataBrowserViewController.m
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/27/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "DSObjectDataBrowserViewController.h"
#import "DSObjectModificationViewController.h"
#import <PubNub/PNImports.h>


#pragma mark Types & Structures

struct PNEntryDataStructure {
    
    /**
     @brief Stores value key-path information which will allow to get into the object.
     */
    __unsafe_unretained NSString *keyPath;
    
    /**
     @brief Stores key in case if entry represent one of dictionary entries.
     */
    __unsafe_unretained NSString *key;
    
    /**
     @brief Stores actual object title which should be displayed in main part of entry cell.
            For simple value stored in list it will represent that value.
     */
    __unsafe_unretained NSString *title;
    
    /**
     @brief For dictionary entry it will store modification date. For list on simple value it
            will store object index.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *additionalInformation;
    
    /**
     @brief Stores whether this entry can be expanded to view more information or not.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *isObject;
};

struct PNEntryDataStructure PNEntryData = {
    
    .keyPath = @"keyPath",
    .key = @"key",
    .title = @"title",
    .additionalInformation = @"additionalInformation",
    .isObject = @"isObject"
};


#pragma mark Private interface declaration

@interface DSObjectDataBrowserViewController () <UIGestureRecognizerDelegate,
                                                 UIActionSheetDelegate, UIAlertViewDelegate>


#pragma mark - Properties

/**
 @brief Stores reference on prepared entry data.
 */
@property (nonatomic, strong) NSArray *entries;

/**
 @brief Stores reference on data against which manipulation should be done.
 */
@property (nonatomic, strong) NSDictionary *activeEntryData;


#pragma mark - Instance methods

/**
 @brief Complete object data browser initialization.
 */
- (void)prepareInterface;

/**
 @brief Update existing interface using latest state information.
 */
- (void)updateInterface;

/**
 @brief Depending on selected/current target there can be different set of actions which can
        be performed on data.
 */
- (void)showAvailableActions;


#pragma mark - Handler methods

/**
 @brief Allow to handle modification event and depending on whether data presented in controller
        affected by change or not.
 
 @param object            Reference on remote data object at which modification event has been
                          triggered.
 @param modifiedLocations List of data location key-paths at which data has been modified.
 */
- (void)handleObject:(PNObject *)object modificationAtLocations:(NSArray *)modifiedLocations;

/**
 @brief Handle user tap on "disconnect" to dismiss presented view controller.
 
 @param sender Reference on button on which user tapped.
 */
- (void)handleDisconnectButtonTouch:(id)sender;

/**
 @brief Handle user tap on collection holder action button.
 
 @param sender Reference on action button on which user tapped.
 
 @since <#version number#>
 */
- (IBAction)handleActionButtonTouch:(id)sender;

/**
 @brief Handle user's long press on one of table entries.
 
 @param gestureRecognizer Reference on gesture which will be used in future to calculate target
                          cell on which user would like to perform modifications.
 */
- (void)handleCellLongPress:(UILongPressGestureRecognizer *)gestureRecognizer;


#pragma mark - Misc methods

/**
 @brief Verify whether displayed object data still available in it's tree or not.
 
 @return \c YES in case if data at requested key-path still part of the object.
 */
- (BOOL)isDataAvailableAtKeyPath;

/**
 @brief Even if data directly available via passed \b PNObject it is better to create separate
        reference on concrete piece of it which is presented in current browser at specified
        data key-path.
 */
- (void)prepareDataSource;

/**
 @brief Start remote object modification events observation to update layout as it may be 
        required.
 */
- (void)registerForDataSynchronizationEvents;

/**
 @brief After end of controller's life-cycle it should stop observation on remote object data
        update events to prevent app from crashing (object will be released).
 */
- (void)unregisterForDataSynchronizationEvents;

#pragma mark -

@end


#pragma mark - Public interface implementation

@implementation DSObjectDataBrowserViewController


#pragma mark - Instance methods

- (void)awakeFromNib {
    
    // Forward method call to the super class.
    [super awakeFromNib];
    
    [self prepareInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewWillAppear:animated];
    
    if (![self isDataAvailableAtKeyPath]) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        
        [self prepareDataSource];
        [self updateInterface];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewDidAppear:animated];
    
    [self registerForDataSynchronizationEvents];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    // Forward method call to the super class.
    [super viewDidDisappear:animated];
    
    [self unregisterForDataSynchronizationEvents];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSString *action = (NSString *)sender;
    DSObjectModificationViewController *objectModify = (DSObjectModificationViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
    
    NSString *targetKeyPath = self.dataKeyPath;
    if (self.activeEntryData) {
        
        targetKeyPath = self.activeEntryData[PNEntryData.keyPath];
    }
    
    objectModify.modificationDelegate = self.modificationDelegate;
    objectModify.modificationLocation = targetKeyPath;
    objectModify.data = [self.object pn_objectAtKeyPath:targetKeyPath];
    
    if ([action isEqualToString:@"Replace"]) {
        
        objectModify.modificationType = DSObjectReplaceModificationType;
    }
    else if ([action isEqualToString:@"Merge"]) {
        
        objectModify.modificationType = DSObjectMergeModificationType;
    }
    else if ([action isEqualToString:@"Push"]) {
        
        objectModify.modificationType = DSObjectPushModificationType;
    }
}

- (void)prepareInterface {
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                                  target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleCellLongPress:)];
    longPressGesture.minimumPressDuration = 2.0;
    longPressGesture.delegate = self;
    [self.tableView addGestureRecognizer:longPressGesture];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
}

- (void)updateInterface {
    
    if (![self.dataKeyPath length] && !self.navigationItem.leftBarButtonItem) {
        
        UIBarButtonItem *disconnect = [[UIBarButtonItem alloc] initWithTitle:@"disconnect" style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(handleDisconnectButtonTouch:)];
        self.navigationItem.leftBarButtonItem = disconnect;
    }
    
    NSString *title = self.object.identifier;
    if ([self.dataKeyPath length]) {
        
        title = [[self.dataKeyPath componentsSeparatedByString:@"."] lastObject];
    }
    self.title = title;
}

- (void)showAvailableActions {
    
    BOOL proposeEntryActions = (self.activeEntryData != nil);
    id object = self.activeEntryData;
    NSString *keyPath = self.dataKeyPath;
    if (object) {
        
        keyPath = object[PNEntryData.keyPath];
    }
    
    if ([keyPath length]) {
        
        object = [self.object pn_objectAtKeyPath:keyPath];
    }
    else {
        
        object = self.object;
    }
    BOOL isObject = [object respondsToSelector:@selector(count)];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    if (!proposeEntryActions) {
        
        if ([object isKindOfClass:[NSArray class]]) {
            
            [sheet addButtonWithTitle:@"Push"];
        }
        else {
            
            [sheet addButtonWithTitle:@"Merge"];
        }
        [sheet addButtonWithTitle:@"Replace"];
    }
    else {
        
        if ([object isKindOfClass:[NSArray class]]) {
            
            [sheet addButtonWithTitle:@"Push"];
        }
        if (isObject) {
            
            [sheet addButtonWithTitle:@"Replace"];
        }
            
        [sheet addButtonWithTitle:@"Merge"];
        
    }
    if ([keyPath length]) {
        
        [sheet addButtonWithTitle:@"Remove"];
    }
    [sheet showInView:self.view];
}


#pragma mark - Handler methods

- (void)handleObject:(PNObject *)object modificationAtLocations:(NSArray *)modifiedLocations {
    
    // Ensure that event arrived on object which has been presented by controller.
    if ([object.identifier isEqualToString:self.object.identifier]) {
        
        if ([self isDataAvailableAtKeyPath]) {
            
            [self prepareDataSource];
        }
        else if ([[self.navigationController visibleViewController] isEqual:self]){
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)handleDisconnectButtonTouch:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handleCellLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.tableView];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
        if (indexPath) {
            
            self.activeEntryData = self.entries[indexPath.row];
            [self showAvailableActions];
        }
    }
}

- (IBAction)handleActionButtonTouch:(id)sender {
    
    [self showAvailableActions];
}


#pragma mark - Misc methods

- (BOOL)isDataAvailableAtKeyPath {
    
    BOOL isDataAvailableAtKeyPath = [self.object isValid];
    if (isDataAvailableAtKeyPath) {
        
        isDataAvailableAtKeyPath = ([self.dataKeyPath length] != 0);
        if ([self.dataKeyPath length] == 0) {
            
            __block id currentStorage = self.object;
            NSArray *keyPathComponents = [self.dataKeyPath componentsSeparatedByString:@"."];
            [keyPathComponents enumerateObjectsUsingBlock:^(NSString *keyPathComponent,
                                                            NSUInteger keyPathComponentIdx,
                                                            BOOL *keyPathComponentEnumeratorStop) {
                
                if ([currentStorage isKindOfClass:[NSArray class]]) {
                    
                    currentStorage = [(NSArray *)currentStorage pn_objectAtIndex:keyPathComponent];
                }
                else {
                    
                    currentStorage = [(NSDictionary *)currentStorage valueForKey:keyPathComponent];
                }
                
                *keyPathComponentEnumeratorStop = (currentStorage == nil);
            }];
            
            isDataAvailableAtKeyPath = (currentStorage != nil);
        }
    }
    
    
    return isDataAvailableAtKeyPath;
}

- (void)prepareDataSource {
    
    if ([self.object isValid]) {
        
        NSMutableArray *dataToShow = [NSMutableArray array];
        id storedData = self.object;
        if ([self.dataKeyPath length]) {
            
            storedData = [self.object pn_objectAtKeyPath:self.dataKeyPath];
        }
        NSString *(^keyPathBlock)(NSString *pathComponents) = ^NSString *(NSString *pathComponents) {
            
            NSString *keyPath = pathComponents;
            if ([self.dataKeyPath length]) {
                
                keyPath = [self.dataKeyPath stringByAppendingFormat:@".%@", pathComponents];
            }
            
            return keyPath;
        };
        if ([storedData isKindOfClass:[NSDictionary class]]) {
            
            [(NSDictionary *)storedData enumerateKeysAndObjectsUsingBlock:^(NSString *entryKey,
                                                                            id entry,
                                                                            BOOL *entriesEnumeratorStop) {
                
                NSString *modificationDate = [[entry pn_modificationDate] stringValue];
                modificationDate = (modificationDate ? modificationDate : @"");
                
                NSString *title = @"{collection}";
                BOOL isObject = NO;
                if ([entry respondsToSelector:@selector(count)]) {
                    
                    isObject = YES;
                }
                else {
                    
                    title = entry;
                }
                [dataToShow addObject:@{PNEntryData.keyPath:keyPathBlock(entryKey),
                                        PNEntryData.key:entryKey,
                                        PNEntryData.title:title,
                                        PNEntryData.additionalInformation:modificationDate,
                                        PNEntryData.isObject:@(isObject)}];
            }];
        }
        else {
            
            [(NSArray *)storedData enumerateObjectsUsingBlock:^(id entry, NSUInteger entryIdx,
                                                                BOOL *entriesEnumeratorStop) {
                
                NSString *additionalData = [entry pn_index];
                additionalData = (additionalData ? additionalData : @"");
                NSString *title = entry;
                BOOL isObject = NO;
                if ([entry respondsToSelector:@selector(count)]) {
                    
                    title = @"{collection}";
                    isObject = YES;
                }
                else {
                    
                    title = entry;
                }
                [dataToShow addObject:@{PNEntryData.keyPath:keyPathBlock(additionalData),
                                        PNEntryData.title:title,
                                        PNEntryData.additionalInformation:additionalData,
                                        PNEntryData.isObject:@(isObject)}];
            }];
        }
        
        self.entries = [dataToShow copy];
    }
    else {
        
        self.entries = [NSArray array];
    }
    
    [self.tableView reloadData];
}

- (void)registerForDataSynchronizationEvents {
    
    [self.modificationDelegate.observer addRemoteObjectModificationEventObserver:self
                                                               withCallbackBlock:^(PNObject *object,
                                                                                   NSArray *locations) {
        
        [self handleObject:object modificationAtLocations:locations];
    }];
}

- (void)unregisterForDataSynchronizationEvents {
    
    [self.modificationDelegate.observer removeRemoteObjectModificationEventObserver:self];
}


#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *entryData = self.entries[indexPath.row];
    
    NSString *targetCellIdentifier = @"DSListEntryCell";
    if ([entryData objectForKey:PNEntryData.key]) {
        
        targetCellIdentifier = @"DSDictionaryEntryCell";
    }
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:targetCellIdentifier];
    [cell performSelector:@selector(updateWithData:) withObject:entryData];
    #pragma clang diagnostic pop
    
    if ([entryData[PNEntryData.isObject] boolValue]) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *entryData = self.entries[indexPath.row];
    
    if ([entryData[PNEntryData.isObject] boolValue]) {

        DSObjectDataBrowserViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DSObjectDataBrowserViewController"];
        controller.object = self.object;
        controller.dataKeyPath = entryData[PNEntryData.keyPath];
        controller.modificationDelegate = self.modificationDelegate;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet cancelButtonIndex] != buttonIndex) {
        
        NSString *targetKeyPath = self.dataKeyPath;
        if (self.activeEntryData) {
            
            targetKeyPath = self.activeEntryData[PNEntryData.keyPath];
        }
        
        NSString *action = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([action isEqualToString:@"Remove"]) {
            
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Data removal"
                                   message:[NSString stringWithFormat:@"Do you realy want to "
                                            "remove data at '%@' key-path?", targetKeyPath] delegate:self
                                                 cancelButtonTitle:@"No"
                                                 otherButtonTitles:@"Remove", nil];
            [view show];
        }
        else {
            
            [self performSegueWithIdentifier:@"showObjectModification" sender:action];
        }
    }
}


#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.cancelButtonIndex != buttonIndex) {
        
        NSString *targetKeyPath = self.dataKeyPath;
        if (self.activeEntryData) {
            
            targetKeyPath = self.activeEntryData[PNEntryData.keyPath];
        }
        [self.modificationDelegate removeDataAtLocation:targetKeyPath];
    }
    self.activeEntryData = nil;
}

#pragma mark -


@end
