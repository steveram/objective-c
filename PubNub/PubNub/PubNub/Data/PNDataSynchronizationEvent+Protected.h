//
//  PNDataSynchronizationEvent+Protected.h
//  PubNub
//
//  Created by Sergey Mamontov on 1/21/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "PNDataSynchronizationEvent.h"


#pragma mark Types & Structures

/**
 @brief Enum represents all data keys which is used by remote object data provider service.

 @since <#version number#>
 */
struct PNDataSynchronizationEventDataKeysStruct {

    /**
     @brief Stores reference on key under which service provided type of remote object data
            modification.

     @since <#version number#>
     */
    __unsafe_unretained NSString *action;

    /**
     @brief Stores reference on key under which service provided data modification time token.

     @since <#version number#>
     */
    __unsafe_unretained NSString *timeToken;

    /**
     @brief Stores reference on key under which service provided location where data has been
            modified.

     @since <#version number#>
     */
    __unsafe_unretained NSString *location;

    /**
     @brief Stores reference on key under which service provided actual data which should be used
            during modification at specified location.

     @since <#version number#>
     */
    __unsafe_unretained NSString *value;

    /**
     @brief Stores reference on key under which service provided modification transaction status
            information (completed).

     @since <#version number#>
     */
    __unsafe_unretained NSString *transactionStatus;

    /**
     @brief Stores reference on key under which service provided modification transaction
            identifier.

     @since <#version number#>
     */
    __unsafe_unretained NSString *transactionIdentifier;
};

extern struct PNDataSynchronizationEventDataKeysStruct PNDataSynchronizationEventDataKeys;


#pragma mark - Private interface declaration

@interface PNDataSynchronizationEvent ()


#pragma mark - Properties

@property (nonatomic, assign) PNDataSynchronizationEventType type;
@property (nonatomic, copy) NSString *objectIdentifier;
@property (nonatomic, copy) NSString *moidificationTransactionIdentifier;
@property (nonatomic, copy) NSString *relativeLocation;
@property (nonatomic, copy) NSString *modificationLocation;
@property (nonatomic, copy) NSString *modificationTimeToken;
@property (nonatomic, strong) id data;


#pragma mark - Class methods

/**
 @brief Create data synchronization event instance.

 @discussion This instance will be used in future by synchronization manager to apply changes which
             arrived from \b PubNub cloud.

 @param objectIdentifierWithPath Reference on event location full path which is composed from object
                                 synchronization feed name and location at which change has been
                                 done.
 @param eventPayload             Reference on data synchronization event payload with all required
                                 information.

 @return Initialized and ready to use event instance.

 @since <#version number#>
 */
+ (instancetype)eventAt:(NSString *)objectIdentifierWithPath
            withPayload:(NSDictionary *)eventPayload;

/**
 @brief      Verify whether provided payload should be treated as data synchronization event or not.

 @discussion There should be predefined set of fields and types that value treated as data
             synchronization event.

 @param eventPayload \c NSDictionary against which check should be performed.

 @return \c YES in case if all required fields available and have corresponding data type.

 @since <#version number#>
 */
+ (BOOL)isDataSynchronizationEvent:(NSDictionary *)eventPayload;


#pragma mark - Instance methods

/**
 @brief Initialize data synchronization event instance.

 @discussion This instance will be used in future by synchronization manager to apply changes which
             arrived from \b PubNub cloud.

 @param type                         One of \c PNDataSynchronizationEventType fields to describe
                                     what kind of action should be performed by \b PubNub client's
                                     synchronization manager.
 @param objectIdentifier             Reference on remote object identifier at which modification is
                                     happened inside \b PubNub cloud.
 @param transactionIdentifier        Reference on bulk change transaction identifier (allow to group
                                     changes in transactions).
 @param modificationLocation         Reference on actual location where data should be modified.
 @param relativeModificationLocation Reference on location inside of which changed object reside.
 @param modificationTimeToken        Reference on modification time token (allow to sort
                                     modifications and apply they in order).
 @param data                         Reference on actual data which should be used for local cache
                                     modification.

 @return Initialized and ready to use event instance.

 @since <#version number#>
 */
- (instancetype)initEvent:(PNDataSynchronizationEventType)type forRemoteObject:(NSString *)objectIdentifier
    transactionIdentifier:(NSString *)transactionIdentifier location:(NSString *)modificationLocation
         relativeLocation:(NSString *)relativeModificationLocation
                timeToken:(NSString *)modificationTimeToken andData:(id)data;

#pragma mark -

@end