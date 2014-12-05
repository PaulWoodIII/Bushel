/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHComposedDataSource.h"
#import "BSHDataSource+Subclasses.h"
#import "BSHComposedCollectionView.h"

@interface BSHComposedDataSource () <BSHDataSourceDelegate>
@property (nonatomic, retain) NSMutableArray *mappings;
@property (nonatomic, retain) NSMapTable *dataSourceToMappings;
@property (nonatomic, retain) NSMutableDictionary *globalSectionToMappings;
@property (nonatomic) NSUInteger sectionCount;
@property (nonatomic, readonly) NSArray *dataSources;
@property (nonatomic, strong) NSString *aggregateLoadingState;
@end

@implementation BSHComposedDataSource

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;

    _mappings = [[NSMutableArray alloc] init];
    _dataSourceToMappings = [[NSMapTable alloc] initWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory capacity:1];
    _globalSectionToMappings = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)updateMappings
{
    _sectionCount = 0;
    [_globalSectionToMappings removeAllObjects];

    for (BSHComposedMapping *mapping in _mappings) {
        NSUInteger newSectionCount = [mapping updateMappingsStartingWithGlobalSection:_sectionCount];
        while (_sectionCount < newSectionCount)
            _globalSectionToMappings[@(_sectionCount++)] = mapping;
    }
}

- (BSHDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex
{
    BSHComposedMapping *mapping = _globalSectionToMappings[@(sectionIndex)];
    return mapping.dataSource;
}

- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    BSHComposedMapping *mapping = [self mappingForGlobalSection:globalIndexPath.section];
    return [mapping localIndexPathForGlobalIndexPath:globalIndexPath];
}

- (BSHComposedMapping *)mappingForGlobalSection:(NSInteger)section
{
    BSHComposedMapping *mapping = _globalSectionToMappings[@(section)];
    return mapping;
}

- (BSHComposedMapping *)mappingForDataSource:(BSHDataSource *)dataSource
{
    BSHComposedMapping *mapping = [_dataSourceToMappings objectForKey:dataSource];
    return mapping;
}

- (NSArray *)dataSources
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[_dataSourceToMappings count]];
    for (id key in _dataSourceToMappings) {
        BSHComposedMapping *mapping = [_dataSourceToMappings objectForKey:key];
        [result addObject:mapping.dataSource];
    }
    return result;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHComposedMapping *mapping = [self mappingForGlobalSection:indexPath.section];

    NSIndexPath *mappedIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];

    return [mapping.dataSource itemAtIndexPath:mappedIndexPath];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHComposedMapping *mapping = [self mappingForGlobalSection:indexPath.section];
    BSHDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];

    [dataSource removeItemAtIndexPath:localIndexPath];
}

#pragma mark - BSHComposedDataSource API

- (void)addDataSource:(BSHDataSource *)dataSource
{
    NSParameterAssert(dataSource != nil);

    dataSource.delegate = self;

    BSHComposedMapping *mappingForDataSource = [_dataSourceToMappings objectForKey:dataSource];
    NSAssert(mappingForDataSource == nil, @"tried to add data source more than once: %@", dataSource);

    mappingForDataSource = [[BSHComposedMapping alloc] initWithDataSource:dataSource];
    [_mappings addObject:mappingForDataSource];
    [_dataSourceToMappings setObject:mappingForDataSource forKey:dataSource];

    [self updateMappings];
    NSMutableIndexSet *addedSections = [NSMutableIndexSet indexSet];
    NSInteger numberOfSections = dataSource.numberOfSections;

    for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx)
        [addedSections addIndex:[mappingForDataSource globalSectionForLocalSection:sectionIdx]];
}

- (void)removeDataSource:(BSHDataSource *)dataSource __unused {
    BSHComposedMapping *mappingForDataSource = [_dataSourceToMappings objectForKey:dataSource];
    NSAssert(mappingForDataSource != nil, @"Data source not found in mapping");

    NSMutableIndexSet *removedSections = [NSMutableIndexSet indexSet];
    NSInteger numberOfSections = dataSource.numberOfSections;

    for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx)
        [removedSections addIndex:[mappingForDataSource globalSectionForLocalSection:sectionIdx]];

    [_dataSourceToMappings removeObjectForKey:dataSource];
    [_mappings removeObject:mappingForDataSource];

    dataSource.delegate = nil;

    [self updateMappings];
}

#pragma mark - BSHDataSource methods

