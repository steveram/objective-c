//
//  PNSubscribeRequest+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#import "PNSubscribeRequest.h"


#pragma mark Class forward

@class PNTimeToken;


#pragma mark - Private interface declaration

@interface PNSubscribeRequest ()


#pragma mark - Properties

// Stores reference on list of channels for which presence should be enabled/disabled
@property (nonatomic, strong) NSArray *channelsForPresenceEnabling;
@property (nonatomic, strong) NSArray *channelsForPresenceDisabling;

// Stores recent channels/presence state update time (token)
@property (nonatomic, strong) PNTimeToken *updateTimeToken;

/**
 @brief  Stores reference on user-provided message filtering expression.
 
 @since 3.8.0
 */
@property (nonatomic, copy) NSString *filteringExpression;

/**
 Stores user-provided state which should be appended to the client subscription.
 */
@property (nonatomic, copy) NSDictionary *state;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, assign) NSInteger presenceHeartbeatTimeout;
@property (nonatomic, copy) NSString *subscriptionKey;

@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, assign, getter = isPerformingMultipleActions) BOOL performingMultipleActions;


#pragma mark - Instance methods

/**
 Retrieve list of channels on which subscribe should subscribe or update timetoken (w/o presence channels).
 
 @return \b PNChannels list
 */
- (NSArray *)channelsForSubscription;

- (void)resetSubscriptionTimeToken;

/**
 * Allow to reset time token on each of channel which should be used for subscription
 */
- (void)resetTimeToken;
- (void)resetTimeTokenTo:(PNTimeToken *)timeToken;

#pragma mark -


@end
