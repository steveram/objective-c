/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-13 PubNub Inc.
 */
#import "PNChannelEventsResponseParser.h"
#import "PNChannelEvents+Protected.h"


#pragma mark Structures

/**
 @brief  Describe structure with keys under which sotred information about when event has been
         triggered and in which region (to which region client subscribed at this moment).
 */
struct PNEventTimeTokenStructure {

    /**
     @brief  Stores reference on key under which stored high precision time token (on linuxtimestamp
             in case of presence events) on when event has been triggered.
     */
    __unsafe_unretained NSString *timeToken;

    /**
     @brief  Stores reference on key under which stored numeric region identier.
     */
    __unsafe_unretained NSString *region;
};

extern struct PNEventTimeTokenStructure PNEventTimeToken;


/**
 @brief  Describes overall real-time event format.
 */
struct PNEventEnvelopeStructure {

    /**
     @brief  Describes structure to represent local time token (unixtimestamp casted to high
             precision).
     */
    struct {

        /**
         @brief  Stores reference on key under which sender time token information is stored.
         */
        __unsafe_unretained NSString *key;

        /**
         @brief  Describes time token information.
         */
        struct PNEventTimeTokenStructure token;
    } senderTimeToken;

    /**
     @brief  Describes structure to represent represent time when message has been received by
             \b PubNub service and passed to subscribers.
     */
    struct {

        /**
         @brief  Stores reference on key under which publish time token information is stored.
         */
        __unsafe_unretained NSString *key;

        /**
         @brief  Describes time token information.
         */
        struct PNEventTimeTokenStructure token;
    } publishTimeToken;

    /**
     @brief  Stores reference on key under which actual channel name on which event has been
             triggered.
     */
    __unsafe_unretained NSString *actualChannel;

    /**
     @brief  Stores reference on key under which stored name of the object on which client
             subscribed at this moment (can be: \c channel, \c group or \c wildcard).
     */
    __unsafe_unretained NSString *subscribedChannel;

    /**
     @brief  Stores reference on key under which stored event object data (can be user message for
             publish message or presence dictionary with information about event).
     */
    __unsafe_unretained NSString *payload;

    struct {

        /**
         @brief  Stores reference on key under which stored information about presence event type.
         */
        __unsafe_unretained NSString *action;

        /**
         @brief  Stores reference on key under which stores information about client state on
                 channel which triggered presence event.
         */
        __unsafe_unretained NSString *data;

        /**
         @brief  Stores reference on key under which stored information about occupancy in channel
                 which triggered event.
         */
        __unsafe_unretained NSString *occupancy;

        /**
         @brief  Stores reference on key under which stored event triggering time token
                 (unixtimestamp).
         */
        __unsafe_unretained NSString *timestamp;

        /**
         @brief  Stores reference on unique client identifier which caused presence event
                 triggering.
         */
        __unsafe_unretained NSString *uuid;
    } presence;
};

extern struct PNEventEnvelopeStructure PNEventEnvelope;


#pragma mark - Private interface methods

@interface PNChannelEventsResponseParser ()


#pragma mark - Properties

/**
 Stores reference on even data object which holds all information about events.
 */
@property (nonatomic, strong) PNChannelEvents *events;

#pragma mark -


@end
