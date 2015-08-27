//
//  JSZVCRKIFTestCase.m
//  PubNub
//
//  Created by Jordan Zucker on 8/27/15.
//  Copyright (c) 2015 Jordan Zucker. All rights reserved.
//

#import "JSZVCRKIFTestCase.h"

#import <JSZVCR/JSZVCRRecorder.h>
#import <JSZVCR/JSZVCRSimpleURLMatcher.h>

@interface JSZVCRKIFTestCase () <JSZVCRPlayerDelegate>
@property (nonatomic) JSZVCR *vcr;

@end

@implementation JSZVCRKIFTestCase

- (BOOL)isRecording {
    return YES;
}

- (JSZVCRTestingStrictness)matchingFailStrictness {
    return JSZVCRTestingStrictnessNone;
}

- (Class<JSZVCRMatching>)matcherClass {
    return [JSZVCRSimpleURLMatcher class];
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super initWithInvocation:invocation];
    if (self) {
        _vcr = [JSZVCR vcrWithMatcherClass:self.matcherClass];
        _vcr.playerDelegate = self;
        _vcr.currentTestCase = self;
        _vcr.recording = [self isRecording];
        _vcr.matchFailStrictness = [self matchingFailStrictness];
    }
    return self;
}

- (void)setUp {
    [super setUp];
    [self.vcr removeAllUnsavedRecordings];
    self.vcr.recording = [self isRecording];
}

- (void)tearDown {
    [self.vcr tearDown];
    [self.vcr removeAllNetworkResponses];
    if (self.vcr.isRecording) {
        [self.vcr saveTestRecordings];
    }
    [super tearDown];
}

- (NSArray *)recordings {
    return self.vcr.currentStoredRecordings;
}

#pragma mark - JSZVCRPlayerDelegate

- (void)testCase:(XCTestCase *)testCase withUnmatchedRequest:(NSURLRequest *)request shouldFail:(BOOL)shouldFail {
    if (shouldFail) {
        XCTFail(@"Unmatched request: %@", request);
    }
}

@end
