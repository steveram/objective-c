//
//  DSListEntryCell.h
//  Data Synchronization
//
//  Created by Sergey Mamontov on 1/27/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark Public interface declaration

@interface DSListEntryCell : UITableViewCell


#pragma mark - Instance methods

/**
 @brief Use provided data to update inner cell field for correct representation of the data.
 
 @param entryData Reference on dictionary which holds data for representation.
 */
- (void)updateWithData:(NSDictionary *)entryData;

#pragma mark -


@end
