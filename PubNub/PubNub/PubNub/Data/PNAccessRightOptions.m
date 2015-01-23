//
//  PNAccessRightOptions.m
//  pubnub
//
//  Created by Sergey Mamontov on 11/3/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNAccessRightOptions+Protected.h"
#import "PNChannel+Protected.h"
#import "PNPrivateImports.h"
#import "PNHelper.h"


#pragma mark Static

// Stores default access period duration (while granted access will be valid)
static NSInteger const kPNDefaulfAccessPeriodDuration = 1440;


#pragma mark - Public interface implementation

@implementation PNAccessRightOptions


#pragma mark - Class methods

+ (PNAccessRightOptions *)accessRightOptionsForApplication:(NSString *)applicationKey withRights:(PNAccessRights)rights
                                                   objects:(NSArray *)objects clients:(NSArray *)clientsAccessKeys
                                              accessPeriod:(NSInteger)accessPeriodDuration {

    return [[self alloc] initWithApplication:applicationKey withRights:rights objects:objects
                                     clients:clientsAccessKeys accessPeriod:accessPeriodDuration];
}


#pragma mark - Instance methods

- (id)initWithApplication:(NSString *)applicationKey withRights:(PNAccessRights)rights objects:(NSArray *)objects
                  clients:(NSArray *)clientsAuthorizationKeys accessPeriod:(NSInteger)accessPeriodDuration {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.applicationKey = applicationKey;
        self.rights = rights;
        self.level = PNApplicationAccessRightsLevel;
        if ([objects count]) {

            self.level = PNChannelAccessRightsLevel;
            if (((PNChannel *)[objects lastObject]).isChannelGroup) {
                
                self.level = PNChannelGroupAccessRightsLevel;
            }
            if ([clientsAuthorizationKeys count]) {

                self.level = PNUserAccessRightsLevel;
                self.clientsAuthorizationKeys = clientsAuthorizationKeys;
            }
            self.objects = objects;
        }

        self.accessPeriodDuration = (accessPeriodDuration >= 0 ? accessPeriodDuration : kPNDefaulfAccessPeriodDuration);
        if (self.rights == PNUnknownAccessRights || self.rights == PNNoAccessRights) {

            self.accessPeriodDuration = 0;
        }
    }



    return self;
}

- (BOOL)isEnablingReadAccessRight {

    return [PNBitwiseHelper is:self.rights containsBit:PNReadAccessRight];
}

- (BOOL)isEnablingWriteAccessRight {
    
    return [PNBitwiseHelper is:self.rights containsBit:PNWriteAccessRight];
}

- (BOOL)isEnablingAllAccessRights {

    return [PNBitwiseHelper is:self.rights strictly:YES containsBits:PNReadAccessRight, PNWriteAccessRight, BITS_LIST_TERMINATOR];
}

- (BOOL)isRevokingAccessRights {

    return ![self isEnablingReadAccessRight] && ![self isEnablingWriteAccessRight];
}

- (NSArray *)channels {

    return self.objects;
}

- (NSString *)description {

    NSMutableString *description = [NSMutableString stringWithFormat:@"%@ (%p) <",
                                                    NSStringFromClass([self class]), self];

    NSString *level = @"application";
    if (self.level == PNChannelAccessRightsLevel) {

        level = @"channel";
    }
    else if (self.level == PNChannelGroupAccessRightsLevel) {

        level = @"channel-group";
    }
    else if (self.level == PNRemoteDataObjectAccessRightsLevel) {

        level = @"object";
    }
    else if (self.level == PNUserAccessRightsLevel) {

        level = @"user";
    }
    [description appendFormat:@"level: %@;", level];

    NSString *rights = @"none (revoked)";
    if ([self isEnablingReadAccessRight] || [self isEnablingWriteAccessRight]) {

        rights = [self isEnablingReadAccessRight] ? @"read" : @"";
        if ([self isEnablingWriteAccessRight]) {

            rights = ([rights length] > 0) ? [rights stringByAppendingString:@" / write"] : @"write";
        }
    }
    [description appendFormat:@" rights: %@;", rights];

    [description appendFormat:@" application: %@;", self.applicationKey];

    if (self.level == PNChannelAccessRightsLevel) {

        [description appendFormat:@" channels: %@;", self.objects];
    }
    else if (self.level == PNChannelGroupAccessRightsLevel) {

        [description appendFormat:@" channel-group: %@;", self.objects];
    }
    else if (self.level == PNRemoteDataObjectAccessRightsLevel) {

        [description appendFormat:@" object: %@;", self.objects];
    }
    else if (self.level == PNUserAccessRightsLevel) {

        [description appendFormat:@" users: %@;", self.clientsAuthorizationKeys];
    }

    [description appendFormat:@" access period duration: %lu>", (unsigned long)self.accessPeriodDuration];


    return description;
}

- (NSString *)logDescription {
    
    NSString *level = @"application";
    if (self.level == PNChannelGroupAccessRightsLevel) {
        
        level = @"channel-group";
    }
    else if (self.level == PNChannelAccessRightsLevel) {

        level = @"channel";
    }
    else if (self.level == PNRemoteDataObjectAccessRightsLevel) {

        level = @"object";
    }
    else if (self.level == PNUserAccessRightsLevel) {
        
        level = @"user";
    }
    NSMutableString *logDescription = [NSMutableString stringWithFormat:@"<%@|%@|%@|%lu", level, PNObfuscateString(self.applicationKey),
                                       @(self.rights), (unsigned long)self.accessPeriodDuration];
    if (self.level == PNChannelGroupAccessRightsLevel || self.level == PNChannelAccessRightsLevel ||
        self.level == PNRemoteDataObjectAccessRightsLevel) {
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        [logDescription appendFormat:@"|%@", (self.objects ? [self.objects performSelector:@selector(logDescription)] : [NSNull null])];
        #pragma clang diagnostic pop
    }
    else if (self.level == PNUserAccessRightsLevel) {
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        [logDescription appendFormat:@"|%@|%@",
         (self.clientsAuthorizationKeys ? [self.clientsAuthorizationKeys performSelector:@selector(logDescription)] : [NSNull null]),
         (self.objects ? [self.objects performSelector:@selector(logDescription)] : [NSNull null])];
        #pragma clang diagnostic pop
    }
    [logDescription appendString:@">"];
    
    
    return logDescription;
}

#pragma mark -


@end
