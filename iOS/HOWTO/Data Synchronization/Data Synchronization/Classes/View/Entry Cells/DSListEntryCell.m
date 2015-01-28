//
//  DSListEntryCell.m
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/27/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "DSListEntryCell.h"


#pragma mark Types & Structures

struct PNListEntryDataStructure {
    
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
};

struct PNListEntryDataStructure PNListEntryData = {
    
    .title = @"title",
    .additionalInformation = @"additionalInformation"
};



#pragma mark - Private interface declaration

@interface DSListEntryCell ()


#pragma mark - Properties

/**
 @brief Reference on value which should be shown for list entry.
 */
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

/**
 @brief Stores reference on index under which entry is stored inside of list.
 
 @since <#version number#>
 */
@property (nonatomic, weak) IBOutlet UILabel *sortingIndexLabel;


#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation DSListEntryCell


#pragma mark - Instance methods

- (UIEdgeInsets)layoutMargins {
    
    return UIEdgeInsetsZero;
}

- (void)updateWithData:(NSDictionary *)entryData {
    
    if ([entryData[PNListEntryData.title] isKindOfClass:[NSNumber class]]) {
        
        self.titleLabel.text = [entryData[PNListEntryData.title] stringValue];
    }
    else if ([entryData[PNListEntryData.title] isKindOfClass:[NSNull class]]) {
        
        self.titleLabel.text = @"<null>";
    }
    else {
        
        self.titleLabel.text = entryData[PNListEntryData.title];
    }
    self.sortingIndexLabel.text = entryData[PNListEntryData.additionalInformation];
}


#pragma mark -


@end
