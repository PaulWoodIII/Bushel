/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A subclass of BSHDataSource with multiple child data sources, however, only one data source will be visible at a time. Load content messages will be sent only to the selected data source. When selected, if a data source is still in the initial state, it will receive a load content message.
  
 */

#import "BSHDataSource+Subclasses.h"
#import "BSHDataSourceDelegate.h"
#import "BSHSegmentedDataSource.h"
#import "BSHLayoutMetrics.h"
#import "BSHSegmentedHeaderView.h"

NSString * const BSHSegmentedDataSourceHeaderKey = @"BSHSegmentedDataSourceHeaderKey";

@interface BSHSegmentedDataSource () <BSHDataSourceDelegate>
@property (nonatomic, strong) NSMutableArray *mutableDataSources;
@end

@implementation BSHSegmentedDataSource
@synthesize mutableDataSources = _dataSources;

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;

    _dataSources = [NSMutableArray array];
    _shouldDisplayDefaultHeader = YES;

    return self;
}

- (NSUInteger)numberOfSections
{
    return _selectedDataSource.numberOfSections;
}

- (BSHDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex
{
    return [_selectedDataSource dataSourceForSectionAtIndex:sectionIndex];
}

- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    return [_selectedDataSource localIndexPathForGlobalIndexPath:globalIndexPath];
}

- (NSArray *)dataSources
{
    return [NSArray arrayWithArray:_dataSources];
}

- (void)addDataSource:(BSHDataSource *)dataSource
{
    if (![_dataSources count])
        _selectedDataSource = dataSource;
    [_dataSources addObject:dataSource];
    dataSource.delegate = self;
}

- (void)removeDataSource:(BSHDataSource *)dataSource
{
    [_dataSources removeObject:dataSource];
    if (dataSource.delegate == self)
        dataSource.delegate = nil;
}

- (void)removeAllDataSources
{
    for (BSHDataSource *dataSource in _dataSources) {
        if (dataSource.delegate == self)
            dataSource.delegate = nil;
    }

    _dataSources = [NSMutableArray array];
    _selectedDataSource = nil;
}

- (BSHDataSource *)dataSourceAtIndex:(NSInteger)dataSourceIndex
{
    return _dataSources[dataSourceIndex];
}

- (NSInteger)selectedDataSourceIndex
{
    return [_dataSources indexOfObject:_selectedDataSource];
}

- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex
{
    [self setSelectedDataSourceIndex:selectedDataSourceIndex animated:NO];
}

- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex animated:(BOOL)animated
{
    BSHDataSource *dataSource = [_dataSources objectAtIndex:selectedDataSourceIndex];
    [self setSelectedDataSource:dataSource animated:animated completionHandler:nil];
}

- (void)setSelectedDataSource:(BSHDataSource *)selectedDataSource
{
    [self setSelectedDataSource:selectedDataSource animated:NO completionHandler:nil];
}

- (void)setSelectedDataSource:(BSHDataSource *)selectedDataSource animated:(BOOL)animated
{
    [self setSelectedDataSource:selectedDataSource animated:animated completionHandler:nil];
}

- (void)setSelectedDataSource:(BSHDataSource *)selectedDataSource animated:(BOOL)animated completionHandler:(void (^)(BOOL))completion
{
    if (_selectedDataSource == selectedDataSource) {
        if (completion)
            completion(YES);
        return;
    }

    [self willChangeValueForKey:@"selectedDataSource"];
    [self willChangeValueForKey:@"selectedDataSourceIndex"];
    NSAssert([_dataSources containsObject:selectedDataSource], @"selected data source must be contained in this data source");

    BSHDataSource *oldDataSource = _selectedDataSource;
    NSInteger numberOfOldSections = oldDataSource.numberOfSections;
    NSInteger numberOfNewSections = selectedDataSource.numberOfSections;

    BSHDataSourceSectionOperationDirection direction = BSHDataSourceSectionOperationDirectionNone;

    if (animated) {
        NSInteger oldIndex = [_dataSources indexOfObjectIdenticalTo:oldDataSource];
        NSInteger newIndex = [_dataSources indexOfObjectIdenticalTo:selectedDataSource];
        direction = (oldIndex < newIndex) ? BSHDataSourceSectionOperationDirectionRight : BSHDataSourceSectionOperationDirectionLeft;
    }

    NSIndexSet *removedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfOldSections)];;
    NSIndexSet *insertedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfNewSections)];

    _selectedDataSource = selectedDataSource;

    [self didChangeValueForKey:@"selectedDataSource"];
    [self didChangeValueForKey:@"selectedDataSourceIndex"];

    // Update the sections all at once.
    [self notifyBatchUpdate:^{
        if (removedSet)
            [self notifySectionsRemoved:removedSet direction:direction];
        if (insertedSet)
            [self notifySectionsInserted:insertedSet direction:direction];
    } completion:^(BOOL finished) {
        if(completion){
            completion(finished);
        }
    }];

    // If the newly selected data source has never been loaded, load it now
    if ([selectedDataSource.loadingState isEqualToString:BSHLoadStateInitial])
        [selectedDataSource setNeedsLoadContent];

}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_selectedDataSource itemAtIndexPath:indexPath];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedDataSource removeItemAtIndexPath:indexPath];
}

