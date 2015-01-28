//
//  DSDictionaryEntryCell.m
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/27/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "DSDictionaryEntryCell.h"


#pragma mark Types & Structures

struct PNDictionaryEntryDataStructure {
    
    /**
     @brief Stores key in case if entry represent one of dictionary entries.
     */
    __unsafe_unretained NSString *key;
    
    /**
     @brief Stores actual object title which should be displayed in main part of entry cell.
            For simple value stored in list it will represent that value.
     */
    __unsafe_unretained NSString *title;
    
    /**
     @brief For dictionary entry it will store modification date. For list on simple value it
            will store object index.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *additionalInformation;
    
    /**
     @brief Stores whether this entry can be expanded to view more information or not.
     
     @since <#version number#>
     */
    __unsafe_unretained NSString *isObject;
};

struct PNDictionaryEntryDataStructure PNDictionaryEntryData = {
    
    .key = @"key",
    .title = @"title",
    .additionalInformation = @"additionalInformation"
};



#pragma mark - Private interface declaration

@interface DSDictionaryEntryCell ()


#pragma mark - Properties

/**
 @brief Reference on the label which should represent name of the key under which actual data is
        stored.
 */
@property (nonatomic, weak) IBOutlet UILabel *keyLabel;

/**
 @brief Reference on label which should represent data assigned to the key field.
 
 @since <#version number#>
 */
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

/**
 @brief Every simple value has it's own modification date which will be represented using this 
        label.
 
 @since <#version number#>
 */
@property (nonatomic, weak) IBOutlet UILabel *modificationDateLabel;

@end


#pragma mark - Public interface implementation

@implementation DSDictionaryEntryCell


#pragma mark - Instance methods

- (UIEdgeInsets)layoutMargins {
    
    return UIEdgeInsetsZero;
}

- (void)updateWithData:(NSDictionary *)entryData {
    
    self.keyLabel.text = entryData[PNDictionaryEntryData.key];
    if ([entryData[PNDictionaryEntryData.title] isKindOfClass:[NSNumber class]]) {
        
        self.valueLabel.text = [entryData[PNDictionaryEntryData.title] stringValue];
    }
    else {
        
        self.valueLabel.text = entryData[PNDictionaryEntryData.title];
    }
    self.modificationDateLabel.text = entryData[PNDictionaryEntryData.additionalInformation];
}

#pragma mark -


@end
