//
//  DSDataModificationDelegate.h
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/28/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PubNub/PNImports.h>


#pragma mark Protocol declaration

@protocol DSDataModificationDelegate <NSObject>


#pragma mark - Delegate methods

/**
 @brief Ask delegate to provide notification observer center which can be used for own purposes.
 
 @return Observer instance which is used by initialized \b PubNub cloud.
 */
- (PNObservationCenter *)observer;

/**
 @brief Called on delegate when user completed composition of data which should be updated or
        added into dictionary in \b PubNub cloud.
 
 @param targetDataLocation Target data location key-path at which new data should be merged.
 @param data               Data which will be merged with existing / create new at specified 
                           location.
 */
- (void)mergeDataAtLocation:(NSString *)targetDataLocation withData:(id)data;

/**
 @brief Called on delegate when user completed composition of data which should be placed instead
        of data at specified location in \b PubNub cloud.
 
 @param targetDataLocation Target data location key-path at which new data should be replaced.
 @param data               Data which will be used to replace old one.
 */
- (void)replaceDataAtLocation:(NSString *)targetDataLocation withData:(id)data;

/**
 @brief Called on delegate when user confirmed his desire to remove piece of data at specified
        location.
 
 @param targetDataLocation Target data location key-path at which data should be removed.
 */
- (void)removeDataAtLocation:(NSString *)targetDataLocation;

/**
 @brief Called on delegate when user confirmed his desire to push some new entries to the list at
        specified location.
 
 @param data               Data which should be pushed into the list in \b PubNub cloud.
 @param targetDataLocation Reference on location where list entries should be pushed.
 @param sortKey            Key used by server to sort list entries before return them to the 
                           client.
 */
- (void)pushData:(id)data toLocation:(NSString *)targetDataLocation withSortingKey:(NSString *)sortKey;

#pragma mark -


@end
