/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHDataSource.h"

/// A subclass of ITCDataSource that manages a single section of items backed by an NSArray.
@interface BSHBasicDataSource : BSHDataSource

/// The items represented by this data source. This property is KVC compliant for mutable changes via -mutableArrayValueForKey:.
@property (nonatomic, copy) NSArray *items;

/// Set the items with optional animation. By default, setting the items is not animated.
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end
