/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHCollectionViewGridLayout.h"
#import "BSHCollectionViewGridLayoutAttributes.h"
#import "BSHDataSourceDelegate.h"
#import "BSHLayoutMetrics.h"

typedef CGSize (^BSHLayoutMeasureBlock)(NSUInteger itemIndex, CGRect frame);
typedef CGSize (^BSHLayoutMeasureKindBlock)(NSString *kind, NSUInteger itemIndex, CGRect frame);

@class BSHGridLayoutInfo;

/// Layout information about a supplementary item (header, footer, or placeholder)
@interface BSHGridLayoutSupplementalItemInfo : NSObject
@property (nonatomic) CGRect frame;
@property (nonatomic) CGFloat height;
@property (nonatomic) BOOL shouldPin;
@property (nonatomic) BOOL visibleWhileShowingPlaceholder;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *selectedBackgroundColor;
@property (nonatomic) BOOL hidden;
@property (nonatomic) UIEdgeInsets padding;
@property (nonatomic) NSInteger zIndex;

@end

/// Layout information about an item (cell)
@interface BSHGridLayoutItemInfo : NSObject

@property (nonatomic) CGRect frame;
@property (nonatomic) BOOL needSizeUpdate;

@end

/// Layout information for a section
@interface BSHGridLayoutSectionInfo : NSObject {
    // For Linear Partition
    CGRect **_itemFrameSections;
    NSInteger _numberOfItemFrameSections;
}

@property (nonatomic) CGRect frame;
@property (nonatomic, weak) BSHGridLayoutInfo *layoutInfo;

@property (nonatomic, readonly) NSMutableArray *items;
@property (nonatomic, readonly) NSMutableDictionary *supplementalItemArraysByKind;
- (void)enumerateArraysOfOtherSupplementalItems:(void(^)(NSString *kind, NSArray *items, BOOL *stop))block;
@property (nonatomic, readonly) BSHGridLayoutSupplementalItemInfo *placeholder;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) UIEdgeInsets separatorInsets;
@property (nonatomic) UIEdgeInsets sectionSeparatorInsets;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIColor *separatorColor;
@property (nonatomic, strong) UIColor *sectionSeparatorColor;
@property (nonatomic) BOOL showsSectionSeparatorWhenLastSection;
@property (nonatomic) BOOL showsItemsInBalancedFlowLayout;
@property (nonatomic, readonly) CGFloat columnWidth;

@property (nonatomic, strong) NSMutableArray *pinnableHeaderAttributes;
@property (nonatomic, strong) NSMutableArray *nonPinnableHeaderAttributes;
@property (nonatomic, strong) BSHCollectionViewGridLayoutAttributes *backgroundAttribute;

- (BSHGridLayoutSupplementalItemInfo *)addSupplementalItemOfKind:(NSString *)kind;
- (BSHGridLayoutSupplementalItemInfo *)addSupplementalItemAsPlaceholder;
- (BSHGridLayoutItemInfo *)addItem;

- (void)computeLayoutForSection:(NSUInteger)sectionIndex origin:(CGPoint)start measureItem:(CGSize(^)(NSIndexPath *, CGRect))measureItemBlock measureSupplementaryItem:(CGSize(^)(NSString *, NSIndexPath *, CGRect))measureSupplementaryItemBlock;

@end

/// The layout information
@interface BSHGridLayoutInfo : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat contentOffsetY;
@property (nonatomic, strong) NSMutableDictionary *sections;

- (BSHGridLayoutSectionInfo *)addSectionWithIndex:(NSInteger)sectionIndex;

- (void)invalidate;

@end

/// Used to look up supplementary & decoration attributes
@interface BSHIndexPathKind : NSObject<NSCopying>

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath kind:(NSString *)kind;

@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSString *kind;

@end
