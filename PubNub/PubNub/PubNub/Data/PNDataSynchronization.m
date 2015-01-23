/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNDataSynchronization.h"
#import "PNSynchronizationChannel+Protected.h"
#import "PNObjectInformation+Protected.h"
#import "NSObject+PNPrivateAdditions.h"
#import "PNDataSynchronizationEvent.h"
#import "PNDataSynchronizationTask.h"
#import "NSDictionary+PNAdditions.h"
#import "PNObject+Protected.h"
#import "PNErrorCodes.h"
#import "PNError.h"
#import "PNDataSynchronizationEvent+Protected.h"
#import "NSArray+PNAdditions.h"


#pragma mark Structures

struct PNObjectDataStructure {
    
    /**
     @brief Stores reference on \b PNObject instance itself which is used to represent object
            stored in \b PubNub cloud locally.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *object;
    
    /**
     @brief Stores reference on object's data stored in the cloud. In case, if information will
            arrive with key-path which will tell that this is object, \a NSDictionary will be
            stored there. In case, if key-path will have markers on lists, modified \b NSArray
            will be stored there.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *data;
    
    /**
     @brief Stores reference on paths which is used for partial data synchronization.
     
     @since <#version number#>
     */
    struct {
        
        /**
         @brief Stores reference on mutable set of paths which can't be linked to more general 
                paths.
         
         @since <#version number#>
         */
        __unsafe_unretained NSString *parent;
        
        /**
         @brief Stores reference on mutable set of paths which can notify about syncrhonization 
                events using more general paths from \c parent paths array.
         
         @since <#version number#>
         */
        __unsafe_unretained NSString *children;
    } paths;
    
    /**
     @brief Stores reference on synchronization task information which is used by manager and
            \b PubNub client to complete synchronization start/stop.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *synchronizationTask;
    
    /**
     @brief Stores reference on fetch which has been launced by used and temporary till process
            completion reside in own cache.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *activeFetch;

    /**
     @brief Stores reference on dictionary which stored information about active synchronization
            events.

     @since <#version number#>
     */
    __unsafe_unretained  NSString *transactions;
};

struct PNObjectDataStructure PNObjectData = {
    
    .object = @"object",
    .data = @"data",
    .paths = {
        
        .parent = @"parent",
        .children = @"children"
    },
    .synchronizationTask = @"synchronizationTask",
    .activeFetch = @"activeFetch",
    .transactions = @"transactions"
};


#pragma mark - Private interface declaration

@interface PNDataSynchronization ()


#pragma mark - Properties

/**
 @brief Stores reference between remote data object identifier and instance which represent it
        locally inside of client.
 
 @since <#version number#>
 */
@property (nonatomic, strong) NSMutableDictionary *objects;


#pragma mark - Instance methods

/**
 @brief      Helper method which allow to find out suitable synchronization data feed channels
             configuration.
 
 @discussion This method will take into account list of locations (if they has been synchronized
             earlier) and provide list of locations on which client should subscribe and list
             of locations from which client should remove synchronization events observation.
 
 @param objectInformation         Reference on temporary instance which describes locally remote
                                  object from \b PubNub cloud along with required information for
                                  synchronization process.
 @param isForSynchronization      Whether processing should be done for new data locations or not.
 @param processingCompletionBlock Block is called at the end of data processing operation and
                                  pass two arguments: \c parentDataFeeds - list of data 
                                  synchronization channels on which client should subscribe; 
                                  \c childDataFeeds - list of channels from which client should
                                  unsubscribe in case if \c isForSynchronization set to \c YES.
 
 @since <#version number#>
 */
- (void)synchronizationDataFeedChannelsFor:(PNObjectInformation *)objectInformation
                   forSynchronizationStart:(BOOL)isForSynchronization
                       withCompletionBlock:(void (^)(NSArray *parentDataFeeds,
                                                     NSArray *childDataFeeds))processingCompletionBlock;

