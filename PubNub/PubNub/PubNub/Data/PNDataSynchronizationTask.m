/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNDataSynchronizationTask.h"
#import "PNSynchronizationChannel+Protected.h"
#import "PNObjectInformation.h"


#pragma mark Private interface declaration

@interface PNDataSynchronizationTask ()


#pragma mark - Properties

@property (nonatomic, strong) PNObjectInformation *objectInformation;
@property (nonatomic, strong) NSArray *relevantDataFeedObjects;
@property (nonatomic, strong) NSArray *irrelevantDataFeedObjects;

/**
 @brief Reference on list of data location key-paths for which \b PubNub client should fetch data
        from \b PubNub cloud.
 
 @since <#version number#>
 */
@property (nonatomic, strong) NSMutableArray *dataLocations;

/**
 @brief Stores list of steps which should be done to complete synchronization process.
 
 @since <#version number#>
 */
@property (nonatomic, strong) NSMutableArray *steps;


#pragma mark - Instance methods

/**
 @brief      Create task which is configured for synchronization start/termination.
 
 @param synchronizationStart      Whether synchronization task created for synchronization start
                                  or termination process.
 @param objectInformation         Reference on instance which temporary represent remote data
                                  object before it's synchronization will be completed.
 @param relevantDataFeedObjects   List of data synchronization feed objects on which client 
                                  should subscribe to complete two staged task.
 @param irrelevantDataFeedObjects List of data synchronization feed objects from which client
                                  should unsubscribe first before proceed to new step.
 
 @return Reference on constructed and ready to use task.
 
 @since <#version number#>
 */
- (instancetype)initSynchronizationTask:(BOOL)synchronizationStart
                              forObject:(PNObjectInformation *)objectInformation
            withRelevantDataFeedObjects:(NSArray *)relevantDataFeedObjects
           andIrrelevantDataFeedObjects:(NSArray *)irrelevantDataFeedObjects;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNDataSynchronizationTask


#pragma mark - Class methods

+ (instancetype)synchronizationStartTaskFor:(PNObjectInformation *)objectInformation
                withRelevantDataFeedObjects:(NSArray *)relevantDataFeedObjects
               andIrrelevantDataFeedObjects:(NSArray *)irrelevantDataFeedObjects {
    
    return [[self alloc] initSynchronizationTask:YES forObject:objectInformation
                     withRelevantDataFeedObjects:relevantDataFeedObjects
                    andIrrelevantDataFeedObjects:irrelevantDataFeedObjects];
}

+ (instancetype)synchronizationStopTaskFor:(PNObjectInformation *)objectInformation
               withRelevantDataFeedObjects:(NSArray *)relevantDataFeedObjects
              andIrrelevantDataFeedObjects:(NSArray *)irrelevantDataFeedObjects {
    
    return [[self alloc] initSynchronizationTask:NO forObject:objectInformation
                     withRelevantDataFeedObjects:relevantDataFeedObjects
                    andIrrelevantDataFeedObjects:irrelevantDataFeedObjects];
}


#pragma mark - Instance methods

- (instancetype)initSynchronizationTask:(BOOL)synchronizationStart
                              forObject:(PNObjectInformation *)objectInformation
            withRelevantDataFeedObjects:(NSArray *)relevantDataFeedObjects
           andIrrelevantDataFeedObjects:(NSArray *)irrelevantDataFeedObjects {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.steps = [NSMutableArray array];
        self.dataLocations = [NSMutableArray array];
        self.objectInformation = objectInformation;
        self.relevantDataFeedObjects = [relevantDataFeedObjects copy];
        self.irrelevantDataFeedObjects = [irrelevantDataFeedObjects copy];
        
        if ([self.irrelevantDataFeedObjects count]) {
            
            [self.steps addObject:@(PNDataSynchronizationTaskUnsubscribeStep)];
        }
        
        if ([self.relevantDataFeedObjects count]) {
            
            [self.steps addObject:@(PNDataSynchronizationTaskSubscribeStep)];
            
            NSArray *uniqueFeeds = [PNSynchronizationChannel baseSynchronizationChannelsFromList:self.relevantDataFeedObjects];
            void(^storeDataLocationKeyPath)(NSString *dataLocation) = ^(NSString *dataLocation) {

                [self.steps addObject:@(PNDataSynchronizationTaskFetchStep)];
                [self.dataLocations addObject:(dataLocation ? dataLocation : @"*")];
            };
            if ([uniqueFeeds count]) {

                [uniqueFeeds enumerateObjectsUsingBlock:^(PNSynchronizationChannel *dataObject,
                                                          NSUInteger dataObjectIdx,
                                                          BOOL *dataObjectEnumeratorStop) {

                    storeDataLocationKeyPath(dataObject.dataLocation);
                }];
            }
            else {

                storeDataLocationKeyPath(nil);
            }
        }
        
        if (synchronizationStart) {
            
            [self.steps addObject:@(PNDataSynchronizationTaskStartCompletedStep)];
        }
        else {
            
            [self.steps addObject:@(PNDataSynchronizationTaskStopCompletedStep)];
        }
    }
    
    
    return self;
}

- (PNDataSynchronizationTaskStep)nextStep {
    
    PNDataSynchronizationTaskStep step = PNDataSynchronizationTaskUnknownStep;
    if ([self.steps count]) {
        
        step = (PNDataSynchronizationTaskStep)[[self.steps objectAtIndex:0] integerValue];
    }
    
    
    return step;
}

- (PNDataSynchronizationTaskStep)lastStep {
    
    PNDataSynchronizationTaskStep step = PNDataSynchronizationTaskUnknownStep;
    if ([self.steps count]) {
        
        step = (PNDataSynchronizationTaskStep)[[self.steps lastObject] integerValue];
    }
    
    
    return step;
}

- (void)commitStep:(PNDataSynchronizationTaskStep)step {
    
    NSUInteger targetStepIndex = [self.steps indexOfObject:@(step)];
    if (targetStepIndex != NSNotFound) {
        
        [self.steps removeObjectAtIndex:targetStepIndex];
    }
}

- (NSString *)nextDataLocation {
    
    NSString *dataLocation = nil;
    if ([self nextStep] == PNDataSynchronizationTaskFetchStep && [self.dataLocations count]) {
        
        dataLocation = [self.dataLocations objectAtIndex:0];
    }
    
    
    return dataLocation;
}

- (void)commitDataLocation:(NSString *)location {
    
    NSUInteger targetLocation = [self.dataLocations indexOfObject:location];
    if (targetLocation != NSNotFound) {
        
        [self.dataLocations removeObjectAtIndex:targetLocation];
    }
}

#pragma mark -


@end
