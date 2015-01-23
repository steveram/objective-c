/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRemoteObjectDataModificationResponseParser+Protected.h"
#import "NSObject+PNPrivateAdditions.h"
#import "PNResponse+Protected.h"
#import "PNMacro.h"
#import "PNDate.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub remote object modification response parser must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Structures

struct PNModificationTypeStructure PNModificationType = {
    
    .push = @"merge",
    .pushToList = @"push",
    .replace = @"replace",
    .remove = @"delete"
};


#pragma mark Public interface implementation

@implementation PNRemoteObjectDataModificationResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {
    
    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];
    if (conforms) {
        
        conforms = (conforms ? [[response.response valueForKey:kPNResponseTimeTokenKey] isKindOfClass:[NSString class]] : conforms);
        conforms = (conforms ? [[response.response valueForKey:kPNResponseLocationKey] isKindOfClass:[NSString class]] : conforms);
        conforms = (conforms ? [[response.response valueForKey:kPNResponseModificationOperationKey] isKindOfClass:[NSString class]] : conforms);
        if (conforms && [response.response valueForKey:kPNResponseEntryIndexKey]) {
            
            conforms = (conforms ? [[response.response valueForKey:kPNResponseEntryIndexKey] isKindOfClass:[NSString class]] : conforms);
        }
    }
    
    
    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        NSString *modificationType = [response.response valueForKey:kPNResponseModificationOperationKey];
        self.objectInformation = response.additionalData;
        if (![modificationType isEqualToString:PNModificationType.remove]) {
            
            NSString *timeTokenString = [response.response valueForKey:kPNResponseTimeTokenKey];
            NSNumber *modificationTimeToken = PNNumberFromUnsignedLongLongString(timeTokenString);
            [self.objectInformation.data pn_setModificationDate:modificationTimeToken];
        }
        
        if ([modificationType isEqualToString:PNModificationType.pushToList] &&
            [response.response valueForKey:kPNResponseEntryIndexKey]) {
            
            id pushedData = self.objectInformation.data;
            if ([pushedData isKindOfClass:[NSArray class]] && [(NSArray *)pushedData count] == 1) {
                
                [[pushedData lastObject] pn_setIndex:[response.response valueForKey:kPNResponseEntryIndexKey]];
            }
        }
    }
    
    
    return self;
}

- (id)parsedData {
    
    return self.objectInformation;
}

#pragma mark -


@end
