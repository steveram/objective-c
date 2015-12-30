/**
 @author Sergey Mamontov
 @since 3.8.0
 @copyright © 2009-15 PubNub Inc.
 */
#import "PNTimeToken.h"
#import "PNMacro.h"


#pragma mark Private interface declaration

@interface PNTimeToken () <NSCopying>


#pragma mark - Properties

@property (nonatomic, copy) NSNumber *token;
@property (nonatomic, copy) NSNumber *region;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize time token instance.
 
 @param token  Unixtimestamp with high precision.
 @param region \b PubNub server region identifier (which generated \c token value).
 
 @return Initialized and ready to use time token information instance.
 
 @since 3.8.0
 */
- (instancetype)initWithTime:(NSString *)token andRegion:(NSNumber *)region;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNTimeToken


#pragma mark - Initialization and Configuration

+ (instancetype)new {
    
    return [self timeTokenWithTime:@"0" andRegion:@0];
}

+ (instancetype)timeTokenWithTime:(NSString *)token andRegion:(NSNumber *)region {
    
    return [[self alloc] initWithTime:token andRegion:region];
}

- (instancetype)initWithTime:(NSString *)token andRegion:(NSNumber *)region {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _token = [PNNumberFromUnsignedLongLongString(token) copy];
        _region = [region copy];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)__unused zone {
    
    return [PNTimeToken timeTokenWithTime:self.token.stringValue andRegion:self.region];
}


#pragma mark - Misc

- (NSString *)description {
    
    return [[NSString alloc] initWithFormat:@"%@ (%p) <token: %@, region: %@>",
            NSStringFromClass([self class]), (__bridge void*)self, self.token, self.region];
}

- (NSString *)logDescription {
    
    return [[NSString alloc] initWithFormat:@"<%@|%@>", (self.token?: [NSNull null]),
            (self.region?: [NSNull null])];
}

#pragma mark -


@end
