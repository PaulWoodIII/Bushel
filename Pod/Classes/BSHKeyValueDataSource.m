/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A data source that populates its cells based on key/value information from a source object. The items in the data source are NSDictionary instances with the keys @"label" and @"keyPath". Any items for which the object does not have a value will not be displayed.
  
 */

#import "BSHKeyValueDataSource.h"
#import "BSHBasicCell.h"

#import "UICollectionReusableView+BSHGridLayout.h"


static NSString * const BSHKeyValueDataSourceKeyPathKey = @"keyPath";
static NSString * const BSHKeyValueDataSourceLabelKey = @"label";

@interface BSHKeyValueDataSource ()
@property (nonatomic, strong) id object;
@end

@implementation BSHKeyValueDataSource

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
    return self;
}

- (void)updateObject:(id)obj{
    self.object = obj;
}

- (void)setItems:(NSArray *)items
{
    // Filter out any items that don't have a value, because it looks sloppy when rows have a label but no value
    NSMutableArray *newItems = [NSMutableArray array];
    for (NSDictionary *dictionary in items) {
        id value = [self.object valueForKeyPath:dictionary[BSHKeyValueDataSourceKeyPathKey]];
        if (value)
            [newItems addObject:dictionary];
    }
    [super setItems:newItems];
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[BSHBasicCell class] forCellWithReuseIdentifier:NSStringFromClass([BSHBasicCell class])];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [self itemAtIndexPath:indexPath];
    BSHBasicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BSHBasicCell class]) forIndexPath:indexPath];

    cell.primaryLabel.text = dictionary[BSHKeyValueDataSourceLabelKey];
    cell.secondaryLabel.text = [self.object valueForKeyPath:dictionary[BSHKeyValueDataSourceKeyPathKey]];
    return cell;
}

@end
