/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHDataSource+Subclasses.h"
#import "BSHCollectionViewGridLayout.h"
#import "BSHPlaceholderView.h"
#import <libkern/OSAtomic.h>

static void *BSHDataSourceLoadingCompleteContext = &BSHDataSourceLoadingCompleteContext;

#define BSH_ASSERT_MAIN_THREAD NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

@interface BSHDataSource () <BSHStateMachineDelegate>
@property (nonatomic, strong) NSMutableDictionary *sectionMetrics;
@property (nonatomic, strong) NSMutableArray *headers;
@property (nonatomic, strong) NSMutableDictionary *headersByKey;
@property (nonatomic, strong) BSHStateMachine *stateMachine;
@property (nonatomic, strong) BSHCollectionPlaceholderView *placeholderView;
@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
@property (nonatomic) BOOL loadingComplete;
@property (nonatomic, weak) BSHLoading *loadingInstance;
@property (nonatomic, copy) dispatch_block_t loadingCompleteBlock;
@property (nonatomic, readonly, getter = isRootDataSource) BOOL rootDataSource;
@end

@implementation BSHDataSource {
	OSSpinLock _loadingCompleteLock;
	int32_t _loadingCompleteObserverToken;
	
}

@synthesize loadingError = _loadingError;

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
	
	
	_loadingCompleteLock = OS_SPINLOCK_INIT;
    _defaultMetrics = [[BSHLayoutSectionMetrics alloc] init];
	
    return self;
}

- (BOOL)isRootDataSource
{
    id delegate = self.delegate;
    return ![delegate isKindOfClass:BSHDataSource.class];
}

- (BSHDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex
{
    return self;
}

- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    return globalIndexPath;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return;
}

- (NSUInteger)numberOfSections
{
    return 1;
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    NSUInteger numberOfSections = self.numberOfSections;

    BSHLayoutSectionMetrics *globalMetrics = [self snapshotMetricsForSectionAtIndex:BSHGlobalSection];
	for (BSHLayoutSupplementaryMetrics *supplMetrics in globalMetrics.supplementaryViews) {
		if (![supplMetrics.supplementaryViewKind isEqual:UICollectionElementKindSectionHeader]) continue;
		[collectionView registerClass:supplMetrics.supplementaryViewClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:supplMetrics.reuseIdentifier];
	}

    for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; ++sectionIndex) {
        BSHLayoutSectionMetrics *metrics = [self snapshotMetricsForSectionAtIndex:sectionIndex];

		for (BSHLayoutSupplementaryMetrics *supplMetrics in metrics.supplementaryViews) {
			[collectionView registerClass:supplMetrics.supplementaryViewClass forSupplementaryViewOfKind:supplMetrics.supplementaryViewKind withReuseIdentifier:supplMetrics.reuseIdentifier];
		}
    }

	[collectionView registerClass:[BSHCollectionPlaceholderView class] forSupplementaryViewOfKind:BSHCollectionElementKindPlaceholder withReuseIdentifier:NSStringFromClass([BSHCollectionPlaceholderView class])];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPathIsHidden:(NSIndexPath *)indexPath
{
	return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return size;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == BSHDataSourceLoadingCompleteContext) {
		BOOL loadingComplete = [change[NSKeyValueChangeNewKey] boolValue];
		if (!loadingComplete) { return; }
		
		if (OSAtomicCompareAndSwap32(1, 0, &_loadingCompleteObserverToken)) {
			[object removeObserver:self forKeyPath:keyPath context:context];
		}
		
		dispatch_block_t block = NULL;
		OSSpinLockLock(&_loadingCompleteLock);
		block = [self.loadingCompleteBlock copy];
		self.loadingCompleteBlock = NULL;
		OSSpinLockUnlock(&_loadingCompleteLock);
		
		if (block) {
			block();
		}
		
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - BSHContentLoading methods

- (BSHStateMachine *)stateMachine
{
    if (_stateMachine) return _stateMachine;
	_stateMachine = [BSHStateMachine loadableContentStateMachine];
    _stateMachine.delegate = self;
    return _stateMachine;
}

- (NSString *)loadingState
{
    // Don't cause the creation of the state machine just by inspection of the loading state.
    if (!_stateMachine)
        return BSHLoadStateInitial;
    return _stateMachine.currentState;
}

- (void)setLoadingState:(NSString *)loadingState
{
    BSHStateMachine *stateMachine = self.stateMachine;
    if (loadingState != stateMachine.currentState)
        stateMachine.currentState = loadingState;
}

- (void)beginLoading
{
    self.loadingComplete = NO;
    self.loadingState = (([self.loadingState isEqualToString:BSHLoadStateInitial] || [self.loadingState isEqualToString:BSHLoadStateLoadingContent]) ? BSHLoadStateLoadingContent : BSHLoadStateRefreshingContent);

    [self notifyWillLoadContent];
}

- (void)endLoadingWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    self.loadingError = error;
    self.loadingState = state;

    if (self.shouldDisplayPlaceholder) {
        if (update)
            [self enqueuePendingUpdateBlock:update];
    }
    else {
        [self notifyBatchUpdate:^{
            // Run pending updates
            [self executePendingUpdates];
			if (update) { update(); }
        } completion:NULL];
    }

    self.loadingComplete = YES;
    [self notifyContentLoadedWithError:error];
}

