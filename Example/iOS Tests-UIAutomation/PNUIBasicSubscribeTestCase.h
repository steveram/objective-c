//
//  PNUIBasicSubscribeTestCase.h
//  PubNub
//
//  Created by Jordan Zucker on 8/27/15.
//  Copyright (c) 2015 Jordan Zucker. All rights reserved.
//

#import "PNUIBasicClientTestCase.h"

typedef void (^PNClientDidReceiveMessageAssertions)(PubNub *client, PNMessageResult *message);
typedef void (^PNClientDidReceivePresenceEventAssertions)(PubNub *client, PNPresenceEventResult *event);
typedef void (^PNClientDidReceiveStatusAssertions)(PubNub *client, PNSubscribeStatus *status);

@class XCTestExpectation;

@interface PNUIBasicSubscribeTestCase : PNUIBasicClientTestCase

@property (nonatomic) XCTestExpectation *subscribeExpectation;
@property (nonatomic) XCTestExpectation *unsubscribeExpectation;
@property (nonatomic) XCTestExpectation *channelGroupSubscribeExpectation;
@property (nonatomic) XCTestExpectation *channelGroupUnsubscribeExpectation;

@property (nonatomic, copy) PNClientDidReceiveMessageAssertions didReceiveMessageAssertions;
@property (nonatomic, copy) PNClientDidReceivePresenceEventAssertions didReceivePresenceEventAssertions;
@property (nonatomic, copy) PNClientDidReceiveStatusAssertions didReceiveStatusAssertions;

- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_subscribeToPresenceChannels:(NSArray *)channels;

- (void)PNTest_unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_unsubscribeFromPresenceChannels:(NSArray *)channels;

- (void)PNTest_subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;

@end
