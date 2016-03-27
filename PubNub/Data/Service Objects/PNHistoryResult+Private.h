/**
 @author Sergey Mamontov
 @since 4.4
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNHistoryResult.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  History result class extension for multi-request history fetch.
 
 @since 4.4
 */
@interface PNHistoryResult (Private)


///------------------------------------------------
/// @name Data modification
///------------------------------------------------

/**
 @brief      Update service information which is stored in receiver.
 @discussion Method allow to replace single request response messages list with list which has been fetched
             during previous requests.
 
 @param messages List of messages with which existing data should be replaced.
 @param start    Time token for oldest message which is stored in \c messages.
 @param end      Time token for newesr message which is stored in \c messages.
 
 @since 4.4
 */
- (void)replaceMessagesWith:(NSArray *)messages startDate:(NSNumber *)start endDate:(NSNumber *)end;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
