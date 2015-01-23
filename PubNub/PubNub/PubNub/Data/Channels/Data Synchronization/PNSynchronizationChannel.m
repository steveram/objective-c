/**
 @author Sergey Mamontov
 @since <#version number#>
 @copyright © 2009-2014 PubNub, Inc.
 */
#import "PNSynchronizationChannel+Protected.h"
#import "PNChannel+Protected.h"
#import "NSString+PNAddition.h"


#pragma mark Public interface implementation

@implementation PNSynchronizationChannel


#pragma mark - Class methods

+ (instancetype)channelForObject:(NSString *)objectIdentifier dataAtLocation:(NSString *)location {
    
    // Object identifier itself shouldn't have "." in it's name or it will be treated as part
    // of data location key-path.
    NSArray *objectIdentifierComponents = [objectIdentifier componentsSeparatedByString:@"."];
    
    // Try to extract data path from object identifier (if initial data location hasn't been
    // specified)
    if (!location && [objectIdentifierComponents count] > 1) {
        
        NSString *prefixForRemoval = [NSString stringWithFormat:@"%@.", [objectIdentifierComponents objectAtIndex:0]];
        location = [objectIdentifier stringByReplacingOccurrencesOfString:prefixForRemoval withString:@""];
    }
    
    // Clear object identifier from unknown path extensions
    if ([objectIdentifierComponents count] > 1) {
        
        objectIdentifier = [objectIdentifierComponents objectAtIndex:0];
    }
    
    NSString *channelName = [objectIdentifier copy];
    if (![channelName hasPrefix:@"pn_ds_"] && ![channelName hasPrefix:@"pn_dstr_"]) {
        
        channelName = [NSString stringWithFormat:@"pn_ds_%@", channelName];
    }
    // Looks like synchronization channel name prefixes leaked into object identifier
    // so we need to remove them from identifier.
    else {
        
        objectIdentifier = [objectIdentifier stringByReplacingOccurrencesOfString:@"pn_ds_" withString:@""];
        objectIdentifier = [objectIdentifier stringByReplacingOccurrencesOfString:@"pn_dstr_" withString:@""];
    }
    if ([location length] && ![channelName hasPrefix:@"pn_dstr_"]) {
        
        channelName = [channelName stringByAppendingFormat:@".%@", location];
    }
    
    PNSynchronizationChannel *channel = (PNSynchronizationChannel *)[super channelWithName:channelName
                                                                     shouldObservePresence:NO];
    channel.identifier = objectIdentifier;
    channel.dataLocation = ([location length] ? location : nil);
    channel.forDataSynchronization = YES;
    
    
    return channel;
}

+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataAtLocations:(NSArray *)locations {
    
    return [self channelsForObject:objectIdentifier dataAtLocations:locations
              includingTransaction:YES];
}

+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataAtLocations:(NSArray *)locations
          includingTransaction:(BOOL)shouldCreatedTransactionFeed {
    
    NSMutableArray *dataChannels = [NSMutableArray array];
    void(^createDataFeedChannelBlock)(NSString *dataLocation) = ^(NSString *dataLocation) {

        NSString *updatesChannelName = [@"pn_ds_" stringByAppendingString:objectIdentifier];
        NSString *dataLocationChildPath = ([dataLocation length] ? [dataLocation stringByAppendingString:@".*"] : @"*");
        NSString *transactionChannelName = [@"pn_dstr_" stringByAppendingString:objectIdentifier];

        // Adding top-level channel
        [dataChannels addObject:[self channelForObject:updatesChannelName dataAtLocation:dataLocation]];

        // Adding data feed channel which allow to observe changes on child nodes
        [dataChannels addObject:[self channelForObject:updatesChannelName dataAtLocation:dataLocationChildPath]];

        if (shouldCreatedTransactionFeed) {

            // Adding data feed channel which allow to track change event transactions
            [dataChannels addObject:[self channelForObject:transactionChannelName dataAtLocation:dataLocation]];
        }
    };

    if ([locations count]) {

        [locations enumerateObjectsUsingBlock:^(NSString *location, NSUInteger locationIdx,
                                                BOOL *locationEnumeratorStop) {

            createDataFeedChannelBlock(location);
        }];
    }
    else {

        createDataFeedChannelBlock(nil);
    }
    
    
    return dataChannels;
}

+ (BOOL)isObjectSynchronizationChannel:(NSString *)channelName {
    
    return ([channelName length] && ([channelName hasPrefix:@"pn_ds_"] || [channelName hasPrefix:@"pn_dstr_"]));
}

+ (NSString *)objectIdentifierFrom:(NSString *)channelName {

    NSMutableString *objectIdentifier = nil;
    if ([channelName length] && [self isObjectSynchronizationChannel:channelName]) {

        NSArray *nameComponents = [channelName componentsSeparatedByString:@"."];
        if ([nameComponents count]) {

            objectIdentifier = [[nameComponents objectAtIndex:0] mutableCopy];
            NSRange prefixRange = [objectIdentifier rangeOfString:@"pn_ds_"];
            if (prefixRange.location == NSNotFound) {

                prefixRange = [objectIdentifier rangeOfString:@"pn_dstr_"];
            }
            [objectIdentifier replaceCharactersInRange:prefixRange withString:@""];
        }
    }


    return [objectIdentifier copy];
}

+ (NSString *)objectModificationLocationFrom:(NSString *)channelName {

    NSString *objectModificationLocation = nil;
    if ([channelName length] && [self isObjectSynchronizationChannel:channelName]) {

        NSArray *nameComponents = [channelName componentsSeparatedByString:@"."];
        if ([nameComponents count] > 1) {

            NSString *objectIdentifier = [self objectIdentifierFrom:channelName];
            NSString *prefix = [objectIdentifier stringByAppendingString:@"."];
            NSRange prefixRange = [channelName rangeOfString:prefix];

            objectModificationLocation = [channelName substringFromIndex:(prefixRange.location + prefixRange.length)];
            if ([objectModificationLocation isEqualToString:@"*"]) {

                objectModificationLocation = nil;
            }
        }
    }


    return objectModificationLocation;
}

+ (NSArray *)baseSynchronizationChannelsFromList:(NSArray *)channels {
    
    NSMutableArray *filteredChannels = [NSMutableArray arrayWithCapacity:[channels count]];
    [channels enumerateObjectsUsingBlock:^(id <PNChannelProtocol>channel, NSUInteger channelIdx,
                                           BOOL *channelEnumeratorStop) {
        
        if ([self isObjectSynchronizationChannel:channel.name]) {
            
            if (!((PNSynchronizationChannel *)channel).isForDataSynchronization) {
                
                ((PNSynchronizationChannel *)channel).forDataSynchronization = YES;
            }
            NSString *partialObjectDataPath = ((PNSynchronizationChannel *)channel).dataLocation;
            
            if ([channel.name hasPrefix:@"pn_ds_"] &&
                (![partialObjectDataPath length] || ![partialObjectDataPath hasSuffix:@"*"])) {
                
                [filteredChannels addObject:channel];
            }
        }
    }];
    
    
    return filteredChannels;
}

#pragma mark -


@end
