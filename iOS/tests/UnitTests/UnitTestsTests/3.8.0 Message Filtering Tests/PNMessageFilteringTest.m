//
//  PNMessageFilteringTest.m
//  UnitTests
//
//  Created by Sergey Mamontov on 1/6/16.
//  Copyright © 2016 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PNMessageFilteringTest : XCTestCase <PNDelegate>

@property (nonatomic) PubNub *client;
@property (nonatomic) PNChannel *channel;

@property (nonatomic, copy) NSString *filterExpression;
@property (nonatomic, copy) NSDictionary *userMetadata;
@property (nonatomic, assign, getter = isMessageExpected) BOOL expectingMessage;
@property (nonatomic) XCTestExpectation *filterExpectation;

@end


@implementation PNMessageFilteringTest

- (void)setUp {
    
    [super setUp];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"msgfiltering-dev.pubnub.com"
                                                                  publishKey:@"demo-36" subscribeKey:@"demo-36" secretKey:@"demo-36"];
    self.client = [PubNub clientWithConfiguration:configuration andDelegate:self];
    self.channel = [PNChannel channelWithName:[[NSUUID UUID] UUIDString]];
    XCTestExpectation *connectionExpectation = [self expectationWithDescription:@"connectionExpectation"];
    [self.client connectWithSuccessBlock:^(NSString *origin) {
        
        [self.client subscribeOn:@[self.channel] 
     withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
            
            if (state == PNSubscriptionProcessSubscribedState) { [connectionExpectation fulfill]; }
            else { XCTFail(@"Subscription failed with error: %@", error); }
        }];
    } errorBlock:^(PNError *error) { XCTAssertNil(error, @"Connection error."); }];
    [self waitForExpectationsWithTimeout:10.0f handler:^(NSError * _Nullable error) {
        
        XCTAssertNil(error, @"Connection timeout.");
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.client disconnect];
    self.client = nil;
}

- (void)testExactNumerMatch {
    
    [self publishMessage:@"message_1" withFilteringExpression:@"count == 42" userMetadata:@{@"count": @42} 
         messageExpected:YES];
}

- (void)testArithmeticResult1Match {
    
    [self publishMessage:@"message_2" withFilteringExpression:@"attributes.var1 + attributes['var2'] == 30"
            userMetadata:@{@"attributes": @{@"var1": @10, @"var2": @20}} messageExpected:YES];
}

- (void)testArithmeticResult2Match {
    
    [self publishMessage:@"message_3" withFilteringExpression:@"meta.data.var1 + data['var2'] == 30"
            userMetadata:@{@"data": @{@"var1": @10, @"var2": @20}} messageExpected:YES];
}

- (void)testArithmeticResultMismatch {
    
    [self publishMessage:@"message_4" withFilteringExpression:@"meta.data.var1 + data['var2'] == 21"
            userMetadata:@{@"data": @{@"var1": @11, @"var2": @20}} messageExpected:NO];
}

- (void)testLargerThanOrEqualMatch {
    
    [self publishMessage:@"message_5" withFilteringExpression:@"regions.east.count >= 42"
            userMetadata:@{@"regions": @{@"east": @{@"count": @42, @"other": @"something"}}} messageExpected:YES];
}

- (void)testSmallerThanMismatch {
    
    [self publishMessage:@"message_6" withFilteringExpression:@"regions.east.count < 42"
            userMetadata:@{@"regions": @{@"east": @{@"count": @42, @"other": @"something"}}} messageExpected:NO];
}

- (void)testLargerThanMissingVariableMismatch {
    
    [self publishMessage:@"message_7" withFilteringExpression:@"regions.east.volume > 0"
            userMetadata:@{@"regions": @{@"east": @{@"count": @42, @"other": @"something"}}} messageExpected:NO];
}

- (void)testExactStringMatch {
    
    [self publishMessage:@"message_8" withFilteringExpression:@"region==\"east\"" userMetadata:@{@"region": @"east"} 
         messageExpected:YES];
}

- (void)testStringCaseMismatch {
    
    [self publishMessage:@"message_9" withFilteringExpression:@"region==\"East\"" userMetadata:@{@"region": @"east"} 
         messageExpected:NO];
}