- (NSUInteger)numberOfSections
{
    [self updateMappings];
    return _sectionCount;
}

- (BSHLayoutSectionMetrics *)snapshotMetricsForSectionAtIndex:(NSInteger)sectionIndex
{
    BSHComposedMapping *mapping = [self mappingForGlobalSection:sectionIndex];
    NSInteger localSection = [mapping localSectionForGlobalSection:(NSUInteger)sectionIndex];
    BSHDataSource *dataSource = mapping.dataSource;

    BSHLayoutSectionMetrics *metrics = [dataSource snapshotMetricsForSectionAtIndex:localSection];
    BSHLayoutSectionMetrics *enclosingMetrics = [super snapshotMetricsForSectionAtIndex:sectionIndex];

    [enclosingMetrics applyValuesFromMetrics:metrics];
    return enclosingMetrics;
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    [super registerReusableViewsWithCollectionView:collectionView];

    for (BSHDataSource *dataSource in self.dataSources)
        [dataSource registerReusableViewsWithCollectionView:collectionView];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPathIsHidden:(NSIndexPath *)indexPath
{
	BSHComposedMapping *mapping = [self mappingForGlobalSection:indexPath.section];
	BSHComposedCollectionView *wrapper = [[BSHComposedCollectionView alloc] initWithView:collectionView mapping:mapping];
	BSHDataSource *dataSource = mapping.dataSource;
	NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];
	
	return [dataSource collectionView:(id)wrapper itemAtIndexPathIsHidden:localIndexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHComposedMapping *mapping = [self mappingForGlobalSection:indexPath.section];
	BSHComposedCollectionView *wrapper = [[BSHComposedCollectionView alloc] initWithView:collectionView mapping:mapping];
    BSHDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];

    return [dataSource collectionView:(id)wrapper sizeFittingSize:size forItemAtIndexPath:localIndexPath];
}

#pragma mark - BSHContentLoading

- (void)updateLoadingState
{
    // let's find out what our state should be by asking our data sources
    NSInteger numberOfLoading = 0;
    NSInteger numberOfRefreshing = 0;
    NSInteger numberOfError = 0;
    NSInteger numberOfLoaded = 0;
    NSInteger numberOfNoContent = 0;

    NSArray *loadingStates = [self.dataSources valueForKey:@"loadingState"];
    loadingStates = [loadingStates arrayByAddingObject:[super loadingState]];

    for (NSString *state in loadingStates) {
        if ([state isEqualToString:BSHLoadStateLoadingContent])
            numberOfLoading++;
        else if ([state isEqualToString:BSHLoadStateRefreshingContent])
            numberOfRefreshing++;
        else if ([state isEqualToString:BSHLoadStateError])
            numberOfError++;
        else if ([state isEqualToString:BSHLoadStateContentLoaded])
            numberOfLoaded++;
        else if ([state isEqualToString:BSHLoadStateNoContent])
            numberOfNoContent++;
    }

//    NSLog(@"Composed.loadingState: loading = %d  refreshing = %d  error = %d  no content = %d  loaded = %d", numberOfLoading, numberOfRefreshing, numberOfError, numberOfNoContent, numberOfLoaded);

    // Always prefer loading
    if (numberOfLoading)
        _aggregateLoadingState = BSHLoadStateLoadingContent;
    else if (numberOfRefreshing)
        _aggregateLoadingState = BSHLoadStateRefreshingContent;
    else if (numberOfError)
        _aggregateLoadingState = BSHLoadStateError;
    else if (numberOfNoContent)
        _aggregateLoadingState = BSHLoadStateNoContent;
    else if (numberOfLoaded)
        _aggregateLoadingState = BSHLoadStateContentLoaded;
    else
        _aggregateLoadingState = BSHLoadStateInitial;
}

- (NSString *)loadingState
{
    if (!_aggregateLoadingState)
        [self updateLoadingState];
    return _aggregateLoadingState;
}

- (void)setLoadingState:(NSString *)loadingState
{
    _aggregateLoadingState = nil;
    [super setLoadingState:loadingState];
}

- (void)loadContent
{
    for (BSHDataSource *dataSource in self.dataSources)
        [dataSource loadContent];
}

- (void)resetContent
{
    _aggregateLoadingState = nil;
    [super resetContent];
    for (BSHDataSource *dataSource in self.dataSources)
        [dataSource resetContent];
}

