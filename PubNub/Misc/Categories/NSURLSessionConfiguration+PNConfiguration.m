/**
 @author Sergey Mamontov
 @since 4.4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "NSURLSessionConfiguration+PNConfigurationPrivate.h"
#if TARGET_OS_WATCH
    #import <WatchKit/WatchKit.h>
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <UIKit/UIKit.h>
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface NSURLSessionConfiguration (PNConfigurationProtected)


#pragma mark - Misc

/**
 @brief  Allow to filter up passed list of prtocol classes from names which can intersect with \c Apple's 
         protocols. 
 
 @since 4.4.0
 
 @param protocolClasses Srouce list of protocol classes which should be filtered.
 
 @return Filtered list of protocol classes or same list if there was no potentially dangerous protocol 
        classes.
 */
+ (nullable NSArray<Class> *)pn_filteredProtocolClasses:(NSArray<Class> *)protocolClasses;

/**
 @brief  Allow to construct set of headers which should be used for network requests.
 
 @return Dictionary with headers which should be added to each request.
 
 @since 4.4.0
 */
+ (NSDictionary *)pn_defaultHeaders;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation NSURLSessionConfiguration (PNConfiguration)


#pragma mark - Initialization and Configuration

+ (instancetype)pn_ephemeralSessionConfiguration {
    
    static NSURLSessionConfiguration *_sharedSessionConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _sharedSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        _sharedSessionConfiguration.URLCache = nil;
        _sharedSessionConfiguration.HTTPAdditionalHeaders = [self pn_defaultHeaders];
    });
    
    return _sharedSessionConfiguration;
}

+ (NSDictionary<NSString *, id> *)pn_HTTPAdditionalHeaders {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    NSMutableDictionary *headers = [configuration.HTTPAdditionalHeaders mutableCopy];
    [headers removeObjectsForKeys:@[@"Accept", @"Accept-Encoding", @"User-Agent", @"Connection"]];
    
    return (headers.count ? headers : nil);
}

+ (void)pn_setHTTPAdditionalHeaders:(NSDictionary<NSString *, id> *)HTTPAdditionalHeaders {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    NSMutableDictionary *headers = [HTTPAdditionalHeaders mutableCopy];
    [headers removeObjectsForKeys:@[@"Accept", @"Accept-Encoding", @"User-Agent", @"Connection"]];
    if (headers.count) {
        
        [headers addEntriesFromDictionary:configuration.HTTPAdditionalHeaders];
        configuration.HTTPAdditionalHeaders = headers;
    }
    else { configuration.HTTPAdditionalHeaders = [self pn_defaultHeaders]; }
}

+ (NSURLRequestNetworkServiceType)pn_networkServiceType {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    
    return configuration.networkServiceType;
}

+ (void)pn_setNetworkServiceType:(NSURLRequestNetworkServiceType)networkServiceType {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    configuration.networkServiceType = networkServiceType;
}

+ (BOOL)pn_allowsCellularAccess {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    
    return configuration.allowsCellularAccess;
}

+ (void)pn_setAllowsCellularAccess:(BOOL)allowsCellularAccess {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    configuration.allowsCellularAccess = allowsCellularAccess;
}

+ (NSArray<Class> *)pn_protocolClasses {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    
    return [self pn_filteredProtocolClasses:configuration.protocolClasses];
}

+ (void)pn_setProtocolClasses:(NSArray<Class> *)protocolClasses {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    
    // Append user-provided protocol classes to system-provided.
    NSMutableArray *currentProtocolClasses = [NSMutableArray arrayWithArray:configuration.protocolClasses];
    [currentProtocolClasses removeObjectsInArray:[self pn_protocolClasses]];
    [currentProtocolClasses addObjectsFromArray:[self pn_filteredProtocolClasses:protocolClasses]];
    configuration.protocolClasses = [currentProtocolClasses copy];
}

+ (NSDictionary<NSString *, id> *)pn_connectionProxyDictionary {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    
    return configuration.connectionProxyDictionary;
}

+ (void)pn_setConnectionProxyDictionary:(NSDictionary<NSString *, id> *)connectionProxyDictionary {
    
    NSURLSessionConfiguration *configuration = [self pn_ephemeralSessionConfiguration];
    configuration.connectionProxyDictionary = connectionProxyDictionary;
}


#pragma mark - Misc

+ (NSArray<Class> *)pn_filteredProtocolClasses:(NSArray<Class> *)protocolClasses {
    
    NSArray<Class> *protocols = (protocolClasses.count ? protocolClasses : nil);
    if (protocols.count) {
        
        NSMutableArray *filteredProtocols = [protocols mutableCopy];
        [protocols enumerateObjectsUsingBlock:^(Class protocolClass, NSUInteger protocolClassIdx, BOOL *protocolClassesEnumeratorStop) {
            
            NSString *className = NSStringFromClass(protocolClass);
            if ([className hasPrefix:@"_NS"] || [className hasPrefix:@"NS"]) {
                
                [filteredProtocols removeObject:protocolClass];
            }
        }];
        protocols = [filteredProtocols copy];
    }
    
    return protocols;
}

+ (NSDictionary *)pn_defaultHeaders {
    
    NSString *device = @"iPhone";
#if TARGET_OS_WATCH
    NSString *osVersion = [[WKInterfaceDevice currentDevice] systemVersion];
#elif __IPHONE_OS_VERSION_MIN_REQUIRED
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
#elif __MAC_OS_X_VERSION_MIN_REQUIRED
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo]operatingSystemVersion];
    NSMutableString *osVersion = [NSMutableString stringWithFormat:@"%@.%@",
                                  @(version.majorVersion), @(version.minorVersion)];
    if (version.patchVersion > 0) {
        
        [osVersion appendFormat:@".%@", @(version.patchVersion)];
    }
#endif
    NSString *userAgent = [NSString stringWithFormat:@"iPhone; CPU %@ OS %@ Version",
                           device, osVersion];
    
    return @{@"Accept":@"*/*", @"Accept-Encoding":@"gzip,deflate", @"User-Agent":userAgent,
             @"Connection":@"keep-alive"};
}

#pragma mark -


@end