/**
 @brief      Prepare manager for object synchronization process.
 
 @discussion Provided object information will be placed into special local cache and allow 
             sequental updates from multi-paged remote object data.
             At the end of synchronization process manager will merge received data into local
             copy of remote object (\b PNObject) or create new one. Merge will be done basing on
             \b replace algorithm.
             Manager will use this opportunity to calculate set of data synchronization feed
             objects on which client should subscribe or unsubscribe from.
 
 @param objectInformation Reference on temporary instance which describes locally remote object
                          from \b PubNub cloud and will be used for temoporary storage of data
                          received from \b PubNub cloud.
 @param isForSynchronization      Whether processing should be done for new data locations or not.
 @param completionBlock   Block which is called at the end of preparation to let know called that
                          everything has been prepared. Pass two arguments: 
                          \c relevantDataFeedObjects - list of data synchronization channels on 
                          which client should subscribe; \c irrelevantDataFeedObjects - list of 
                          channels from which client should unsubscribe.
 
 @note Object is able to perform synchronization only for one \c objectInformation instance at 
       once.
 
 @since <#version number#>
 */
- (void)prepareForSynchronization:(PNObjectInformation *)objectInformation
          forSynchronizationStart:(BOOL)isForSynchronization
                        withBlock:(void (^)(NSArray *relevantDataFeedObjects,
                                            NSArray *irrelevantDataFeedObjects))completionBlock;

/**
 @brief      Handle synchronization start event on set of data synchronization feeds.
 
 @discussion Handle and commit subscription event on synchronization task for each of remote
             object identifiers which can be passed in \c synchronizationDataFeedObjects .
 
 @param isSynchronizationStart         Whether handling synchronization start or not.
 @param synchronizationDataFeedObjects List of data feed synchronization objects for which
                                       \b PubNub completed one of steps (subscribe or unsubscribe
                                       to/from set of data feed synchronization objects).
 @param completionBlock                Handling completion block is called when all preparations
                                       for next step is done and pass only one argument
                                       \c synchronizationTasks which stores list of tasks for
                                       each remote data object identifier which has been passed 
                                       in \c synchronizationDataFeedObjects .
 
 @since <#version number#>
 */
- (void)handleSynchronization:(BOOL)isSynchronizationStart
                    onObjects:(NSArray *)synchronizationDataFeedObjects
                    withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNDataSynchronization


#pragma mark - Instance methods

- (instancetype)init {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.objects = [NSMutableDictionary dictionary];
        [self pn_setupPrivateSerialQueueWithIdentifier:@"data-synchronization"
                                           andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
    }
    
    
    return self;
}


#pragma mark - Data feeds helper methods

- (void)synchronizationDataFeedChannelsFor:(PNObjectInformation *)objectInformation
                   forSynchronizationStart:(BOOL)isForSynchronization
                       withCompletionBlock:(void (^)(NSArray *parentDataFeeds,
                                                     NSArray *childDataFeeds))processingCompletionBlock {
    
    [self pn_scheduleOnPrivateQueueAssert];
        
    NSDictionary *objectData = [self.objects valueForKey:objectInformation.identifier];
    
    // Check whether manager already stores local copy of the object using some data feeds or
    // not.
    if ([[objectData valueForKey:PNObjectData.paths.parent] count]) {
        
        // Re-assign provided locations to "*" in case if user would like to synchronize
        // whole remote data object from \b PubNub cloud.
        NSArray *providedLocations = ([objectInformation.dataLocations count] ? objectInformation.dataLocations : @[@"*"]);
        
        // Fetch parent key-paths which is used by client to receive synchronization events
        // for specified object
        NSMutableSet *objectLocationsParent = [[objectData valueForKey:PNObjectData.paths.parent] mutableCopy];
        
        NSSet *targetParents = nil;
        NSArray *parentDataFeeds = nil;
        NSArray *childDataFeeds = nil;
        
        if (isForSynchronization) {
            
            // Filter parent key-paths among locations provided by user
            NSSet *providedLocationsParent = [NSSet setWithArray:[NSDictionary pn_topLevelKeysFromList:providedLocations]];
            
            // Compund user provided and cached parents to calculate resulting set of parent
            // data synchronization feeds.
            NSSet *parents = [objectLocationsParent setByAddingObjectsFromSet:providedLocationsParent];
            
            // Calculated target synchronization data feeds on which client should re-subscribe.
            targetParents = [NSSet setWithArray:[NSDictionary pn_topLevelKeysFromList:[parents allObjects]]];
        }
        else {
            
            // Fetch all locations which is used to synchronize local object with object from
            // PubNub cloud.
            NSMutableSet *objectLocations = [[objectData valueForKey:PNObjectData.paths.parent] mutableCopy];
            [objectLocations unionSet:[objectData valueForKey:PNObjectData.paths.children]];
            
            // Removing locations on which client should stop synchronization
            [objectLocations minusSet:[NSSet setWithArray:providedLocations]];
            
            // Calculated target synchronization data feeds on which client should re-subscribe.
            targetParents = [NSSet setWithArray:[NSDictionary pn_topLevelKeysFromList:[objectLocations allObjects]]];
        }
        
        // Removing target parents to calculate child data synchronization feeds from which
        // client should unsubscribe.
        [objectLocationsParent minusSet:targetParents];
        
        parentDataFeeds = [PNSynchronizationChannel channelsForObject:objectInformation.identifier
                                                      dataAtLocations:[targetParents allObjects]];
        if ([objectLocationsParent count]) {
            
            childDataFeeds = [PNSynchronizationChannel channelsForObject:objectInformation.identifier
                                                         dataAtLocations:[objectLocationsParent allObjects]
                                                    includingTransaction:NO];
        }
        
        processingCompletionBlock(parentDataFeeds, childDataFeeds);
    }
    // Looks like manager not sycnhronized with any remote object yet.
    else {
        
        if (isForSynchronization) {
        
            NSArray *validLocations = [NSDictionary pn_topLevelKeysFromList:objectInformation.dataLocations];
            processingCompletionBlock([PNSynchronizationChannel channelsForObject:objectInformation.identifier
                                                                  dataAtLocations:validLocations], nil);
        }
        else {
            
            processingCompletionBlock(nil, nil);
        }
    }
}

