//
//  DSObjectModificationViewController.h
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/28/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSDataModificationDelegate.h"
#import "DSUserInputViewController.h"


#pragma mark Types & Structures

typedef NS_OPTIONS(NSUInteger, DSObjectModificationType) {
    
    DSObjectMergeModificationType,
    DSObjectPushModificationType,
    DSObjectReplaceModificationType
};


#pragma mark - Public interface declaration

@interface DSObjectModificationViewController : DSUserInputViewController


#pragma mark - Properties

/**
 @brief Stores reference on delegate which handle all modification requests and send them on
        processing to \b PubNub cloud service.
 */
@property (nonatomic, weak) id <DSDataModificationDelegate> modificationDelegate;

/**
 @brief Stores reference on enum field which specify what kind of modification expected.
 */
@property (nonatomic, assign) DSObjectModificationType modificationType;

/**
 @brief Stores reference at place, where data modification sbould be applied.
 */
@property (nonatomic, copy) NSString *modificationLocation;

/**
 @brief Reference on data which should be used during data modification process and will be sent
        to \b PubNub cloud service.
 */
@property (nonatomic, strong) id data;


#pragma mark -


@end