- (void)testStringAgainstList1Match {
    
    [self publishMessage:@"message_10" withFilteringExpression:@"region in (\"east\",\"west\")" 
            userMetadata:@{@"region": @"east"} messageExpected:YES];
}

- (void)testStringAgainstList2Match {
    
    [self publishMessage:@"message_11" withFilteringExpression:@"\"east\" in regions" 
            userMetadata:@{@"regions": @[@"east", @"west"]} messageExpected:YES];
}

- (void)testNegatedStringAgainstListMatch {
    
    [self publishMessage:@"message_12" withFilteringExpression:@"!(\"central\" in regions)" 
            userMetadata:@{@"regions": @[@"east", @"west"]} messageExpected:YES];
}

- (void)testStringCaseAgainstListMismatch {
    
    [self publishMessage:@"message_13" withFilteringExpression:@"\"East\" in regions" 
            userMetadata:@{@"regions": @[@"east", @"west"]} messageExpected:NO];
}

- (void)testLikeListAgainstStringMatch {
    
    [self publishMessage:@"message_14" withFilteringExpression:@"regions like \"EAST\"" 
            userMetadata:@{@"regions": @[@"east", @"west"]} messageExpected:YES];
}

- (void)testLikeListAgainstStringWithWildcard1Match {
    
    [self publishMessage:@"message_15" withFilteringExpression:@"regions like \"EAST%\"" 
            userMetadata:@{@"regions": @[@"east", @"west"]} messageExpected:YES];
}

- (void)testLikeListAgainstStringWithWildcard2Match {
    
    [self publishMessage:@"message_16" withFilteringExpression:@"regions like \"EAST%\"" 
            userMetadata:@{@"regions": @[@"east coast", @"west coast"]} messageExpected:YES];
}

- (void)testLikeListAgainstStringWithWildcard3Match {
    
    [self publishMessage:@"message_17" withFilteringExpression:@"regions like \"%east\"" 
            userMetadata:@{@"regions": @[@"north east", @"west coast"]} messageExpected:YES];
}

- (void)testLikeListAgainstStringWithWildcard4Match {
    
    [self publishMessage:@"message_18" withFilteringExpression:@"regions like \"%est%\"" 
            userMetadata:@{@"regions": @[@"east east", @"west coast"]} messageExpected:YES];
}

- (void)  publishMessage:(NSString *)message withFilteringExpression:(NSString *)filterExpression 
            userMetadata:(NSDictionary *)metadata messageExpected:(BOOL)messageExpected {
    
    self.userMetadata = metadata;
    self.filterExpression = filterExpression;
    self.expectingMessage = messageExpected;
    
    self.filterExpectation = [self expectationWithDescription:@"messageFiltering"];
    [self.client setFilterExpression:filterExpression];
    [self.client sendMessage:message toChannel:self.channel withMetadata:metadata completionBlock:NULL];
    if (!self.isMessageExpected) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.filterExpectation fulfill];
        });
    }
    [self waitForExpectationsWithTimeout:7 handler:^(NSError * _Nullable error) {
        
        if (self.isMessageExpected && error) {
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metadata options:(NSJSONWritingOptions)0 error:nil];
            XCTFail(@"\"%@\" message with (%@) metadata expected with (%@) filter expression.", message,
                    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], filterExpression);
        }
    }];
}


#pragma mark - PubNub delegate methods

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    
    XCTAssertEqualObjects(message.metadata, self.userMetadata, @"Metadata of published message doesn't match to "
                          "received metadata.");
    
    if (self.isMessageExpected) { [self.filterExpectation fulfill]; }
    else {
        
        NSData *metadata = [NSJSONSerialization dataWithJSONObject:message.metadata options:(NSJSONWritingOptions)0 error:nil];
        XCTFail(@"\"%@\" message with (%@) metadata not expected with (%@) filter expression.", message.message,
                [[NSString alloc] initWithData:metadata encoding:NSUTF8StringEncoding], self.filterExpression);
    }
}

#pragma mark -


@end
