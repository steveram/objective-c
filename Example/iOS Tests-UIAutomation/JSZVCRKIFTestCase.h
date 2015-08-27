//
//  JSZVCRKIFTestCase.h
//  PubNub
//
//  Created by Jordan Zucker on 8/27/15.
//  Copyright (c) 2015 Jordan Zucker. All rights reserved.
//

#import <KIF/KIF.h>

#import <JSZVCR/JSZVCR.h>

@interface JSZVCRKIFTestCase : KIFTestCase

- (BOOL)isRecording;

- (Class<JSZVCRMatching>)matcherClass;

- (JSZVCRTestingStrictness)matchingFailStrictness;

@property (nonatomic, readonly) NSArray *recordings;

@end
