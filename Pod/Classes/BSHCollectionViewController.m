/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHCollectionViewController.h"
#import "BSHDataSourceDelegate.h"

static void *BSHDataSourceContext = &BSHDataSourceContext;

@interface BSHCollectionViewController () <BSHDataSourceDelegate>

@property (nonatomic, assign) BOOL loadedFirstTime;

@end

@implementation BSHCollectionViewController

- (void)loadView
{
    [super loadView];
    self.loadedFirstTime = NO;
    //  We need to know when the data source changes on the collection view so we can become the delegate for any APPLDataSource subclasses.
    [self.collectionView addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:BSHDataSourceContext];
}

- (void)dealloc
{
	[self.collectionView removeObserver:self forKeyPath:@"dataSource" context:BSHDataSourceContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UICollectionView *collectionView = self.collectionView;
    
    BSHDataSource *dataSource = (BSHDataSource *)collectionView.dataSource;
    if (!self.loadedFirstTime && [dataSource isKindOfClass:BSHDataSource.class]) {
        self.loadedFirstTime = YES;
        [dataSource registerReusableViewsWithCollectionView:collectionView];
        [dataSource setNeedsLoadContent];
    }
}

- (void)setCollectionView:(UICollectionView *)collectionView
{
    UICollectionView *oldCollectionView = self.collectionView;

    // Always call super, because we don't know EXACTLY what UICollectionViewController does in -setCollectionView:.
    [super setCollectionView:collectionView];

    [oldCollectionView removeObserver:self forKeyPath:@"dataSource" context:BSHDataSourceContext];

    //  We need to know when the data source changes on the collection view so we can become the delegate for any APPLDataSource subclasses.
    [collectionView addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:BSHDataSourceContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //  For change contexts that aren't the data source, pass them to super.
	if (context == BSHDataSourceContext) {
		UICollectionView *collectionView = object;
		BSHDataSource *dataSource = (BSHDataSource *)collectionView.dataSource;
		if ([dataSource isKindOfClass:BSHDataSource.class]) {
			if (!dataSource.delegate)
				dataSource.delegate = self;
		}
		
		return;
	}
	
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - BSHDataSourceDelegate methods

- (void)dataSource:(BSHDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)dataSource:(BSHDataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
	id <BSHDataSourceDelegate> layout = (id <BSHDataSourceDelegate>)self.collectionView.collectionViewLayout;
	if ([layout conformsToProtocol:@protocol(BSHDataSourceDelegate)] && [layout respondsToSelector:@selector(dataSource:didInsertSections:direction:)]) {
		[layout dataSource:dataSource didInsertSections:sections direction:direction];
	}
    [self.collectionView insertSections:sections];
}

- (void)dataSource:(BSHDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction
{
	id <BSHDataSourceDelegate> layout = (id <BSHDataSourceDelegate>)self.collectionView.collectionViewLayout;
	if ([layout conformsToProtocol:@protocol(BSHDataSourceDelegate)] && [layout respondsToSelector:@selector(dataSource:didRemoveSections:direction:)]) {
		[layout dataSource:dataSource didRemoveSections:sections direction:direction];
	}
    [self.collectionView deleteSections:sections];
}

- (void)dataSource:(BSHDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(BSHDataSourceSectionOperationDirection)direction
{
	id <BSHDataSourceDelegate> layout = (id <BSHDataSourceDelegate>)self.collectionView.collectionViewLayout;
	if ([layout conformsToProtocol:@protocol(BSHDataSourceDelegate)] && [layout respondsToSelector:@selector(dataSource:didMoveSection:toSection:direction:)]) {
		[layout dataSource:dataSource didMoveSection:section toSection:newSection direction:direction];
	}
    [self.collectionView moveSection:section toSection:newSection];
}

- (void)dataSource:(BSHDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)dataSource:(BSHDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections
{
	[self.collectionView reloadSections:sections];
}

- (void)dataSourceDidReloadData:(BSHDataSource *)dataSource
{
    [self.collectionView reloadData];
}

- (void)dataSource:(BSHDataSource *)dataSource performBatchUpdate:(void(^)(void))update completion:(void (^)(BOOL))completion
{
    [self.collectionView performBatchUpdates:update completion:completion];
}

@end
