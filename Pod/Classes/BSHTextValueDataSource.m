/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A data source that populates its cells based on key/value information from a source object. The items in the data source are NSDictionary instances with the keys @"label" and @"keyPath". Any items for which the object does not have a value will not be displayed.
  This is a tad more complex than BSHKeyValueDataSource, because each item will be used to create a single item section. The value of the label will be used to create a section header.
  
 */

#import "BSHTextValueDataSource.h"
#import "BSHDataSource+Subclasses.h"
#import "BSHTextValueCell.h"
#import "BSHSectionHeaderView.h"
#import "UICollectionReusableView+BSHGridLayout.h"

static NSString * const BSHTextValueDataSourceKeyPathKey = @"keyPath";
static NSString * const BSHTextValueDataSourceLabelKey = @"label";

@interface BSHTextValueDataSource ()
@property (nonatomic, strong) id object;
@end

@implementation BSHTextValueDataSource

@synthesize items = _items;

- (instancetype)init
{
    return [self initWithObject:nil];
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (!self)
        return nil;

    _object = object;

    self.defaultMetrics.selectedBackgroundColor = nil;

    // Create a section header that will pull the text of the header from the label of the item.
    BSHLayoutSupplementaryMetrics *header = [self.defaultMetrics newHeader];
    header.supplementaryViewClass = [BSHSectionHeaderView class];
	[header configureWithBlock:^(BSHSectionHeaderView *header, BSHTextValueDataSource *dataSource, NSIndexPath *indexPath) {
		NSDictionary *dictionary = dataSource.items[indexPath.section];
		header.leftLabel.text = dictionary[BSHTextValueDataSourceLabelKey];
	}];

    return self;
}

- (void)setObject:(id)object
{
    if (object == _object)
        return;
    _object = object;
    [self notifySectionsRefreshed:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)]];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return _items[indexPath.section];
}

- (NSUInteger)numberOfSections
{
    return [_items count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.obscuredByPlaceholder)
        return 0;

    NSDictionary *dictionary = _items[section];
    NSString *keyPath = dictionary[BSHTextValueDataSourceKeyPathKey];
    NSString *value = [self.object valueForKeyPath:keyPath];

    if (value)
        return 1;
    else
        return 0;
}

- (void)setItems:(NSArray *)items
{
    NSInteger oldNumberOfSections = self.numberOfSections;
    _items = [items copy];

    NSInteger newNumberOfSections = [_items count];

    NSIndexSet *refreshedSet;
    NSIndexSet *removedSet;
    NSIndexSet *insertedSet;

    if (newNumberOfSections == oldNumberOfSections)
        refreshedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)];
    else if (newNumberOfSections < oldNumberOfSections) {
        refreshedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNumberOfSections)];
        removedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newNumberOfSections, oldNumberOfSections - newNumberOfSections)];
    }
    else if (newNumberOfSections > oldNumberOfSections) {
        refreshedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldNumberOfSections)];
        insertedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(oldNumberOfSections, newNumberOfSections - oldNumberOfSections)];
    }

    if (refreshedSet)
        [self notifySectionsRefreshed:refreshedSet];
    if (insertedSet)
        [self notifySectionsInserted:insertedSet direction:BSHDataSourceSectionOperationDirectionNone];
    if (removedSet)
        [self notifySectionsRemoved:removedSet direction:BSHDataSourceSectionOperationDirectionNone];
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[BSHTextValueCell class] forCellWithReuseIdentifier:NSStringFromClass([BSHTextValueCell class])];
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHTextValueCell *cell = (BSHTextValueCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    CGSize fittingSize = [cell BSH_preferredLayoutSizeFittingSize:size];
    [cell removeFromSuperview];
    return fittingSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHTextValueCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BSHTextValueCell class]) forIndexPath:indexPath];
    NSDictionary *dictionary = [self itemAtIndexPath:indexPath];

    NSString *value = [self.object valueForKeyPath:dictionary[BSHTextValueDataSourceKeyPathKey]];

    [cell configureWithText:value];
    return cell;
}

@end
