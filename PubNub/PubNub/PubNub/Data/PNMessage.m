//
//  PNMessage.m
//  pubnub
//
//  This class is used to represent single message
//  which is sent to the PubNub service and will be
//  sent to the PubNub client delegate and observers
//  to notify about that message will/did/fail to send.
//  This object also used to represent arrived messages
//  (received on subscribed channels).
//
//
//  Created by Sergey Mamontov on 1/7/13.
//
//
#import "PNMessage+Protected.h"
#import "PNSubscribeEventInformation.h"
#import "PNJSONSerialization.h"
#import "NSString+PNAddition.h"
#import "PNChannelGroup.h"
#import "PNErrorCodes.h"
#import "PNTimeToken.h"
#import "PNChannel.h"
#import "PNError.h"
#import "PNDate.h"
#import "PubNub.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub message must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif

#pragma mark Structures

struct PNMessageDataKeysStruct PNMessageDataKeys = {
    
    .message = @"message",
    .metadata = @"metadata",
    .encryptedMessage = @"emessage",
    .channel = @"channel",
    .compress = @"compressed",
    .store = @"store",
    .contentEncrypted = @"encrypted",
    .date = @"date"
};


#pragma mark - Public interface methods

@implementation PNMessage


#pragma mark - Class methods

+ (PNMessage *)messageWithObject:(id<NSObject, NSCopying>)object forChannel:(PNChannel *)channel
                      compressed:(BOOL)shouldCompressMessage
                  storeInHistory:(BOOL)shouldStoreInHistory error:(PNError **)error {

    PNMessage *messageObject = nil;
    BOOL isValidMessage = NO;
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    id objectForValidation = (object ? [PNJSONSerialization stringFromJSONObject:object] : @"");
    isValidMessage = [[objectForValidation stringByReplacingOccurrencesOfString:@" " withString:@""] length] > 0;
#else
    isValidMessage = (object != nil);
#endif

    // Ensure that all parameters provided and they are valid or not
    if (isValidMessage && channel != nil) {

        messageObject = [[self alloc] initWithObject:object forChannel:channel
                                          compressed:shouldCompressMessage
                                      storeInHistory:shouldStoreInHistory];
    }
    // Looks like some conditions not met
    else {

        // Check whether reference on error holder has been passed or not
        if (error != NULL) {

            // Check whether user tried to send empty object or not
            if (!isValidMessage) { *error = [PNError errorWithCode:kPNMessageHasNoContentError]; }
            // Looks like user didn't specified channel on which this object
            // should be sent
            else { *error = [PNError errorWithCode:kPNMessageHasNoChannelError]; }
        }
    }

    return messageObject;
}

+ (PNMessage *)messageFromServiceResponse:(id<NSObject, NSCopying>)messageBody onChannel:(PNChannel *)channel
                                   atDate:(PNTimeToken *)messagePostDate {
    
    return [self messageFromServiceResponse:messageBody onChannel:channel channelGroup:nil
                                     atDate:messagePostDate];
}

+ (PNMessage *)messageFromServiceResponse:(id<NSObject, NSCopying>)messageBody onChannel:(PNChannel *)channel
                             channelGroup:(PNChannelGroup *)group atDate:(PNTimeToken *)messagePostDate {
    
    PNMessage *message = [self new];
    PNDate *date = (messagePostDate ? [PNDate dateWithToken:messagePostDate.token] : nil);

    // Check whether message body contains time token included from history API or not
    if (!date && [messageBody isKindOfClass:[NSDictionary class]]) {

        NSNumber *timeToken = ((NSDictionary *)messageBody)[kPNMessageTimeTokenKey];
        if (timeToken) { date = [PNDate dateWithToken:timeToken]; }

        // Extract real message
        if (((NSDictionary *)messageBody)[kPNMessageBodyKey]) {

            messageBody = (NSDictionary *)messageBody[kPNMessageBodyKey];
        }
    }
    
    message.message = messageBody;
    message.encryptedMessage = messageBody;
    message.channel = channel;
    message.channelGroup = group;
    message->_date = date;

    return message;
}

+ (PNMessage *)messageFromFileAtPath:(NSString *)messageFilePath {

    PNMessage *message = nil;
    if (messageFilePath) {

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:messageFilePath]) {

            message = [NSKeyedUnarchiver unarchiveObjectWithFile:messageFilePath];
        }
    }

    return message;
}


#pragma mark - Instance methods

