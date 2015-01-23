#import <Foundation/Foundation.h>


#pragma mark Types & Structures

/**
 This enumerator represents available synchronization steps
 */
typedef NS_OPTIONS(NSInteger , PNDataSynchronizationTaskStep) {
    
    /**
     @brief Step which is used if \b PubNub client will try to request next step in case if all 
            of them already has been completed.
     
     @since <#version number#>
     */
    PNDataSynchronizationTaskUnknownStep = -1,
    
    /**
     @brief Task which requires from \b PubNub client subscription on relevan data feed objects.
     
     @since <#version number#>
     */
    PNDataSynchronizationTaskUnsubscribeStep,
    
    /**
     @brief Task which requires from \b PubNub client unsubscribe from irrelevan data feed 
            objects.
     
     @since <#version number#>
     */
    PNDataSynchronizationTaskSubscribeStep,
    
    /**
     @brief Task which requires from \b PubNub client fetch remote object data for one of data
            location key-paths.
     
     @since <#version number#>
     */
    PNDataSynchronizationTaskFetchStep,
    
    /**
     @brief Task which requires from \b PubNub client notify about successful synchronization 
            start task completion.
     
     @since <#version number#>
     */
    PNDataSynchronizationTaskStartCompletedStep,
    
    /**
     @brief Task which requires from \b PubNub client notify about successful synchronization 
            stop task completion.
     
     @since <#version number#>
     */
    PNDataSynchronizationTaskStopCompletedStep
};

#pragma mark - Class forward

@class PNObjectInformation;


/**
 @brief      Class allow to describe concrete syncrhonization task.
 
 @discussion Depending on current data synchronization manager it may request from \b PubNub 
             client unsubscribe from set of data feed objects before continue subscription with
             further data fetch.
 
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
@interface PNDataSynchronizationTask : NSObject


#pragma mark - Properties

/**
 @brief Stores reference on instance which temporary represent remote object from \b PubNub cloud
        for which this synchronization event has been created.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) PNObjectInformation *objectInformation;


/**
 @brief Represent list of channels which will receive required synchronization events after
        \b PubNub client will unsubscribe from old data feed objects.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) NSArray *relevantDataFeedObjects;

/**
 @brief Old channels which doesn't represent actual interests of the client in synchronization
        events.
 
 @since <#version number#>
 */
@property (nonatomic, readonly, strong) NSArray *irrelevantDataFeedObjects;


#pragma mark - Class methods

/**
 @brief      Create task which is configured for synchronization start.
 
 @discussion Client may request synchronization start for new remote data object or use new data
             location on existing object to fetch.
 
 @param objectInformation         Reference on instance which temporary represent remote data
                                  object before it's synchronization will be completed.
 @param relevantDataFeedObjects   List of data synchronization feed objects on which client 
                                  should subscribe to complete two staged task.
 @param irrelevantDataFeedObjects List of data synchronization feed objects from which client
                                  should unsubscribe first before proceed to new step.
 
 @return Reference on constructed and ready to use task.
 
 @since <#version number#>
 */
+ (instancetype)synchronizationStartTaskFor:(PNObjectInformation *)objectInformation
                withRelevantDataFeedObjects:(NSArray *)relevantDataFeedObjects
               andIrrelevantDataFeedObjects:(NSArray *)irrelevantDataFeedObjects;

/**
 @brief      Create task which is configured for synchronization termination.
 
 @discussion During synchronization termination on particular data path or whole data object 
             client may require to unsubscribe from some data objects and subscribe to another
             one.
 
 @param objectInformation         Reference on instance which temporary represent remote data
                                  object before it's synchronization will be completed.
 @param relevantDataFeedObjects   List of data synchronization feed objects on which client 
                                  should subscribe to complete two staged task.
 @param irrelevantDataFeedObjects List of data synchronization feed objects from which client
                                  should unsubscribe first before proceed to new step.
 
 @return Reference on constructed and ready to use task.
 
 @since <#version number#>
 */
+ (instancetype)synchronizationStopTaskFor:(PNObjectInformation *)objectInformation
               withRelevantDataFeedObjects:(NSArray *)relevantDataFeedObjects
              andIrrelevantDataFeedObjects:(NSArray *)irrelevantDataFeedObjects;


#pragma mark - Instance methods

/**
 @brief Request next synchronization task step which should be performed by \b PubNub client.
 
 @return One of \a PNDataSynchronizationTaskStep type fields which represent further actions
         which should be performed by \b PubNub client.
 
 @since <#version number#>
 */
- (PNDataSynchronizationTaskStep)nextStep;

/**
 @brief Request information about last step which should be done to complete synchronization 
        process.
 
 @return One of \a PNDataSynchronizationTaskStep type fields which represent further actions
         which should be performed by \b PubNub client.
 
 @since <#version number#>
 */
- (PNDataSynchronizationTaskStep)lastStep;

/**
 @brief Commit as completed one of synchronization steps
 
 @param step Synchronization step which should be commited as 'done'.
 
 @since <#version number#>
 */
- (void)commitStep:(PNDataSynchronizationTaskStep)step;

/**
 @brief Request next data location key-path which \b PubNub client should fetch on
        \c PNDataSynchronizationTaskFetchStep step.
 
 @return Data location key-path which should be fecthed from \b PubNub cloud to complete 
         synchronization process.
 
 @since <#version number#>
 */
- (NSString *)nextDataLocation;

/**
 @brief Commit as fetched one of data location key-paths.
 
 @param location Reference on key-path which should be marked as fetched.
 
 @since <#version number#>
 */
- (void)commitDataLocation:(NSString *)location;

#pragma mark -


@end
