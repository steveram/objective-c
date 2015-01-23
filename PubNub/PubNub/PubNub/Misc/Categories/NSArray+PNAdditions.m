//
//  NSArray+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import "NSArray+PNAdditions.h"
#import "NSObject+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub array category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface methods

@implementation NSArray (PNAdditions)


#pragma mark - Class methods

+ (NSArray *)pn_arrayWithVarietyList:(va_list)list {

    NSMutableArray *array = [NSMutableArray array];
    id argument;
    while ((argument = va_arg(list, id))) {
        if (argument == nil)
            break;
        [array addObject:argument];
    }


    return array;
}

+ (BOOL)pn_isEntryIndexString:(NSString *)string {
    
    // Lighweight check to ensure that string at least start with char specific only to time
    // tokens.
    BOOL isEntryIndexString = [string hasPrefix:@"-"];
    if (isEntryIndexString) {
        
        
        isEntryIndexString = ([string rangeOfString:@"^-([A-Za-z]*)?!([0-9]{17})"
                                            options:NSRegularExpressionSearch].location != NSNotFound);
    }
    
    
    return isEntryIndexString;
}


#pragma mark - Instance methods

- (id)pn_objectAtIndex:(NSString *)pnIndex {
    
    __block id storedObject = nil;
    if (pnIndex) {

        [[self copy] enumerateObjectsUsingBlock:^(id object, NSUInteger objectIdx,
                BOOL *objectEnumeratorStop) {

            if ([[object pn_index] isEqualToString:pnIndex]) {

                storedObject = object;
            }

            *objectEnumeratorStop = (storedObject != nil);
        }];
    }
    
    
    return storedObject;
}

- (NSString *)logDescription {
    
    NSMutableString *logDescription = [NSMutableString stringWithString:@"<["];
    
    [self enumerateObjectsUsingBlock:^(id entry, NSUInteger entryIdx, BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry performSelector:@selector(logDescription)];
            entry = (entry ? entry : @"");
        }
        [logDescription appendFormat:@"%@%@", entry, (entryIdx + 1 != [self count] ? @"|" : @"")];
    }];
    [logDescription appendString:@"]>"];
    
    
    return logDescription;
}

#pragma mark -


@end
