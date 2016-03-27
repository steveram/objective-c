/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PubNub+History.h"
#import "PNHistoryResult+Private.h"
#import "PNServiceData+Private.h"
#import "PNErrorStatus+Private.h"
#import "PNRequestParameters.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscribeStatus.h"
#import "PNResult+Private.h"
#import "PNStatus+Private.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


#pragma mark Types

/**
 @brief  Channel history fetch completion block.
 
 @param result Reference on result object which describe service response on history request.
 @param status Reference on status instance which hold information about processing results.
 
 @return \c YES in case if 
 
 @since 4.4
 */
typedef PNRequestParameters *(^PNHistoryRequestCompletionBlock)(PNHistoryResult * _Nullable result,
                                                                PNErrorStatus * _Nullable status);

typedef NS_ENUM(NSUInteger, PNHistoryFetchRequirements) {
    
    /**
     @brief  There is no requirements to received history and values should be returned as soon as received.
     */
    PNHistoryFetchRequirementsNone,
    
    /**
     @brief  Requires from client to fetch messages from history till total messages count won't be equal to
     specified limit.
     */
    PNHistoryFetchRequirementsCount,
    
    /**
     @brief  Requires from client to fetch messages from history till total messages count won't be equal to
     specified limit.
     */
    PNHistoryFetchRequirementsOlderThan,
    
    /**
     @brief  Requires from client to fetch messages from history till total messages count won't be equal to
     specified limit.
     */
    PNHistoryFetchRequirementsNewerThan,
    
    /**
     @brief  Requires from client to fetch messages from history till total messages count won't be equal to
     specified limit.
     */
    PNHistoryFetchRequirementsBetween,
};

NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (HistoryPrivate)


#pragma mark - Fetch history

/**
 @brief  Perform history fetch using configured parameters set.
 
 @param parameters Reference on configured request parameters set.
 @param retryBlock Reference on block which should be set to error status object in case of fialure.
 @param block      Reference on block which should be called at the end of request processing.
 */
- (void)fetchHistoryWithParameters:(PNRequestParameters *)parameters retry:(dispatch_block_t)retryBlock
                        completion:(PNHistoryRequestCompletionBlock)block;


#pragma mark - Handlers

