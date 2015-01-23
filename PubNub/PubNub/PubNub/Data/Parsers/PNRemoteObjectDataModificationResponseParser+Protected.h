//
//  PNRemoteObjectModificationResponseParser_Protected.h
//  PubNub
//
//  Created by Sergey Mamontov on 1/16/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "PNRemoteObjectDataModificationResponseParser.h"
#import "PNObjectInformation+Protected.h"


#pragma mark Static

/**
 @brief Reference on key under which service return time token which represent change date.
 
 @since <#version number#>
 */
static NSString * const kPNResponseTimeTokenKey = @"timetoken";

/**
 @brief Reference on key under which service return location key-path at which change has been
        done.
 
 @since <#version number#>
 */
static NSString * const kPNResponseLocationKey = @"location";

/**
 @brief Reference on key under which service return type of modification which has been accepted.
 
 @since <#version number#>
 */
static NSString * const kPNResponseModificationOperationKey = @"op";

/**
 @brief Reference on key under which service return list entry index assigned during new element
        push reequest (returned only if only one element has been pushed at once).
 
 @since <#version number#>
 */
static NSString * const kPNResponseEntryIndexKey = @"index";


#pragma mark - Structures

struct PNModificationTypeStructure {
    
    // Represent any kind of data to remote object
    __unsafe_unretained NSString *push;
    
    // Represent any single item push to remote object's list
    __unsafe_unretained NSString *pushToList;
    
    // Represent complete data replacement operation
    __unsafe_unretained NSString *replace;
    
    // Represent remote object's data removal
    __unsafe_unretained NSString *remove;
};

extern struct PNModificationTypeStructure PNModificationType;


#pragma mark - Private interface declaration

@interface PNRemoteObjectDataModificationResponseParser ()


#pragma mark - Properties

/**
 @brief Stores reference on instance which temporary represent remote object locally.
 
 @since <#version number#>
 */
@property (nonatomic, strong) PNObjectInformation *objectInformation;


#pragma mark - Instance methods

/**
 @brief Initiate parser using pre-processed \b PubNub service response.
 
 @param response Pre-processed \b PubNub response on remote object data modification request.
 
 @return Initiated and ready to use parser.
 
 @since <#version number#>
 */
- (instancetype)initWithResponse:(PNResponse *)response;

#pragma mark -


@end