- (void)prepareForSynchronizationOf:(PNObjectInformation *)objectInformation
                          withBlock:(void (^)(NSArray *relevantDataFeedObjects,
                                              NSArray *irrelevantDataFeedObjects))completionBlock {
    
    [self prepareForSynchronization:objectInformation forSynchronizationStart:YES
                          withBlock:completionBlock];
}

- (void)prepareForSynchronizationStopFor:(PNObjectInformation *)objectInformation
                               withBlock:(void (^)(NSArray *relevantDataFeedObjects,
                                                   NSArray *irrelevantDataFeedObjects))completionBlock {
    
    [self prepareForSynchronization:objectInformation forSynchronizationStart:NO
                          withBlock:completionBlock];
}

- (void)prepareForSynchronization:(PNObjectInformation *)objectInformation
          forSynchronizationStart:(BOOL)isForSynchronization
                        withBlock:(void (^)(NSArray *relevantDataFeedObjects,
                                            NSArray *irrelevantDataFeedObjects))completionBlock {
    
    [self pn_dispatchBlock:^{
        
        [self synchronizationDataFeedChannelsFor:objectInformation
                         forSynchronizationStart:isForSynchronization
                             withCompletionBlock:^(NSArray *calculatedRelevantDataFeedObjects,
                                                   NSArray *calculatedIrrelevantDataFeedObjects) {
                                 
             calculatedRelevantDataFeedObjects = (calculatedRelevantDataFeedObjects ? calculatedRelevantDataFeedObjects : @[]);
             calculatedIrrelevantDataFeedObjects = (calculatedIrrelevantDataFeedObjects ? calculatedIrrelevantDataFeedObjects : @[]);
             PNDataSynchronizationTask *task = nil;
             if (isForSynchronization) {
                 
                 task = [PNDataSynchronizationTask synchronizationStartTaskFor:objectInformation
                                                   withRelevantDataFeedObjects:calculatedRelevantDataFeedObjects
                                                  andIrrelevantDataFeedObjects:calculatedIrrelevantDataFeedObjects];
             }
             else {
                 
                 task = [PNDataSynchronizationTask synchronizationStopTaskFor:objectInformation
                                                  withRelevantDataFeedObjects:calculatedRelevantDataFeedObjects
                                                 andIrrelevantDataFeedObjects:calculatedIrrelevantDataFeedObjects];
             }
                                 
             NSMutableDictionary *objectData = [self.objects valueForKey:objectInformation.identifier];
             if (!objectData) {
                 
                 objectData = [NSMutableDictionary dictionary];
                 [self.objects setValue:objectData forKey:objectInformation.identifier];
             }
             else {
                 
                 // Retrieve reference on local copy of remote object
                 PNObject *object = [objectData valueForKey:PNObjectData.object];
                 
                 // Invalidate object which will allow user to know that there is no valid
                 // data in local cache anymore.
                 [object invalidate];
                 
                 // Clear cached object data. From this moment, ant referent on this object will
                 // contain invalid/outdated state.
                 [objectData removeObjectForKey:PNObjectData.data];
             }
                                 
                 
             [objectData setValue:task forKey:PNObjectData.synchronizationTask];
             completionBlock(calculatedRelevantDataFeedObjects, calculatedIrrelevantDataFeedObjects);
         }];
    }];
}

