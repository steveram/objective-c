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

#pragma mark -


@end