- (void)configureSegmentedControl:(UISegmentedControl *)segmentedControl
{
    NSArray *titles = [self.dataSources valueForKey:@"title"];

    [segmentedControl removeAllSegments];
    [titles enumerateObjectsUsingBlock:^(NSString *segmentTitle, NSUInteger segmentIndex, BOOL *stop) {
        if ([segmentTitle isEqual:[NSNull null]])
            segmentTitle = @"NULL";
        [segmentedControl insertSegmentWithTitle:segmentTitle atIndex:segmentIndex animated:NO];
    }];
    [segmentedControl addTarget:self action:@selector(selectedSegmentIndexChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = self.selectedDataSourceIndex;
}

- (BSHLayoutSupplementaryMetrics *)segmentedControlHeader
{
    if (!self.shouldDisplayDefaultHeader)
        return nil;

    BSHLayoutSupplementaryMetrics *defaultHeader = [self headerForKey:BSHSegmentedDataSourceHeaderKey];
    if (defaultHeader)
        return defaultHeader;

    BSHLayoutSupplementaryMetrics *header = [self newHeaderForKey:BSHSegmentedDataSourceHeaderKey];
    header.supplementaryViewClass = [BSHSegmentedHeaderView class];
    header.shouldPin = YES;
    // Show this header regardless of whether there are items
    header.visibleWhileShowingPlaceholder = YES;
    header.configureView = ^(UICollectionReusableView *headerView, BSHDataSource *dataSource, NSIndexPath *indexPath) {
        BSHSegmentedHeaderView *segmentedHeaderView = (BSHSegmentedHeaderView *)headerView;
        BSHSegmentedDataSource *segmentedDataSource = (BSHSegmentedDataSource *)dataSource;
        [segmentedDataSource configureSegmentedControl:segmentedHeaderView.segmentedControl];
    };

    return header;
}

- (BSHLayoutSectionMetrics *)snapshotMetricsForSectionAtIndex:(NSInteger)sectionIndex
{
    BSHLayoutSupplementaryMetrics *defaultHeader = [self headerForKey:BSHSegmentedDataSourceHeaderKey];
    if (self.shouldDisplayDefaultHeader) {
        if (!defaultHeader)
            [self segmentedControlHeader];
    }
    else {
        if (defaultHeader)
            [self removeHeaderForKey:BSHSegmentedDataSourceHeaderKey];
    }


    BSHLayoutSectionMetrics *metrics = [_selectedDataSource snapshotMetricsForSectionAtIndex:sectionIndex];
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

- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_selectedDataSource collectionView:collectionView sizeFittingSize:size forItemAtIndexPath:indexPath];
}

//- (BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [_selectedDataSource collectionView:collectionView canEditItemAtIndexPath:indexPath];
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [_selectedDataSource collectionView:collectionView canMoveItemAtIndexPath:indexPath];
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    return [_selectedDataSource collectionView:collectionView canMoveItemAtIndexPath:indexPath toIndexPath:destinationIndexPath];
//}
//
//- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    [_selectedDataSource collectionView:collectionView moveItemAtIndexPath:indexPath toIndexPath:destinationIndexPath];
//}


#pragma mark - BSHContentLoading

- (void)loadContent
{
    // Only load the currently selected data source. Others will be loaded as necessary.
    [_selectedDataSource loadContent];
}

- (void)resetContent
{
    for (BSHDataSource *dataSource in self.dataSources)
         [dataSource resetContent];
    [super resetContent];
}

#pragma mark - Placeholders

- (BOOL)shouldDisplayPlaceholder
{
    if ([super shouldDisplayPlaceholder])
        return YES;

    NSString *loadingState = _selectedDataSource.loadingState;

    // If we're in the error state & have an error message or title
    if ([loadingState isEqualToString:BSHLoadStateError] && (_selectedDataSource.errorMessage || _selectedDataSource.errorTitle))
        return YES;

    // Only display a placeholder when we're loading or have no content
    if (![loadingState isEqualToString:BSHLoadStateLoadingContent] && ![loadingState isEqualToString:BSHLoadStateNoContent])
        return NO;

    // Can't display the placeholder if both the title and message is missing
    if (!_selectedDataSource.noContentMessage && !_selectedDataSource.noContentTitle)
        return NO;

    return YES;
}

//- (BSHCollectionPlaceholderView *)dequeuePlaceholderViewForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
//{
//    return [_selectedDataSource dequeuePlaceholderViewForCollectionView:collectionView atIndexPath:indexPath];
//}

- (void)updatePlaceholder:(BSHCollectionPlaceholderView *)placeholderView notifyVisibility:(BOOL)notify
{
    [_selectedDataSource updatePlaceholder:placeholderView notifyVisibility:notify];
}

- (NSString *)noContentMessage
{
    return _selectedDataSource.noContentMessage;
}

- (NSString *)noContentTitle
{
    return _selectedDataSource.noContentTitle;
}

- (UIImage *)noContentImage
{
    return _selectedDataSource.noContentImage;
}

- (NSString *)errorTitle
{
    return _selectedDataSource.errorTitle;
}

- (NSString *)errorMessage
{
    return _selectedDataSource.errorMessage;
}

//- (UIImage *)errorImage
//{
//    return _selectedDataSource.errorImage;
//}

#pragma mark - Header action method

- (void)selectedSegmentIndexChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (![segmentedControl isKindOfClass:[UISegmentedControl class]])
          return;

    segmentedControl.userInteractionEnabled = NO;
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    BSHDataSource *dataSource = self.dataSources[selectedSegmentIndex];
    [self setSelectedDataSource:dataSource animated:YES completionHandler:^(BOOL completed) {
        segmentedControl.userInteractionEnabled = YES;
    }];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.shouldDisplayPlaceholder)
        return 0;

    return [_selectedDataSource collectionView:collectionView numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_selectedDataSource collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    return [_selectedDataSource collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
//}

#pragma mark - BSHDataSourceDelegate methods

- (void)dataSource:(BSHDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyItemsInsertedAtIndexPaths:indexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyItemsRemovedAtIndexPaths:indexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyItemsRefreshedAtIndexPaths:indexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyItemMovedFromIndexPath:fromIndexPath toIndexPaths:newIndexPath];
}

- (void)dataSource:(BSHDataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifySectionsInserted:sections direction:direction];
}

- (void)dataSource:(BSHDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifySectionsRemoved:sections direction:direction];
}

- (void)dataSource:(BSHDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifySectionsRefreshed:sections];
}

- (void)dataSource:(BSHDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(BSHDataSourceSectionOperationDirection)direction
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifySectionMovedFrom:section to:newSection direction:direction];
}

- (void)dataSourceDidReloadData:(BSHDataSource *)dataSource
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyDidReloadData];
}

- (void)dataSource:(BSHDataSource *)dataSource performBatchUpdate:(dispatch_block_t)update completion:(void (^)(BOOL))completion
{
    if (dataSource != _selectedDataSource) {
        if (update)
            update();
        if (completion)
            completion(YES);
        return;
    }

    [self notifyBatchUpdate:update completion:completion];
}

- (void)dataSource:(BSHDataSource *)dataSource didLoadContentWithError:(NSError *)error
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyContentLoadedWithError:error];
}

- (void)dataSourceWillLoadContent:(BSHDataSource *)dataSource
{
    if (dataSource != _selectedDataSource)
        return;

    [self notifyWillLoadContent];
}

@end
