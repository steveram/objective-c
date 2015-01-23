/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNRemoteObjectDataModificationRequest+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PNJSONSerialization.h"
#import "PNObjectInformation.h"
#import "NSString+PNAddition.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


#pragma mark Public interface implementation

@implementation PNRemoteObjectDataModificationRequest


#pragma mark - Class methods

+ (instancetype)dataPushRequestFor:(PNObjectInformation *)objectInformation {
    
    return [[self alloc] initModificationRequest:PNRemoteObjectPushModificationType
                                       forObject:objectInformation];
}

+ (instancetype)dataPushToListRequestFor:(PNObjectInformation *)objectInformation
                          withSortingKey:(NSString *)entriesSortingKey {
    
    PNRemoteObjectDataModificationRequest *request = [[self alloc] initModificationRequest:PNRemoteObjectPushToListModificationType
                                                                                 forObject:objectInformation];
    request.entriesSortingKey = entriesSortingKey;
    
    
    return request;
}

+ (instancetype)dataReplaceRequestFor:(PNObjectInformation *)objectInformation {
    
    return [[self alloc] initModificationRequest:PNRemoteObjectReplaceModificationType
                                       forObject:objectInformation];
}

+ (instancetype)dataRemoveRequestFor:(PNObjectInformation *)objectInformation {
    
    return [[self alloc] initModificationRequest:PNRemoteObjectRemoveModificationType
                                       forObject:objectInformation];
}


#pragma mark - Instance methods

- (instancetype)initModificationRequest:(PNRemoteObjectModificationType)modificationType
                              forObject:(PNObjectInformation *)objectInformation {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.objectInformation = objectInformation;
        self.modificationType = modificationType;
    }
    
    
    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.publishKey = configuration.publishKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {
    
    NSString *callbackMethodName = PNServiceResponseCallbacks.remoteObjectDataPushCallback;
    if (self.modificationType == PNRemoteObjectReplaceModificationType) {
        
        callbackMethodName = PNServiceResponseCallbacks.remoteObjectDataReplaceCallback;
    }
    else if (self.modificationType == PNRemoteObjectReplaceModificationType) {
        
        callbackMethodName = PNServiceResponseCallbacks.remoteObjectDataRemoveCallback;
    }
    
    
    return callbackMethodName;
}

- (PNRequestHTTPMethod)HTTPMethod {

    PNRequestHTTPMethod method = PNRequestPATCHMethod;
    if (self.modificationType == PNRemoteObjectPushToListModificationType) {

        if ([(NSArray *)self.objectInformation.data count] == 1) {

            method = PNRequestPOSTMethod;
        }
    }
    else if (self.modificationType == PNRemoteObjectReplaceModificationType) {

        method = PNRequestPUTMethod;
    }
    else if (self.modificationType == PNRemoteObjectRemoveModificationType) {

        method = PNRequestDELETEMethod;
    }
    
    return method;
}

- (NSData *)POSTBody {
    
    return [self.preparedData dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)preparedData {
    
    if (_preparedData == nil) {
        
        id originalData = self.objectInformation.data;
        if (self.modificationType == PNRemoteObjectPushToListModificationType) {
            
            if ([(NSArray *)self.objectInformation.data count] == 1) {
                
                originalData = [(NSArray *)self.objectInformation.data lastObject];
            }
        }
        _preparedData = [PNJSONSerialization stringFromJSONObject:originalData];
    }
    
    
    return _preparedData;
}

- (NSString *)resourcePath {
    
    NSString *dataLocation = @"";
    if ([self.objectInformation.dataLocations count]) {
        
        NSString *locationKeyPath = [self.objectInformation.dataLocations lastObject];
        dataLocation = [@"/" stringByAppendingString:[locationKeyPath stringByReplacingOccurrencesOfString:@"." withString:@"/"]];
    }
    NSString *sortingKey = @"";
    if ([self.entriesSortingKey length]) {
        
        sortingKey = [@"&sort_key=" stringByAppendingString:self.entriesSortingKey];
    }
    
    
    return [NSString stringWithFormat:@"/v1/datasync/sub-key/%@/pub-key/%@/obj-id/%@%@?callback=%@_%@%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString], [self.publishKey pn_percentEscapedString],
            [self.objectInformation.identifier pn_percentEscapedString], dataLocation,
            [self callbackMethodName], self.shortIdentifier, sortingKey,
            ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    NSString *publishKey = [self.publishKey pn_percentEscapedString];
    NSString *debugResourcePath = [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey
                                                                                 withString:PNObfuscateString(subscriptionKey)];
    
    
    return [debugResourcePath stringByReplacingOccurrencesOfString:publishKey withString:PNObfuscateString(publishKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
