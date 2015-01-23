/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRemoteObjectDataFetchRequest+Protected.h"
#import "PNObjectInformation+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub object fetch request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface implementation

@implementation PNRemoteObjectDataFetchRequest


#pragma mark - Class methods

+ (instancetype)remoteObjectFetchRequestFor:(PNObjectInformation *)objectInformation {
    
    return [[self alloc] initRequestFor:objectInformation];
}


#pragma mark - Instance methods

- (instancetype)initRequestFor:(PNObjectInformation *)objectInformation {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.objectInformation = objectInformation;
    }
    
    
    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration
                 clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {
    
    return PNServiceResponseCallbacks.remoteObjectDataFetchCallback;
}

- (NSString *)resourcePath {
    
    // Composing parameters list
    NSMutableString *parameters = [NSMutableString stringWithFormat:@"?callback=%@_%@", [self callbackMethodName],
                                   self.shortIdentifier];
    
    // Checking whether there is offset which should be used or not.
    if (self.objectInformation.lastSnaphostTimeToken) {
        
        [parameters appendFormat:@"&start_at=%@", self.objectInformation.lastSnaphostTimeToken];
    }
    
    NSString *dataLocation = @"";
    if ([self.objectInformation.dataLocations count]) {
        
        NSString *locationKeyPath = [self.objectInformation.dataLocations lastObject];
        dataLocation = [@"/" stringByAppendingString:[locationKeyPath stringByReplacingOccurrencesOfString:@"." withString:@"/"]];
    }
    
    NSString *nextDataPage = @"";
    if ([self.objectInformation.nextDataPageToken length]) {
        
        nextDataPage = [NSString stringWithFormat:@"&next_page=%@",
                        self.objectInformation.nextDataPageToken];
    }
    
    //&page_max_bytes=3
    return [NSString stringWithFormat:@"/v1/datasync/sub-key/%@/obj-id/%@%@%@%@%@&method=GET&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString],
            [self.objectInformation.identifier pn_percentEscapedString], dataLocation, parameters, nextDataPage,
            ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