- (void)prepareForDataFetchFor:(NSString *)objectIdentifier withBlock:(dispatch_block_t)completionBlock {
    
    [self pn_dispatchBlock:^{
    
        NSMutableDictionary *objectData = [self.objects valueForKey:objectIdentifier];
        if (!objectData) {
            
            [self.objects setValue:[NSMutableDictionary dictionary] forKey:objectIdentifier];
        }

        completionBlock();
    }];
}

- (void)hasActiveSynchronizationTasks:(void (^)(BOOL hasActiveTask))checkCompletionBlock {
    
    [self pn_dispatchBlock:^{
        
        __block BOOL hasActiveSynchronizationTasks = NO;
        [self.objects enumerateKeysAndObjectsUsingBlock:^(NSString *objectIdentifier,
                                                          NSMutableDictionary *objectData,
                                                          BOOL *objectsEnumeratorStop) {
            
            hasActiveSynchronizationTasks = ([objectData valueForKey:PNObjectData.synchronizationTask] != nil);
            *objectsEnumeratorStop = hasActiveSynchronizationTasks;
        }];
        
        checkCompletionBlock(hasActiveSynchronizationTasks);
    }];
}

- (void)hasActiveSynchronizationTaskFor:(NSString *)objectIdentifier
                              withBlock:(void(^)(PNDataSynchronizationTask *task,
                                                 BOOL hasActiveTask,
                                                 BOOL isSynchronizationStart))completionBlock {
    
    [self pn_dispatchBlock:^{
        
        PNDataSynchronizationTask *activeTask = nil;
        BOOL hasActiveSynchronizationTask = NO;
        BOOL isTaskForSynchronizationStart = NO;
        if ([self.objects valueForKey:objectIdentifier]){
            
            NSMutableDictionary *objectData = [self.objects valueForKey:objectIdentifier];
            hasActiveSynchronizationTask = ([objectData valueForKey:PNObjectData.synchronizationTask] != nil);
            if (hasActiveSynchronizationTask) {
                
                PNDataSynchronizationTask *storedTask = (PNDataSynchronizationTask *)[objectData valueForKey:PNObjectData.synchronizationTask];
                activeTask = storedTask;
                isTaskForSynchronizationStart = ([storedTask lastStep] == PNDataSynchronizationTaskStartCompletedStep);
            }
        }
        
        completionBlock(activeTask, hasActiveSynchronizationTask, isTaskForSynchronizationStart);
    }];
}

- (void)handleSynchronizationOn:(NSArray *)synchronizationDataFeedObjects
                      withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock {
    
    [self handleSynchronization:YES onObjects:synchronizationDataFeedObjects
                      withBlock:completionBlock];
}

- (void)handleSynchronizationStopOn:(NSArray *)synchronizationDataFeedObjects
                          withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock {
    
    [self handleSynchronization:NO onObjects:synchronizationDataFeedObjects
                      withBlock:completionBlock];
}

- (void)handleSynchronization:(BOOL)isSynchronizationStart
                    onObjects:(NSArray *)synchronizationDataFeedObjects
                    withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock {
    
    [self pn_dispatchBlock:^{
        
        NSMutableArray *tasks = [NSMutableArray array];
        
        // Retrieve list of object identifiers for which client received data synchronization feeds,
        NSSet *objectIdentifiers = [NSSet setWithArray:[synchronizationDataFeedObjects valueForKey:@"identifier"]];
        
        [objectIdentifiers enumerateObjectsUsingBlock:^(NSString *objectIdentifier,
                                                        BOOL *objectIdentifierEnumeratorStop) {
            
            NSMutableDictionary *objectData = [self.objects valueForKey:objectIdentifier];
            if ([objectData valueForKey:PNObjectData.synchronizationTask]) {
                
                PNDataSynchronizationTask *task = [objectData valueForKey:PNObjectData.synchronizationTask];
                
                if (isSynchronizationStart) {
                    
                    [task commitStep:PNDataSynchronizationTaskSubscribeStep];
                    
                    // Per request, client doesn't generate unsubscribe error, so it may miss
                    // unsubscription event (error doesn't mean that unsubscription not
                    // completed)
                    [task commitStep:PNDataSynchronizationTaskUnsubscribeStep];
                }
                else {
                    
                    [task commitStep:PNDataSynchronizationTaskUnsubscribeStep];
                }
                
                [tasks addObject:task];
            }
        }];
        
        completionBlock(tasks);
    }];
}

