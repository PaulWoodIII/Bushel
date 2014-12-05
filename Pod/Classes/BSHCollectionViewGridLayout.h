/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import <UIKit/UIKit.h>

#import "BSHCollectionViewGridLayoutAttributes.h"

extern NSUInteger const BSHGlobalSection;

extern NSString * const BSHCollectionElementKindPlaceholder;

@interface BSHCollectionViewGridLayout : UICollectionViewLayout

/// Recompute the layout for a specific item. This will remeasure the cell and then update the layout.
- (void)invalidateLayoutForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