- (id)initWithCoder:(NSCoder *)decoder {

    // Checking whether valid decoder data has been provided or not.
    if ([decoder containsValueForKey:PNMessageDataKeys.message] &&
        [decoder containsValueForKey:PNMessageDataKeys.channel]) {

        // Check whether initialization has been successful or not
        if ((self = [super init])) {

            self.message = [decoder decodeObjectForKey:PNMessageDataKeys.message];
            if ([decoder containsValueForKey:PNMessageDataKeys.encryptedMessage]) {

                self.encryptedMessage = [decoder decodeObjectForKey:PNMessageDataKeys.encryptedMessage];
            }
            if ([decoder containsValueForKey:PNMessageDataKeys.metadata]) {
                
                self.userMetadata = [decoder decodeObjectForKey:PNMessageDataKeys.metadata];
            }
            self.channel = [PNChannel channelWithName:[decoder decodeObjectForKey:PNMessageDataKeys.channel]];

            if ([decoder containsValueForKey:PNMessageDataKeys.date]) {

                _date = [PNDate dateWithToken:[decoder decodeObjectForKey:PNMessageDataKeys.date]];
            }
            self.compressMessage = [[decoder decodeObjectForKey:PNMessageDataKeys.compress] boolValue];
            self.storeInHistory = [[decoder decodeObjectForKey:PNMessageDataKeys.store] boolValue];
            if ([decoder containsValueForKey:PNMessageDataKeys.contentEncrypted]) {

                self.contentEncrypted = [[decoder decodeObjectForKey:PNMessageDataKeys.contentEncrypted] boolValue];
            }
        }
    }
    else { self = nil; }

    return self;
}

- (id)initWithObject:(id<NSObject, NSCopying>)object forChannel:(PNChannel *)channel
          compressed:(BOOL)shouldCompressMessage storeInHistory:(BOOL)shouldStoreInHistory {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.message = object;
        self.encryptedMessage = object;
        self.channel = channel;
        self.compressMessage = shouldCompressMessage;
        self.storeInHistory = shouldStoreInHistory;
    }

    return self;
}

- (void)updateReceiveDate:(PNTimeToken *)receiveDate {

    _date = [PNDate dateWithToken:receiveDate.token];
}

- (PNDate *)receiveDate {
    
    return _date;
}

- (NSDictionary *)metadata {
    
    return self.debugInformation.metadata;
}

- (BOOL)writeToFileAtPath:(NSString *)messageStoreFilePath {

    BOOL isWritten = NO;
    if (messageStoreFilePath) {

        NSError *storeError = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:messageStoreFilePath]) {

            [fileManager removeItemAtPath:messageStoreFilePath error:&storeError];
        }

        if (storeError == nil) {

            isWritten = [NSKeyedArchiver archiveRootObject:self toFile:messageStoreFilePath];
        }
    }

    return isWritten;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.message forKey:PNMessageDataKeys.message];
    if (self.userMetadata) { [coder encodeObject:self.userMetadata forKey:PNMessageDataKeys.metadata]; }
    [coder encodeObject:self.encryptedMessage forKey:PNMessageDataKeys.encryptedMessage];
    [coder encodeObject:self.channel.name forKey:PNMessageDataKeys.channel];

    if (self.date) { [coder encodeObject:self.date.timeToken forKey:PNMessageDataKeys.date]; }
    [coder encodeObject:@(self.shouldCompressMessage) forKey:PNMessageDataKeys.compress];
    [coder encodeObject:@(self.shouldStoreInHistory) forKey:PNMessageDataKeys.store];
    [coder encodeObject:@(self.isContentEncrypted) forKey:PNMessageDataKeys.contentEncrypted];
}

- (NSString *)description {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [[NSString alloc] initWithFormat:@"%@ (%p): <message: %@, date: %@, channel: %@, "
            "debug: %@>", NSStringFromClass([self class]), (__bridge void*)self, self.message,
            self.date, self.channel.name, self.debugInformation];
    #pragma clang diagnostic pop
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    NSMutableString *logDescription = [[NSMutableString alloc] initWithFormat:@"<%@|%@",
                                       (self.channel.name ? self.channel.name : [NSNull null]),
                                       ([self.date performSelector:@selector(logDescription)]?: [NSNull null])];
    if (self.message) {
        
        [logDescription appendFormat:@"|%@|%@>",
         ([self.message respondsToSelector:@selector(logDescription)] ?
          [self.message performSelector:@selector(logDescription)] : self.message),
         ([self.debugInformation performSelector:@selector(logDescription)]?: [NSNull null])];
    }
    else {
        
        [logDescription appendFormat:@"|%@>",
         ([self.debugInformation performSelector:@selector(logDescription)]?: [NSNull null])];
    }
    #pragma clang diagnostic pop

    return logDescription;
}

#pragma mark -


@end