- (void)setNeedsLoadContent
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadContent) object:nil];
        [self performSelector:@selector(loadContent) withObject:nil afterDelay:0];
    });
    

}

- (void)log{
    NSLog(@"Log");
}

- (void)resetContent
{
    _stateMachine = nil;
    // Content has been reset, if we're loading something, chances are we don't need it.
    self.loadingInstance.current = NO;
}

- (void)loadContent
{
    // To be implemented by subclasses…
}

- (void)loadContentWithBlock:(void(^)(BSHLoading *))block
{
    [self beginLoading];

    __weak typeof(&*self) weakself = self;

    BSHLoading *loading = [[BSHLoading alloc] initWithCompletionHandler:^(NSString *newState, NSError *error, BSHLoadingUpdateBlock update){
        if (!newState)
            return;

        [self endLoadingWithState:newState error:error update:^{
            BSHDataSource *me = weakself;
            if (update && me)
                update(me);
        }];
    }];

    // Tell previous loading instance it's no longer current and remember this loading instance
    self.loadingInstance.current = NO;
    self.loadingInstance = loading;
    
    // Call the provided block to actually do the load
    block(loading);
}

- (void)whenLoaded:(dispatch_block_t)block {
	NSParameterAssert(block != nil);

	OSSpinLockLock(&_loadingCompleteLock);
	if (!_loadingCompleteBlock) {
		self.loadingCompleteBlock = block;
	} else {
		// chain the old with the new
		dispatch_block_t oldBlock = _loadingCompleteBlock;
		self.loadingCompleteBlock = ^{
			oldBlock();
			block();
		};
	}
	OSSpinLockUnlock(&_loadingCompleteLock);
		
	if (OSAtomicCompareAndSwap32(0, 1, &_loadingCompleteObserverToken)) {
		[self addObserver:self forKeyPath:@"loadingComplete" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:BSHDataSourceLoadingCompleteContext];
	}
}

- (void)stateWillChangeFrom:(NSString *)oldState to:(NSString *)newState
{
    // loadingState property isn't really Key Value Compliant, so let's begin a change notification
    [self willChangeValueForKey:@"loadingState"];
}

- (void)stateDidChangeFrom:(NSString *)oldState to:(NSString *)newState
{
	if (![newState isEqualToString:BSHLoadStateInitial] && ![newState isEqualToString:BSHLoadStateRefreshingContent]) {
		[self updatePlaceholder:self.placeholderView notifyVisibility:YES];
	}

	// loadingState property isn't really Key Value Compliant, so let's finish a change notification
    [self didChangeValueForKey:@"loadingState"];
}

#pragma mark - UICollectionView metrics

- (BSHLayoutSectionMetrics *)defaultMetrics
{
    if (_defaultMetrics)
        return _defaultMetrics;
    _defaultMetrics = [BSHLayoutSectionMetrics defaultMetrics];
    return _defaultMetrics;
}

- (BSHLayoutSectionMetrics *)metricsForSectionAtIndex:(NSInteger)sectionIndex
{
    if (!_sectionMetrics)
        _sectionMetrics = [NSMutableDictionary dictionary];
    return _sectionMetrics[@(sectionIndex)];
}

- (void)setMetrics:(BSHLayoutSectionMetrics *)metrics forSectionAtIndex:(NSInteger)sectionIndex
{
    NSParameterAssert(metrics != nil);
    if (!_sectionMetrics)
        _sectionMetrics = [NSMutableDictionary dictionary];

    _sectionMetrics[@(sectionIndex)] = metrics;
}

