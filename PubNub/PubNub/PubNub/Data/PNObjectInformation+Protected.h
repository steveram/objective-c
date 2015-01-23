#import "PNObjectInformation.h"
#import "PNObject.h"
#import "PNDate.h"


#pragma mark Private interface declaration

@interface PNObjectInformation ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSArray *dataLocations;

@property (nonatomic, strong) id data;
@property (nonatomic, strong) PNObject *object;

/**
 @brief Stores reference on qunieue key which is used during remote object request to identify 
        that there is more data available if this key not \c nil .
 
 @since <#version number#>
 */
@property (nonatomic, copy) NSString *nextDataPageToken;

/**
 @brief Stores reference on time token which represent date when last changes has been done to 
        remote object.
 
 @since <#version number#>
 */
@property (nonatomic, copy) NSString *lastSnaphostTimeToken;


#pragma mark - Class methods

/**
 @brief Construct remote object information instance with base parameters required to complete
        object fetching request.
 
 @param identifier        Reference on remote object identifier which should be pulled to the 
                          local copy.
 @param locations         Key-paths to portions of data which should be in sync with \b PubNub 
                          cloud object. In case if \c nil is passed, whole object from \b PubNub
                          cloud will be synchronized with local object copy.
 @param snapshotTimeToken Time token since which object changes will be pulled out from \b PubNub
                          cloud.
 
 @return Ready to use remote object information instance.
 
 @since <#version number#>
 */
+ (instancetype)objectInformation:(NSString *)identifier dataLocations:(NSArray *)locations
                snapshotTimeToken:(NSString *)snapshotTimeToken;


#pragma marin - Instance methods

/**
 @brief Initialize remote object information instance with base parameters required to complete
        object fetching request.
 
 @param identifier        Reference on remote object identifier which should be pulled to the 
                          local copy.
 @param locations         Key-paths to portions of data which should be in sync with \b PubNub 
                          cloud object. In case if \c nil is passed, whole object from \b PubNub
                          cloud will be synchronized with local object copy.
 @param snapshotTimeToken Time token since which object changes will be pulled out from \b PubNub
                          cloud.
 
 @return Ready to use remote object information instance.
 
 @since <#version number#>
 */
- (instancetype)initObjectInformation:(NSString *)identifier dataLocations:(NSArray *)locations
                    snapshotTimeToken:(NSString *)snapshotTimeToken;

#pragma mark -


@end