- (void)handleSynchronizationError:(PNError *)error onObjects:(NSArray *)synchronizationDataFeedObjects
                         withBlock:(void (^)(NSArray *synchronizationTasks))completionBlock {
    
    [self pn_dispatchBlock:^{
        
        NSMutableArray *tasks = [NSMutableArray array];
        
        // Retrieve list of object identifiers for which client received unsubscription from
        // data synchronization feeds,
        NSSet *objectIdentifiers = [NSSet setWithArray:[synchronizationDataFeedObjects valueForKey:@"identifier"]];
        
        [objectIdentifiers enumerateObjectsUsingBlock:^(NSString *objectIdentifier,
                                                        BOOL *objectIdentifierEnumeratorStop) {
            
            NSMutableDictionary *objectData = [self.objects valueForKey:objectIdentifier];
            if ([objectData valueForKey:PNObjectData.synchronizationTask]) {
            
                PNDataSynchronizationTask *task = [objectData valueForKey:PNObjectData.synchronizationTask];
                [tasks addObject:task];
            }
        }];
        
        completionBlock(tasks);
    }];
}

- (void)hasActiveFetchFor:(NSString *)objectIdentifier
                witbBlock:(void (^)(PNObjectInformation *activeObjectInformation))completionBlock {
    
    [self pn_dispatchBlock:^{

        [self hasActiveSynchronizationTaskFor:objectIdentifier
                                    withBlock:^(PNDataSynchronizationTask *task,
                                            BOOL hasActiveTask, BOOL isSynchronizationStart) {

            if (hasActiveTask) {

                completionBlock(task.objectInformation);
            }
            else {

                completionBlock([[self.objects valueForKey:objectIdentifier] valueForKey:PNObjectData.activeFetch]);
            }
        }];
    }];
}

