//
//  BSHDataSourceHeader.h
//  AdvancedCollectionView
//
//  Created by Zachary Waldowski on 7/12/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "BSHDataSource.h"

@class BSHCollectionPlaceholderView;

@protocol BSHDataSourceDelegate <NSObject>
@optional

- (void)dataSource:(BSHDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)dataSource:(BSHDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)dataSource:(BSHDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)dataSource:(BSHDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(BSHDataSource *)dataSource didInsertSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction;
- (void)dataSource:(BSHDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections direction:(BSHDataSourceSectionOperationDirection)direction;
- (void)dataSource:(BSHDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection direction:(BSHDataSourceSectionOperationDirection)direction;
- (void)dataSource:(BSHDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections;

- (void)dataSourceDidReloadData:(BSHDataSource *)dataSource;
- (void)dataSource:(BSHDataSource *)dataSource performBatchUpdate:(void(^)(void))update completion:(void(^)(BOOL finished))completion;

/// If the content was loaded successfully, the error will be nil.
- (void)dataSource:(BSHDataSource *)dataSource didLoadContentWithError:(NSError *)error;

/// Called just before a data source begins loading its content.
- (void)dataSourceWillLoadContent:(BSHDataSource *)dataSource;
@end

@interface BSHDataSource ()

/// A delegate object that will receive change notifications from this data source.
@property (nonatomic, weak) id<BSHDataSourceDelegate> delegate;

@end