/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNRemoteObjectDataFetchResponseParser+Protected.h"
#import "PNObjectInformation+Protected.h"
#import "NSObject+PNPrivateAdditions.h"
#import "NSArray+PNPrivateAdditions.h"
#import "PNResponse+Protected.h"
#import "NSArray+PNAdditions.h"


#pragma mark Public interface implementation

@implementation PNRemoteObjectDataFetchResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {
    
    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);
    
    
    return nil;
}

+ (BOOL)isResponseConformToRequiredStructure:(PNResponse *)response {
    
    // Checking base requirement about payload data type.
    BOOL conforms = [response.response isKindOfClass:[NSDictionary class]];
    if (conforms) {
        
        conforms = (conforms ? [[response.response valueForKey:kPNResponseDataKey] isKindOfClass:[NSDictionary class]] : conforms);
        conforms = (conforms ? [[response.response valueForKey:kPNResponseDataLocationKey] isKindOfClass:[NSString class]] : conforms);
        if (![[response.response valueForKey:kPNResponseNextDataPortionPageKey] isEqual:[NSNull null]]) {
            
            conforms = (conforms ? [[response.response valueForKey:kPNResponseNextDataPortionPageKey] isKindOfClass:[NSString class]] : conforms);
        }
        conforms = (conforms ? [[response.response valueForKey:kPNResponseOperationTypeKey] isKindOfClass:[NSString class]] : conforms);
    }
    
    
    return conforms;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {
    
    // Check whether initialization successful or not
    if ((self = [super init])) {
        
        self.objectInformation = response.additionalData;
        if (![[response.response valueForKey:kPNResponseNextDataPortionPageKey] isEqual:[NSNull null]]) {
            
            self.objectInformation.nextDataPageToken = [response.response valueForKey:kPNResponseNextDataPortionPageKey];
        }
        else {
            
            self.objectInformation.nextDataPageToken = nil;
        }
        NSDictionary *fetchedData = [response.response valueForKey:kPNResponseDataKey];
        
        // Check whether service returned some data or not
        if ([fetchedData count]) {
            
            NSString *dataLocationKeyPath = [response.response valueForKey:kPNResponseDataLocationKey];
            dataLocationKeyPath = ([dataLocationKeyPath length] ? dataLocationKeyPath : nil);
            
            // In case if this is first time when remote object's data has been requested from
            // PubNub cloud storage should be created.
            if (self.objectInformation.data == nil) {
                
                // Checking whether whole object has been requested or not
                if (!dataLocationKeyPath) {
                    
                    // Check whether fetched data represent list or not
                    if ([NSArray pn_isEntryIndexString:[[fetchedData allKeys] lastObject]]) {
                        
                        self.objectInformation.data = [NSMutableArray array];
                    }
                }
                // Looks like data has been received for particular location
                else {
                    
                    NSArray *dataLocationKeyPathComponents = [dataLocationKeyPath componentsSeparatedByString:@"."];
                    
                    // Check whether fetched data represent list or not
                    if ([NSArray pn_isEntryIndexString:[dataLocationKeyPathComponents lastObject]]) {
                        
                        self.objectInformation.data = [NSMutableArray array];
                        [self.objectInformation.data pn_setIndex:[dataLocationKeyPathComponents lastObject]];
                    }
                    // Check whether fetched data represent list or not
                    else if ([NSArray pn_isEntryIndexString:[[fetchedData allKeys] lastObject]]) {

                        self.objectInformation.data = [NSMutableArray array];
                    }
                }
                
                if (self.objectInformation.data == nil) {
                    
                    self.objectInformation.data = [NSMutableDictionary dictionary];
                }
            }
            @autoreleasepool {

                [self.objectInformation.data pn_mergeRemoteObjectData:fetchedData];
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
