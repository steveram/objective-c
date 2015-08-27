//
//  PNTimeTokenTestCase.m
//  PubNub
//
//  Created by Jordan Zucker on 8/26/15.
//  Copyright (c) 2015 Jordan Zucker. All rights reserved.
//

#import "PNUIBasicClientTestCase.h"

@interface PNTimeTokenTestCase : PNUIBasicClientTestCase 

@end

@implementation PNTimeTokenTestCase

- (BOOL)isRecording{
    return YES;
}

- (void)testTimeToken {
    XCTestExpectation *timeTokenExpectation = [self expectationWithDescription:@"timeToken"];
    [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.operation, PNTimeOperation);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.timetoken, @14355553745683928);
        [timeTokenExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
