/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNObjectInformation+Protected.h"


#pragma mark Public interface implementation

@implementation PNObjectInformation


#pragma mark - Class methods

+ (instancetype)objectInformation:(NSString *)identifier dataLocations:(NSArray *)locations
                snapshotTimeToken:(NSString *)snapshotTimeToken {
    
    return [[self alloc] initObjectInformation:identifier dataLocations:locations
                             snapshotTimeToken:snapshotTimeToken];
}

- (instancetype)initObjectInformation:(NSString *)identifier dataLocations:(NSArray *)locations
                    snapshotTimeToken:(NSString *)snapshotTimeToken {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.identifier = identifier;
        self.dataLocations = locations;
        self.lastSnaphostTimeToken = (snapshotTimeToken.length > 1 ? snapshotTimeToken : nil);
    }
    
    
    return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@ (%p) <identifier: %@, paths: %@, snapshot date: %@, next page token: %@>",
            NSStringFromClass([self class]), self, self.identifier,
            (self.dataLocations ? [self.dataLocations componentsJoinedByString:@", "] : @"*"),
            self.lastSnaphostTimeToken, self.nextDataPageToken];
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@|%@>", self.identifier,
            (self.dataLocations ? [self.dataLocations performSelector:@selector(logDescription)] :
             [NSNull null]),
            (self.nextDataPageToken ? self.nextDataPageToken : [NSNull null])];
    #pragma clang diagnostic pop
}

#pragma mark -


@end
