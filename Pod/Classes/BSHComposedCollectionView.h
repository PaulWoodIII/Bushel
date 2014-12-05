/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
*/

#import <UIKit/UIKit.h>

@class BSHDataSource;

/// Maps global sections to local sections for a given data source
@interface BSHComposedMapping : NSObject <NSCopying>

- (instancetype)initWithDataSource:(BSHDataSource *)dataSource;

/// The data source associated with this mapping
@property (nonatomic, strong) BSHDataSource * dataSource;

/// The number of sections in this mapping
@property (nonatomic, readonly) NSInteger sectionCount;

/// Return the local section for a global section
- (NSUInteger)localSectionForGlobalSection:(NSUInteger)globalSection;

/// Return the global section for a local section
- (NSUInteger)globalSectionForLocalSection:(NSUInteger)localSection;

/// Return a local index path for a global index path
- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath;

/// Return a global index path for a local index path
- (NSIndexPath *)globalIndexPathForLocalIndexPath:(NSIndexPath *)localIndexPath;

/// Return an array of local index paths from an array of global index paths
- (NSArray *)localIndexPathsForGlobalIndexPaths:(NSArray *)globalIndexPaths;

/// Return an array of global index paths from an array of local index paths
- (NSArray *)globalIndexPathsForLocalIndexPaths:(NSArray *)localIndexPaths;

/// Update the mapping of local sections to global sections.
- (NSUInteger)updateMappingsStartingWithGlobalSection:(NSUInteger)globalSection;

@end

@interface BSHComposedCollectionView : NSObject

- (id)initWithView:(UICollectionView *)view mapping:(BSHComposedMapping *)mapping;

@property (nonatomic, readonly) UICollectionView *wrappedView;
@property (nonatomic, retain) BSHComposedMapping *mapping;

@end