- (BSHLayoutSectionMetrics *)snapshotMetricsForSectionAtIndex:(NSInteger)sectionIndex
{
    BSHLayoutSectionMetrics *metrics = [self.defaultMetrics copy];
	BSHLayoutSectionMetrics *submetrics = [self metricsForSectionAtIndex:sectionIndex];
    [metrics applyValuesFromMetrics:submetrics];

    // The root data source puts its headers into the special global section. Other data sources put theirs into their 0 section.
    BOOL rootDataSource = self.rootDataSource;
    if (rootDataSource && BSHGlobalSection == sectionIndex) {
		metrics.supplementaryViews = [NSArray arrayWithArray:_headers];
    }

    // We need to handle global headers and the placeholder view for section 0
    if (!sectionIndex) {
        NSMutableArray *headers = [NSMutableArray array];

        if (_headers && !rootDataSource)
            [headers addObjectsFromArray:_headers];

        metrics.hasPlaceholder = self.shouldDisplayPlaceholder;

		if (metrics.supplementaryViews)
			[headers addObjectsFromArray:metrics.supplementaryViews];

		metrics.supplementaryViews = headers;
    }
    
    return metrics;
}

- (NSDictionary *)snapshotMetrics
{
    NSUInteger numberOfSections = self.numberOfSections;
    NSMutableDictionary *metrics = [NSMutableDictionary dictionary];

    UIColor *defaultBackground = [UIColor whiteColor];

    BSHLayoutSectionMetrics *globalMetrics = [self snapshotMetricsForSectionAtIndex:BSHGlobalSection];
    if (!globalMetrics.backgroundColor)
        globalMetrics.backgroundColor = defaultBackground;
    metrics[@(BSHGlobalSection)] = globalMetrics;

    for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; ++sectionIndex) {
        BSHLayoutSectionMetrics *sectionMetrics = [self snapshotMetricsForSectionAtIndex:sectionIndex];
        // assign default colors
        if (!sectionMetrics.backgroundColor)
            sectionMetrics.backgroundColor = defaultBackground;
        metrics[@(sectionIndex)] = sectionMetrics;
    }

    return metrics;
}

- (BSHLayoutSupplementaryMetrics *)headerForKey:(NSString *)key
{
    return _headersByKey[key];
}

- (BSHLayoutSupplementaryMetrics *)newHeaderForKey:(NSString *)key
{
    if (!_headers)
        _headers = [NSMutableArray array];
    if (!_headersByKey)
        _headersByKey = [NSMutableDictionary dictionary];

    NSAssert(!_headersByKey[key], @"Attempting to add a header for a key that already exists: %@", key);

	BSHLayoutSupplementaryMetrics *header = [[BSHLayoutSupplementaryMetrics alloc] initWithSupplementaryViewKind:UICollectionElementKindSectionHeader];
    _headersByKey[key] = header;
    [_headers addObject:header];
    return header;
}

- (void)replaceHeaderForKey:(NSString *)key withHeader:(BSHLayoutSupplementaryMetrics *)header
{
    if (!_headers)
        _headers = [NSMutableArray array];
    if (!_headersByKey)
        _headersByKey = [NSMutableDictionary dictionary];

    BSHLayoutSupplementaryMetrics *oldHeader = _headersByKey[key];
    NSAssert(oldHeader != nil, @"Attempting to replace a header that doesn't exist: key = %@", key);

    NSUInteger headerIndex = [_headers indexOfObject:oldHeader];
    _headersByKey[key] = header;
    _headers[headerIndex] = header;
}

- (void)removeHeaderForKey:(NSString *)key {
    if (!_headers)
        _headers = [NSMutableArray array];
    if (!_headersByKey)
        _headersByKey = [NSMutableDictionary dictionary];

    BSHLayoutSupplementaryMetrics *oldHeader = _headersByKey[key];
    NSAssert(oldHeader != nil, @"Attempting to remove a header that doesn't exist: key = %@", key);

    [_headers removeObject:oldHeader];
    [_headersByKey removeObjectForKey:key];
}

#pragma mark - Placeholder

- (BOOL)obscuredByPlaceholder
{
    if (self.shouldDisplayPlaceholder)
        return YES;

    if (!self.delegate)
        return NO;

    if (![self.delegate isKindOfClass:[BSHDataSource class]])
        return NO;

    BSHDataSource *dataSource = (BSHDataSource *)self.delegate;
    return dataSource.obscuredByPlaceholder;
}