- (void)stateDidChangeFrom:(NSString *)oldState to:(NSString *)newState
{
    [super stateDidChangeFrom:oldState to:newState];
    [self updateLoadingState];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [self updateMappings];

    BSHComposedMapping *mapping = [self mappingForGlobalSection:section];
	BSHComposedCollectionView *wrapper = [[BSHComposedCollectionView alloc] initWithView:collectionView mapping:mapping];
    NSInteger localSection = [mapping localSectionForGlobalSection:(NSUInteger)section];
    BSHDataSource *dataSource = mapping.dataSource;

    NSInteger numberOfSections = [dataSource numberOfSectionsInCollectionView:(id)wrapper];
    NSAssert(localSection < numberOfSections, @"local section is out of bounds for composed data source");

    // If we're showing the placeholder, ignore what the child data sources have to say about the number of items.
    if (self.obscuredByPlaceholder)
        return 0;
    
    return [dataSource collectionView:(id)wrapper numberOfItemsInSection:localSection];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHComposedMapping *mapping = [self mappingForGlobalSection:indexPath.section];
	BSHComposedCollectionView *wrapper = [[BSHComposedCollectionView alloc] initWithView:collectionView mapping:mapping];
    BSHDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];

    return [dataSource collectionView:(id)wrapper cellForItemAtIndexPath:localIndexPath];
}

#pragma mark - BSHDataSourceDelegate

- (void)dataSource:(BSHDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];
    NSArray *globalIndexPaths = [mapping globalIndexPathsForLocalIndexPaths:indexPaths];

    [self notifyItemsInsertedAtIndexPaths:globalIndexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];
    NSArray *globalIndexPaths = [mapping globalIndexPathsForLocalIndexPaths:indexPaths];

    [self notifyItemsRemovedAtIndexPaths:globalIndexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];
    NSArray *globalIndexPaths = [mapping globalIndexPathsForLocalIndexPaths:indexPaths];

    [self notifyItemsRefreshedAtIndexPaths:globalIndexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];
    NSIndexPath *globalFromIndexPath = [mapping globalIndexPathForLocalIndexPath:fromIndexPath];
    NSIndexPath *globalNewIndexPath = [mapping globalIndexPathForLocalIndexPath:newIndexPath];

    [self notifyItemMovedFromIndexPath:globalFromIndexPath toIndexPaths:globalNewIndexPath];
}

- (void)dataSource:(BSHDataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];

    [self updateMappings];

    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
        [globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
    }];

    [self notifySectionsInserted:globalSections direction:direction];
}

- (void)dataSource:(BSHDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];

    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
        [globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
    }];

    [self updateMappings];

    [self notifySectionsRemoved:globalSections direction:direction];
}

- (void)dataSource:(BSHDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];

    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
        [globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
    }];

    [self notifySectionsRefreshed:globalSections];
    [self updateMappings];
}

- (void)dataSource:(BSHDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(BSHDataSourceSectionOperationDirection)direction
{
    BSHComposedMapping *mapping = [self mappingForDataSource:dataSource];

    NSInteger globalSection = [mapping globalSectionForLocalSection:(NSUInteger)section];
    NSInteger globalNewSection = [mapping globalSectionForLocalSection:(NSUInteger)newSection];

    [self updateMappings];

    [self notifySectionMovedFrom:globalSection to:globalNewSection direction:direction];
}

- (void)dataSourceDidReloadData:(BSHDataSource *)dataSource
{
    [self notifyDidReloadData];
}

- (void)dataSource:(BSHDataSource *)dataSource performBatchUpdate:(void(^)(void))update completion:(void (^)(BOOL))completion
{
    [self notifyBatchUpdate:update completion:completion];
}

/// If the content was loaded successfully, the error will be nil.
- (void)dataSource:(BSHDataSource *)dataSource didLoadContentWithError:(NSError *)error
{
    BOOL showingPlaceholder = self.shouldDisplayPlaceholder;
	
    [self updateLoadingState];

    // We were showing the placeholder and now we're not
	if (showingPlaceholder && !self.shouldDisplayPlaceholder) {
        [self notifyBatchUpdate:^{
            [self executePendingUpdates];
        } completion:NULL];
	}

    [self notifyContentLoadedWithError:error];
}

/// Called just before a data source begins loading its content.
- (void)dataSourceWillLoadContent:(BSHDataSource *)dataSource
{
    [self updateLoadingState];
    [self notifyWillLoadContent];
}

@end