- (void)handleDataFetchCompletionFor:(PNObjectInformation *)objectInformation
                            andBlock:(void (^)(PNDataSynchronizationTask *task))completionBlock {
    
    [self pn_dispatchBlock:^{
        
        NSMutableDictionary *objectData = [self.objects valueForKey:objectInformation.identifier];
        PNDataSynchronizationTask *activeTask = nil;
        if (objectData) {
            
            activeTask = [objectData valueForKey:PNObjectData.synchronizationTask];
            if (activeTask) {
                
                NSString *fetchedLocation = (![objectInformation.dataLocations count] ? @"*" :
                                             [objectInformation.dataLocations lastObject]);
                [activeTask commitStep:PNDataSynchronizationTaskFetchStep];
                [activeTask commitDataLocation:fetchedLocation];
                
                if ([activeTask nextStep] == PNDataSynchronizationTaskStartCompletedStep ||
                    [activeTask nextStep] == PNDataSynchronizationTaskStopCompletedStep) {
                    
                    PNObject *cachedObject = [objectData valueForKey:PNObjectData.object];
                    id objectCache = nil;
                    if (!cachedObject) {

                        cachedObject = [PNObject objectWithIdentifier:activeTask.objectInformation.identifier];
                        [objectData setValue:cachedObject forKey:PNObjectData.object];
                    }

                    if (![objectInformation.dataLocations count]) {

                        if ([objectInformation.data isKindOfClass:[NSArray class]]) {

                            objectCache = [NSMutableArray array];
                        }
                        else {

                            objectCache = [NSMutableDictionary dictionary];
                        }
                    }
                    else {

                        NSArray *locationKeyPaths = [[objectInformation.dataLocations lastObject] componentsSeparatedByString:@"."];
                        if ([NSArray pn_isEntryIndexString:[locationKeyPaths objectAtIndex:0]]) {

                            objectCache = [NSMutableArray array];
                        }
                        else {

                            objectCache = [NSMutableDictionary dictionary];
                        }
                    }
                    @autoreleasepool {

                        [objectCache pn_mergeData:activeTask.objectInformation.data
                                               at:[objectInformation.dataLocations lastObject]];
                        [objectData setValue:objectCache forKey:PNObjectData.data];
                    }

                    NSMutableSet *storedRelevantFeeds = [objectData valueForKey:PNObjectData.paths.parent];
                    if (!storedRelevantFeeds)  {

                        storedRelevantFeeds = [NSMutableSet set];
                        [objectData setValue:storedRelevantFeeds forKey:PNObjectData.paths.parent];
                    }
                    NSMutableSet *storedIrrelevantFeeds = [objectData valueForKey:PNObjectData.paths.children];
                    if (!storedIrrelevantFeeds)  {

                        storedIrrelevantFeeds = [NSMutableSet set];
                        [objectData setValue:storedIrrelevantFeeds forKey:PNObjectData.paths.children];
                    }
                    NSArray *relevantFeeds = [PNSynchronizationChannel baseSynchronizationChannelsFromList:activeTask.relevantDataFeedObjects];
                    [relevantFeeds enumerateObjectsUsingBlock:^(PNSynchronizationChannel *dataObject,
                                                                NSUInteger dataObjectIdx,
                                                                BOOL *dataObjectEnumeratorStop) {

                        if ([dataObject.dataLocation length]) {

                            [storedRelevantFeeds addObject:dataObject.dataLocation];
                        }
                    }];
                    NSArray *irrelevantFeeds = [PNSynchronizationChannel baseSynchronizationChannelsFromList:activeTask.irrelevantDataFeedObjects];
                    [irrelevantFeeds enumerateObjectsUsingBlock:^(PNSynchronizationChannel *dataObject,
                                                                  NSUInteger dataObjectIdx,
                                                                  BOOL *dataObjectEnumeratorStop) {

                        if ([dataObject.dataLocation length]) {

                            [storedIrrelevantFeeds addObject:dataObject.dataLocation];
                        }
                    }];

                    cachedObject.data = objectCache;
                    cachedObject.valid = YES;
                    activeTask.objectInformation.object = cachedObject;
                    
                    [objectData removeObjectForKey:PNObjectData.synchronizationTask];

                    NSMutableDictionary *transactions = [objectData valueForKey:PNObjectData.transactions];
                    if ([transactions count]) {

                        __block NSUInteger transactionsForProcessing = [transactions count];
                        [transactions enumerateKeysAndObjectsUsingBlock:^(NSString *transactionIdentifier,
                                                                          NSMutableArray *transactionEvents,
                                                                          BOOL *transactionsEnumeratorStop) {

                            PNDataSynchronizationEvent *lastEvent = [transactionEvents lastObject];
                            if (lastEvent.type == PNDataTransactionCompleteEvent) {

                                [transactionEvents removeObject:lastEvent];
                                [self handleSynchronizationEvent:lastEvent
                                                       withBlock:^(PNObject *updatedObject,
                                                                   NSArray *locations,
                                                                   BOOL modificationCompleted) {

                                    if (--transactionsForProcessing == 0) {

                                        completionBlock(activeTask);

                                    }
                                }];
                            }
                            else {

                                transactionsForProcessing--;
                            }
                        }];
                    }
                    else {

                        completionBlock(activeTask);
                    }
                }
            }
            else {
                
                PNObjectInformation *storedObjectInformation = [objectData valueForKey:PNObjectData.activeFetch];
                if (!storedObjectInformation) {
                    
                    [objectData setValue:objectInformation forKey:PNObjectData.activeFetch];
                }

                completionBlock(activeTask);
            }
        }
        else {

            completionBlock(activeTask);
        }
    }];
}

- (void)handlePartialDataFetchCompletionFor:(PNObjectInformation *)objectInformation
                                   andBlock:(void (^)(PNDataSynchronizationTask *task))completionBlock {
    
    [self pn_dispatchBlock:^{

        NSMutableDictionary *objectData = [self.objects valueForKey:objectInformation.identifier];
        PNDataSynchronizationTask *activeTask = nil;
        if (objectData) {

            activeTask = [objectData valueForKey:PNObjectData.synchronizationTask];
            if (!activeTask) {

                PNObjectInformation *storedObjectInformation = [objectData valueForKey:PNObjectData.activeFetch];
                if (!storedObjectInformation) {

                    [objectData setValue:objectInformation forKey:PNObjectData.activeFetch];
                }
            }
        }

        completionBlock(activeTask);
    }];
}

- (void)handleDataFetchFor:(PNObjectInformation *)objectInformation failWithError:(PNError *)error
                  andBlock:(dispatch_block_t)completionBlock {
    
    [self pn_dispatchBlock:^{
        
        NSMutableDictionary *objectData = [self.objects valueForKey:objectInformation.identifier];
        if (objectData) {
            
            [objectData removeObjectForKey:PNObjectData.activeFetch];
        }
        else {
            
            completionBlock();
        }
    }];
}

