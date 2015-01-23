/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNObject+Protected.h"
#import "PNDate.h"



#pragma mark Private interface declaration

@interface PNObject ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *identifier;



#pragma mark - Instance methods

/**
 @brief      Initialize dummy object instance which not bound to any synchronization schemes.
 
 @discussion This method is useful when object should be passed to one of APIs (PAM for example).
 
 @param identifier Reference on identifier which has been used to store object in \b PubNub cloud
                   and allow to gain access to it and synchronize with local copy.
 
 @return Initialized and ready to use dummy object with specified identifier.
 
 @since <#version number#>
 */
- (instancetype)initWithIdentifier:(NSString *)identifier;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNObject


#pragma mark - Class methods

+ (instancetype)objectWithIdentifier:(NSString *)identifier {
    
    return [[self alloc] initWithIdentifier:identifier];
}

+ (NSArray *)objectsWithIdentifiers:(NSArray *)identifiers {
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[identifiers count]];
    [identifiers enumerateObjectsUsingBlock:^(NSString *objectIdentifier,
                                              NSUInteger objectIdentifierIdx,
                                              BOOL *objectIdentifierEnumeratopStop) {
        
        [objects addObject:[[self alloc] initWithIdentifier:objectIdentifier]];
    }];
    
    
    return [objects copy];
}


#pragma mark - Instance methods

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.identifier = identifier;
    }
    
    
    return self;
}

- (void)invalidate {
    
    self.valid = NO;
    self.data = nil;
}

- (BOOL)isKindOfClass:(Class)aClass {
    
    return [(self.data ? self.data : self) isKindOfClass:aClass];
}


#pragma mark - NSDictionary calls forward

- (id)valueForUndefinedKey:(NSString *)key {

    return [self.data valueForKey:key];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    id target = nil;
    if ([self.data respondsToSelector:aSelector]) {
        
        target = self.data;
    }
    
    return target;
}


#pragma mark - PNChannel protocol methods

- (NSString *)name {
    
    return self.identifier;
}

- (NSString *)updateTimeToken {
    
    return nil;
}

- (BOOL)isChannelGroup {
    
    return NO;
}

- (BOOL)isForDataSynchronization {
    
    return YES;
}


- (PNDate *)presenceUpdateDate {
    
    return nil;
}

- (NSUInteger)participantsCount {
    
    return 0;
}

- (NSArray *)participants {
    
    return nil;
}


#pragma mark - Misc methods

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@(%p) %@ object data:\n%@",
            NSStringFromClass([self class]), self,  self.identifier, self.data];
}

- (NSString *)logDescription {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@|%@>", (self.identifier ? self.identifier : [NSNull null]),
            (self.data ? [self.data performSelector:@selector(logDescription)] : [NSNull null])];
#pragma clang diagnostic pop
}

#pragma mark -


@end
