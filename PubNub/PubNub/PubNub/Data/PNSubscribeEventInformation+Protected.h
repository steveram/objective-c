/**
 @author Sergey Mamontov
 @version 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNSubscribeEventInformation.h"


#pragma mark Structures

/**
 @brief  Describes overall real-time event format.
 */
struct PNEventDebugEnvelopeStructure {

    /**
     @brief  Stores reference key under which stored shard identifier on which event has been stored.
     */
    __unsafe_unretained NSString *shardIdentifier;

    /**
     @brief  Stores reference key under which stored numeric representation of enabled debug flags.
     */
    __unsafe_unretained NSString *debugFlags;

    /**
     @brief  Stores reference on key under which stored identifier of client which sent message
             (set only for publish).
     */
    __unsafe_unretained NSString *senderIdentifier;

    /**
     @Brief  Stores reference on key under which stored sequence nubmer of published messages
             (clients keep track of their own value locally).
     */
    __unsafe_unretained NSString *sequenceNumber;

    /**
     @brief  Stores reference on key under which stored application's subscribe key.
     */
    __unsafe_unretained NSString *subscribeKey;

    /**
     @brief  Stores reference on key under which stored numeric representation of event replication
             map (region based).
     */
    __unsafe_unretained NSString *replicationMap;

    /**
     @brief  Stores reference on key under which stored boolean flag which tell whether message
             should be stored in memory or removed after delivering.
     */
    __unsafe_unretained NSString *eatAfterReading;

    /**
     @brief  Stores reference on key under which stored user-provided (during publish) meta-data
             which will be taken into account by filtering algorithms.
     */
    __unsafe_unretained NSString *meta;

    /**
     @brief  Stores reference on key under which stored information about waypoints.
     */
    __unsafe_unretained NSString *waypoints;
};

extern struct PNEventDebugEnvelopeStructure PNDebugEventEnvelope;


#pragma mark Private interface declaration

@interface PNSubscribeEventInformation ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *shardIdentifier;
@property (nonatomic, copy) NSNumber *debugFlags;
@property (nonatomic, copy) NSString *senderIdentifier;
@property (nonatomic, copy) NSNumber *sequenceNumber;
@property (nonatomic, copy) NSString *subscribeKey;
@property (nonatomic, copy) NSNumber *replicationMap;
@property (nonatomic, copy) NSNumber *eatAfterReading;
@property (nonatomic, copy) NSDictionary *meta;
@property (nonatomic, copy) NSArray *waypoints;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize real-time event debug information instance.

 @param payload  Event envelop dictionary which contain even delivery debug information.

 @return Initialized and ready to use subscribe event information instance.

 @since 3.8.0
 */
- (instancetype)initWithPayload:(NSDictionary *)payload;

#pragma mark -


@end
