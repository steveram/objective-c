/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRemoteObjectDataFetchResponseParser.h"


#pragma mark Static

/**
 @brief Stores reference on key under which actual data for remote object is stored.
 
 @since <#version number#>
 */
static NSString * const kPNResponseDataKey = @"data";

/**
 @brief Stores reference on data location key-path for data returned in \c kPNResponseDataKey
        field.
 
 @since <#version number#>
 */
static NSString * const kPNResponseDataLocationKey = @"location";

/**
 @brief Under this key service return operation type which has been performed on \b PubNub client
        request.
 
 @since <#version number#>
 */
static NSString * const kPNResponseOperationTypeKey = @"op";

/**
 @brief Stores reference on key under which service return identifier which is required to fetch
        another portion of data.
 
 @since <#version number#>
 */
static NSString * const kPNResponseNextDataPortionPageKey = @"next_page";


#pragma mark - Class forward

@class PNObjectInformation;


#pragma mark - Private interface declaration

@interface PNRemoteObjectDataFetchResponseParser ()


#pragma mark - Properties

/**
 @brief Stores reference on instance which temporary represent remote object locally.
 
 @since <#version number#>
 */
@property (nonatomic, strong) PNObjectInformation *objectInformation;


#pragma mark - Instance methods

/**
 @brief Initiate parser using pre-processed \b PubNub service response.
 
 @param response Pre-processed \b PubNub response on remote object data fetch request.
 
 @return Initiated and ready to use parser.
 
 @since <#version number#>
 */
- (instancetype)initWithResponse:(PNResponse *)response;

#pragma mark -


@end
