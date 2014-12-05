//
//  BSHExampleDataSource.m
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHExampleDataSource.h"
#import <Bushel/BSHImageTextCell.h>

@implementation BSHExampleDataSource

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[BSHImageTextCell class] forCellWithReuseIdentifier:NSStringFromClass([BSHImageTextCell class])];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [self itemAtIndexPath:indexPath];
    BSHImageTextCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BSHImageTextCell class]) forIndexPath:indexPath];
    
    cell.primaryLabel.text = dictionary[BSHDataSourceTitleKey];
    [cell.imageView setImage:[UIImage imageNamed:dictionary[BSHDataSourceImageNameKey]]];
    
    if ([dictionary[BSHDataSourceActiveKey] boolValue]) {
        [cell.primaryLabel setTextColor:[UIColor blackColor]];
        [cell.imageView setTintColor:[UIColor blackColor]];
    }
    else{
        [cell.primaryLabel setTextColor:[UIColor lightGrayColor]];
        [cell.imageView setTintColor:[UIColor lightGrayColor]];
    }
    
    return cell;
}

@end