- (void)handleSynchronizationEvent:(PNDataSynchronizationEvent *)event
                         withBlock:(void(^)(PNObject *object, NSArray *locations,
                                    BOOL modificationCompleted))completionBlock {

    [self pn_dispatchBlock:^{

        PNObject *cachedObject = nil;
        NSMutableSet *modifiedLocations = nil;

        // Try to fetch reference on local copy of remote object.
        NSMutableDictionary *objectData = [self.objects valueForKey:event.objectIdentifier];
        NSMutableDictionary *transactions = [objectData valueForKey:PNObjectData.transactions];

        // To handle synchronization events, client at least once should try to access remote object
        if (objectData) {

            // Looks like bulk change completed and data should be merged with local copy.
            if (event.type == PNDataTransactionCompleteEvent) {

                NSMutableArray *transactionEvents = [transactions valueForKey:event.moidificationTransactionIdentifier];

                // Fetch reference on object on which modifications will be applied
                cachedObject = [objectData valueForKey:PNObjectData.object];
                if ([cachedObject isValid]) {

                    modifiedLocations = [NSMutableSet set];
                    if ([transactionEvents count]) {

                        __block id objectCache = [objectData valueForKey:PNObjectData.data];
                        __block BOOL shouldCreateCache = (objectCache == nil);

                        // Sorting events from older-to-newer before applying
                        NSArray *arraySortingDescriptor = @[[[NSSortDescriptor alloc] initWithKey:@"modificationTimeToken" ascending:YES]];
                        [transactionEvents sortUsingDescriptors:arraySortingDescriptor];

                        [transactionEvents enumerateObjectsUsingBlock:^(PNDataSynchronizationEvent *storedEvent,
                                                                        NSUInteger storedEventIdx,
                                                                        BOOL *storedEventEnumeratorStop) {

                            if (shouldCreateCache) {

                                NSArray *locationKeyPaths = [storedEvent.modificationLocation componentsSeparatedByString:@"."];
                                if ([NSArray pn_isEntryIndexString:[locationKeyPaths objectAtIndex:0]]) {

                                    objectCache = [NSMutableArray array];
                                }
                                else {

                                    objectCache = [NSMutableDictionary dictionary];
                                }

                                [objectData setValue:objectCache forKey:PNObjectData.data];
                                shouldCreateCache = NO;
                            }

                            @autoreleasepool {

                                if (storedEvent.type == PNDataUpdateEvent) {

                                    [objectCache pn_mergeData:storedEvent.data at:storedEvent.modificationLocation];
                                }
                                else if (storedEvent.type == PNDataReplaceEvent) {

                                    [objectCache pn_removeRemoteObjectDataAtPath:storedEvent.modificationLocation];
                                    [objectCache pn_mergeData:storedEvent.data at:storedEvent.modificationLocation];
                                }
                                else if (storedEvent.type == PNDataDeleteEvent) {

                                    [objectCache pn_removeRemoteObjectDataAtPath:storedEvent.modificationLocation];
                                }
                            }

                            [modifiedLocations addObject:storedEvent.relativeLocation];
                        }];
                        cachedObject.valid = YES;
                    }
                    [transactions removeObjectForKey:event.moidificationTransactionIdentifier];
                }
                else {

                    [transactionEvents addObject:event];
                }
            }
            // Keep provided information in temporary storage.
            else {

                if (!transactions) {

                    transactions = [NSMutableDictionary dictionary];
                    [objectData setValue:transactions forKey:PNObjectData.transactions];
                }
                NSMutableArray *transactionEvents = [transactions valueForKey:event.moidificationTransactionIdentifier];
                if (!transactionEvents) {
                    
                    transactionEvents = [NSMutableArray array];
                    [transactions setValue:transactionEvents forKey:event.moidificationTransactionIdentifier];
                }
                [transactionEvents addObject:event];
            }
        }

        completionBlock(cachedObject, [modifiedLocations allObjects], (event.type == PNDataTransactionCompleteEvent));
    }];
}


#pragma mark - Misc

- (void)purgeLocalCache {
    
    [self pn_dispatchBlock:^{
        
        [self.objects removeAllObjects];
    }];
}

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];
}

#pragma mark -


@end