/**
 @brief  History request results handling and pre-processing before notify to completion blocks (if required 
         at all).
 
 @param result Reference on object which represent server useful response data.
 @param status Reference on object which represent request processing results.
 @param block  History pull processing completion block which pass two arguments: \c result - in case of
               successful request processing \c data field will contain results of history request operation;
               \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)handleHistoryResult:(nullable PNResult *)result withStatus:(nullable PNStatus *)status
                 completion:(PNHistoryCompletionBlock)block;


#pragma mark - Misc

- (PNRequestParameters *)parametersForChannel:(NSString *)channel start:(nullable NSNumber *)startDate
                                          end:(nullable NSNumber *)endDate limit:(NSUInteger)limit 
                                      reverse:(BOOL)shouldReverseOrder 
                                    includeTimeToken:(BOOL)shouldIncludeTimeToken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (History)


#pragma mark - Full history

- (void)historyForChannel:(NSString *)channel withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:nil end:nil withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel limit:(NSUInteger)limit 
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel limit:limit includeTimeToken:NO withCompletion:block];
}


#pragma mark - History in specified frame

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:100 withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit includeTimeToken:NO
             withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel olderThan:(NSNumber *)date limit:(NSUInteger)limit
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel olderThan:date limit:limit includeTimeToken:NO withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel newerThan:(NSNumber *)date limit:(NSUInteger)limit
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel newerThan:date limit:limit includeTimeToken:NO withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel between:(NSArray<NSNumber *> *)timeFrame
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel between:timeFrame includeTimeToken:NO withCompletion:block];
}


#pragma mark - History in frame with extended response

- (void)historyForChannel:(NSString *)channel limit:(NSUInteger)limit 
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t retryBlock = ^{
        
        [weakSelf historyForChannel:channel limit:limit includeTimeToken:shouldIncludeTimeToken
                     withCompletion:block];
    };
    
    [self historyForChannel:channel start:nil end:nil limit:limit reverse:NO
           includeTimeToken:shouldIncludeTimeToken requirements:PNHistoryFetchRequirementsCount
             withCompletion:block andRetry:retryBlock];
}

- (void)historyForChannel:(NSString *)channel start:(nullable NSNumber *)startDate
                      end:(nullable NSNumber *)endDate includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:100
           includeTimeToken:shouldIncludeTimeToken withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit includeTimeToken:(BOOL)shouldIncludeTimeToken
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit reverse:NO
           includeTimeToken:shouldIncludeTimeToken withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder 
           withCompletion:(PNHistoryCompletionBlock)block {
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit reverse:shouldReverseOrder 
           includeTimeToken:NO withCompletion:block];
}

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    // Clamp limit to allowed values.
    limit = MIN(limit, (NSUInteger)100);
    
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t retryBlock = ^{
        
        [weakSelf historyForChannel:channel start:startDate end:endDate limit:limit
                            reverse:shouldReverseOrder includeTimeToken:shouldIncludeTimeToken
                     withCompletion:block];
    };
    
    [self historyForChannel:channel start:startDate end:endDate limit:limit reverse:shouldReverseOrder
           includeTimeToken:shouldIncludeTimeToken requirements:PNHistoryFetchRequirementsNone
             withCompletion:block andRetry:retryBlock];
}

- (void)historyForChannel:(NSString *)channel olderThan:(NSNumber *)date limit:(NSUInteger)limit
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t retryBlock = ^{
        
        [weakSelf historyForChannel:channel olderThan:date limit:limit includeTimeToken:shouldIncludeTimeToken
                     withCompletion:block];
    };
    
    [self historyForChannel:channel start:date end:nil limit:limit reverse:NO
           includeTimeToken:shouldIncludeTimeToken requirements:PNHistoryFetchRequirementsOlderThan
             withCompletion:block andRetry:retryBlock];
}

- (void)historyForChannel:(NSString *)channel newerThan:(NSNumber *)date limit:(NSUInteger)limit 
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t retryBlock = ^{
        
        [weakSelf historyForChannel:channel olderThan:date limit:limit includeTimeToken:shouldIncludeTimeToken 
                     withCompletion:block];
    };
    
    [self historyForChannel:channel start:date end:nil limit:limit reverse:YES
           includeTimeToken:shouldIncludeTimeToken requirements:PNHistoryFetchRequirementsNewerThan
             withCompletion:block andRetry:retryBlock];
}

- (void)historyForChannel:(NSString *)channel between:(NSArray<NSNumber *> *)timeFrame
         includeTimeToken:(BOOL)shouldIncludeTimeToken withCompletion:(PNHistoryCompletionBlock)block {
    
    NSParameterAssert(timeFrame.count == 2);
    
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t retryBlock = ^{
        
        [weakSelf historyForChannel:channel between:timeFrame includeTimeToken:shouldIncludeTimeToken
                     withCompletion:block];
    };
    
    [self historyForChannel:channel start:timeFrame.firstObject end:timeFrame.lastObject limit:0 reverse:NO
           includeTimeToken:shouldIncludeTimeToken requirements:PNHistoryFetchRequirementsBetween
             withCompletion:block andRetry:retryBlock];
}


#pragma mark - Fetch history

- (void)historyForChannel:(NSString *)channel start:(NSNumber *)startDate end:(NSNumber *)endDate 
                    limit:(NSUInteger)limit reverse:(BOOL)shouldReverseOrder 
         includeTimeToken:(BOOL)shouldIncludeTimeToken requirements:(PNHistoryFetchRequirements)requirements
           withCompletion:(PNHistoryCompletionBlock)block andRetry:(dispatch_block_t)retryBlock {
    
    DDLogAPICall([[self class] ddLogLevel], @"<PubNub::API> %@ for '%@' channel%@%@ with %@ limit%@.",
                 (shouldReverseOrder ? @"Reversed history" : @"History"), (channel?: @"<error>"),
                 (startDate ? [NSString stringWithFormat:@" from %@", startDate] : @""),
                 (endDate ? [NSString stringWithFormat:@" to %@",  endDate] : @""), @(limit),
                 (shouldIncludeTimeToken ? @" (including message time tokens)" : @""));
    
    NSUInteger eventsCount = (limit == 0 ? 100 : limit);
    PNRequestParameters *parameters = [self parametersForChannel:channel start:startDate end:endDate 
                                                           limit:eventsCount reverse:shouldReverseOrder
                                                includeTimeToken:shouldIncludeTimeToken];
    __block NSUInteger fetchedCount = 0;
    NSUInteger requiredCount = (limit == 0 ? NSUIntegerMax : limit);
    __block NSNumber *oldestEventDate = nil;
    __block NSNumber *newestEventDateDate = nil;
    __block NSArray *messages = nil;
    
    __weak __typeof(self) weakSelf = self;
    [self fetchHistoryWithParameters:parameters retry:retryBlock
                          completion:^PNRequestParameters *(PNHistoryResult * _Nullable result, 
                                                            PNErrorStatus * _Nullable status) {
                              
        PNRequestParameters *nextRequestParameters = nil;
        if (!status.isError && requirements != PNHistoryFetchRequirementsNone && 
            !result.serviceData[@"decryptError"]) {

            BOOL movingFromOlder = (requirements == PNHistoryFetchRequirementsBetween ||  
                                    requirements == PNHistoryFetchRequirementsNewerThan);
            NSArray *fetched = result.data.messages;
            if (movingFromOlder) { messages = [messages?:@[] arrayByAddingObjectsFromArray:(fetched?: @[])]; }
            else { messages = [fetched arrayByAddingObjectsFromArray:messages]; }
            fetchedCount += fetched.count;
            NSUInteger eventsLeft = (fetchedCount < requiredCount ? requiredCount - fetchedCount : 0);
            BOOL shouldFetchMore = (fetched.count && eventsLeft > 0 && fetched.count >= MIN(requiredCount, 100));
            
            NSNumber *nextStartDate = (movingFromOlder ? result.data.end : result.data.start);
            NSNumber *nextEndDate = (movingFromOlder ? endDate : nil);
            if (shouldFetchMore) {
                
                nextRequestParameters = [self parametersForChannel:channel start:nextStartDate end:nextEndDate
                                                             limit:MIN(eventsLeft, eventsCount)
                                                           reverse:shouldReverseOrder
                                                  includeTimeToken:shouldIncludeTimeToken];
            }
            
            if (movingFromOlder) {

                if (!oldestEventDate) { oldestEventDate = result.data.start; }
                if (!nextRequestParameters) { newestEventDateDate = result.data.end; }
            }
            else {
                
                if (!nextRequestParameters) { oldestEventDate = result.data.start; }
                if (!newestEventDateDate) { newestEventDateDate = result.data.end; }
            }
        }

        if (!nextRequestParameters) { 

            [result replaceMessagesWith:messages startDate:oldestEventDate endDate:newestEventDateDate];
            [weakSelf handleHistoryResult:result withStatus:status completion:block];
        }

        return nextRequestParameters;
    }];
}

- (void)fetchHistoryWithParameters:(PNRequestParameters *)parameters retry:(dispatch_block_t)retryBlock
                        completion:(PNHistoryRequestCompletionBlock)block {
    
    __weak __typeof(self) weakSelf = self;
    [self processOperation:PNHistoryOperation withParameters:parameters 
           completionBlock:^(PNHistoryResult * _Nullable result, PNErrorStatus * _Nullable status) {
               
        if (status.isError) { status.retryBlock = retryBlock; }
        PNRequestParameters *nextRequestParameters = block(result, status);
        if (nextRequestParameters) {
            
            [weakSelf fetchHistoryWithParameters:nextRequestParameters retry:retryBlock completion:block];
        }
    }];
}


#pragma mark - Handlers

- (void)handleHistoryResult:(PNHistoryResult *)result withStatus:(PNErrorStatus *)status
                 completion:(PNHistoryCompletionBlock)block {

    if (result && result.serviceData[@"decryptError"]) {
        
        status = [PNErrorStatus statusForOperation:PNHistoryOperation category:PNDecryptionErrorCategory
                               withProcessingError:nil];
        NSMutableDictionary *updatedData = [result.serviceData mutableCopy];
        [updatedData removeObjectForKey:@"decryptError"];
        status.associatedObject = [PNHistoryData dataWithServiceResponse:updatedData];
        [status updateData:updatedData];
    }
    [self callBlock:block status:NO withResult:(status ? nil : result) andStatus:status];
}


#pragma mark - Misc

- (PNRequestParameters *)parametersForChannel:(NSString *)channel start:(NSNumber *)startDate
                                          end:(NSNumber *)endDate limit:(NSUInteger)limit 
                                      reverse:(BOOL)shouldReverseOrder 
                             includeTimeToken:(BOOL)shouldIncludeTimeToken {
    
    // Swap time frame dates if required.
    if (startDate && endDate && [startDate compare:endDate] == NSOrderedDescending) {
        
        NSNumber *_startDate = startDate;
        startDate = endDate;
        endDate = _startDate;
    }
    // Clamp limit to allowed values.
    NSUInteger eventsCount = MIN(limit, (NSUInteger)100);
    
    PNRequestParameters *parameters = [PNRequestParameters new];
    [parameters addQueryParameters:@{@"count": @(eventsCount),
                                     @"reverse": (shouldReverseOrder ? @"true" : @"false"),
                                     @"include_token": (shouldIncludeTimeToken ? @"true" : @"false")}];
    if (startDate) {
        
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:startDate].stringValue
                         forFieldName:@"start"];
    }
    if (endDate) {
        
        [parameters addQueryParameter:[PNNumber timeTokenFromNumber:endDate].stringValue
                         forFieldName:@"end"];
    }
    if (channel.length) {
        
        [parameters addPathComponent:[PNString percentEscapedString:channel] forPlaceholder:@"{channel}"];
    }
    
    return parameters;
}

#pragma mark -


@end