- (BOOL)shouldDisplayPlaceholder
{
    NSString *loadingState = self.loadingState;

    // If we're in the error state & have an error message or title
    if ([loadingState isEqualToString:BSHLoadStateError] && (self.errorMessage || self.errorTitle))
        return YES;

    // Only display a placeholder when we're loading or have no content
    if (![loadingState isEqualToString:BSHLoadStateLoadingContent] && ![loadingState isEqualToString:BSHLoadStateNoContent])
        return NO;

    // Can't display the placeholder if both the title and message are missing
	return self.noContentMessage || self.noContentTitle;
}

- (void)updatePlaceholder:(BSHCollectionPlaceholderView *)placeholderView notifyVisibility:(BOOL)notify
{
    NSString *message;
    NSString *title;

    if (placeholderView) {
        NSString *loadingState = self.loadingState;
	    [placeholderView showActivityIndicator:[loadingState isEqualToString:BSHLoadStateLoadingContent]];

        if ([loadingState isEqualToString:BSHLoadStateNoContent]) {
            title = self.noContentTitle;
            message = self.noContentMessage;
            [placeholderView showPlaceholderWithTitle:title message:message image:self.noContentImage animated:YES];
        }
        else if ([loadingState isEqualToString:BSHLoadStateError]) {
            title = self.errorTitle;
            message = self.errorMessage;
            [placeholderView showPlaceholderWithTitle:title message:message image:self.noContentImage animated:YES];
        }
        else
            [placeholderView hidePlaceholderAnimated:YES];
    }

    if (notify && (self.noContentTitle || self.noContentMessage || self.errorTitle || self.errorMessage))
        [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)]];
}

- (BSHCollectionPlaceholderView *)dequeuePlaceholderViewForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath
{
    if (!_placeholderView)
        _placeholderView = [collectionView dequeueReusableSupplementaryViewOfKind:BSHCollectionElementKindPlaceholder withReuseIdentifier:NSStringFromClass([BSHCollectionPlaceholderView class]) forIndexPath:indexPath];
    [self updatePlaceholder:_placeholderView notifyVisibility:NO];
    return _placeholderView;
}

#pragma mark - Notification methods

- (void)executePendingUpdates
{
    BSH_ASSERT_MAIN_THREAD;
    dispatch_block_t block = _pendingUpdateBlock;
    _pendingUpdateBlock = nil;
    if (block)
        block();
}

- (void)enqueuePendingUpdateBlock:(dispatch_block_t)block
{
    dispatch_block_t update;

    if (_pendingUpdateBlock) {
        dispatch_block_t oldPendingUpdate = _pendingUpdateBlock;
        update = ^{
            oldPendingUpdate();
            block();
        };
    }
    else
        update = block;

    self.pendingUpdateBlock = update;
}

- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths
{
    BSH_ASSERT_MAIN_THREAD;
    if (self.shouldDisplayPlaceholder) {
        __weak typeof(&*self) weakself = self;
        [self enqueuePendingUpdateBlock:^{
            [weakself notifyItemsInsertedAtIndexPaths:insertedIndexPaths];
        }];
        return;
    }

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertItemsAtIndexPaths:)]) {
        [delegate dataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths];
    }
}

- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths
{
    BSH_ASSERT_MAIN_THREAD;
    if (self.shouldDisplayPlaceholder) {
        __weak typeof(&*self) weakself = self;
        [self enqueuePendingUpdateBlock:^{
            [weakself notifyItemsRemovedAtIndexPaths:removedIndexPaths];
        }];
        return;
    }

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:)]) {
        [delegate dataSource:self didRemoveItemsAtIndexPaths:removedIndexPaths];
    }
}

- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths
{
    BSH_ASSERT_MAIN_THREAD;
    if (self.shouldDisplayPlaceholder) {
        __weak typeof(&*self) weakself = self;
        [self enqueuePendingUpdateBlock:^{
            [weakself notifyItemsRefreshedAtIndexPaths:refreshedIndexPaths];
        }];
        return;
    }

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshItemsAtIndexPaths:)]) {
        [delegate dataSource:self didRefreshItemsAtIndexPaths:refreshedIndexPaths];
    }
}

- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPaths:(NSIndexPath *)newIndexPath
{
    BSH_ASSERT_MAIN_THREAD;
    if (self.shouldDisplayPlaceholder) {
        __weak typeof(&*self) weakself = self;
        [self enqueuePendingUpdateBlock:^{
            [weakself notifyItemMovedFromIndexPath:indexPath toIndexPaths:newIndexPath];
        }];
        return;
    }

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveItemAtIndexPath:toIndexPath:)]) {
        [delegate dataSource:self didMoveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

- (void)notifySectionsInserted:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
    BSH_ASSERT_MAIN_THREAD;

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertSections:direction:)]) {
        [delegate dataSource:self didInsertSections:sections direction:direction];
    }
}

- (void)notifySectionsRemoved:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
    BSH_ASSERT_MAIN_THREAD;

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveSections:direction:)]) {
        [delegate dataSource:self didRemoveSections:sections direction:direction];
    }
}

- (void)notifySectionsRefreshed:(NSIndexSet *)sections
{
    BSH_ASSERT_MAIN_THREAD;

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshSections:)]) {
        [delegate dataSource:self didRefreshSections:sections];
    }
}

- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection direction:(BSHDataSourceSectionOperationDirection)direction
{
    BSH_ASSERT_MAIN_THREAD;

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveSection:toSection:direction:)]) {
        [delegate dataSource:self didMoveSection:section toSection:newSection direction:direction];
    }
}

- (void)notifyDidReloadData
{
    BSH_ASSERT_MAIN_THREAD;

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidReloadData:)]) {
        [delegate dataSourceDidReloadData:self];
    }
}

- (void)notifyBatchUpdate:(void(^)(void))update completion:(void(^)(BOOL))completion
{
    BSH_ASSERT_MAIN_THREAD;

    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:performBatchUpdate:completion:)]) {
        [delegate dataSource:self performBatchUpdate:update completion:completion];
    } else {
        if (update) { update(); }
        if (completion) { completion(YES); }
    }
}

- (void)notifyContentLoadedWithError:(NSError *)error
{
    BSH_ASSERT_MAIN_THREAD;
    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didLoadContentWithError:)]) {
        [delegate dataSource:self didLoadContentWithError:error];
    }
}

- (void)notifyWillLoadContent
{
    BSH_ASSERT_MAIN_THREAD;
    id<BSHDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceWillLoadContent:)]) {
        [delegate dataSourceWillLoadContent:self];
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.numberOfSections;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:BSHCollectionElementKindPlaceholder])
        return [self dequeuePlaceholderViewForCollectionView:collectionView atIndexPath:indexPath];

    NSUInteger section, item;
    BSHDataSource *dataSource;

    if (indexPath.length == 1) {
        section = BSHGlobalSection;
        item = [indexPath indexAtPosition:0];
        dataSource = self;
    }
    else if (indexPath.length > 1) {
        section = [indexPath indexAtPosition:0];
        item = [indexPath indexAtPosition:1];
        dataSource = [self dataSourceForSectionAtIndex:section];
    } else {
	    return nil;
    }

    BSHLayoutSectionMetrics *sectionMetrics = [self snapshotMetricsForSectionAtIndex:section];
	NSIndexSet *matching = [sectionMetrics.supplementaryViews indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(BSHLayoutSupplementaryMetrics *metrics, NSUInteger idx, BOOL *stop) {
		return [metrics.supplementaryViewKind isEqual:kind];
	}];

	if (item >= matching.count) { return nil; }

	BSHLayoutSupplementaryMetrics *metrics = [sectionMetrics.supplementaryViews objectsAtIndexes:matching][item];

    // Need to map the global index path to an index path relative to the target data source, because we're handling this method at the root of the data source tree. If I allowed subclasses to handle this, this wouldn't be necessary. But because of the way headers layer, it's more efficient to snapshot the section and find the metrics once.
    NSIndexPath *localIndexPath = [self localIndexPathForGlobalIndexPath:indexPath];
    UICollectionReusableView *view;
    if (metrics.createView)
        view = metrics.createView(collectionView, kind, metrics.reuseIdentifier, localIndexPath);
    else
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:metrics.reuseIdentifier forIndexPath:indexPath];

    NSAssert(view != nil, @"Unable to dequeue a reusable view with identifier %@", metrics.reuseIdentifier);
    if (!view)
        return nil;

    if (metrics.configureView)
        metrics.configureView(view, dataSource, localIndexPath);

    return view;
}

@end
