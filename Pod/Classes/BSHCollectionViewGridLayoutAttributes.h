/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import <UIKit/UIKit.h>

@interface BSHCollectionViewGridLayoutAttributes : UICollectionViewLayoutAttributes

/// If this is a header, is it pinned to the top of the collection view?
@property (nonatomic, getter = isPinnedHeader) BOOL pinnedHeader;
/// The background color for the view
@property (nonatomic) UIColor *backgroundColor;
/// The background color when selected
@property (nonatomic) UIColor *selectedBackgroundColor;
/// Used by supplementary items
@property (nonatomic) UIEdgeInsets padding;
/// Y offset when not pinned
@property (nonatomic) CGFloat unpinnedY;

@end

/// A subclass of UICollectionViewLayoutInvalidationContext that adds invalidation for metrics and origin
@interface BSHGridLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic) BOOL invalidateLayoutMetrics;
@property (nonatomic) BOOL invalidateLayoutOrigin;

@end
