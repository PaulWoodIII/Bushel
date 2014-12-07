/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHCollectionViewGridLayout_Internal.h"
#import "BSHLinearPartition.h"

@implementation BSHGridLayoutSupplementalItemInfo
@end

@implementation BSHGridLayoutItemInfo
@end

@implementation BSHGridLayoutSectionInfo

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;

    _items = [NSMutableArray array];
	_supplementalItemArraysByKind = [NSMutableDictionary dictionary];
    _pinnableHeaderAttributes = [NSMutableArray array];
    
    return self;
}

- (NSMutableArray *)nonPinnableHeaderAttributes
{
    // Lazy initialise this, because it's only used for the global section
    if (_nonPinnableHeaderAttributes)
        return _nonPinnableHeaderAttributes;
    _nonPinnableHeaderAttributes = [NSMutableArray array];
    return _nonPinnableHeaderAttributes;
}

- (BSHGridLayoutSupplementalItemInfo *)addSupplementalItemAsPlaceholder
{
    BSHGridLayoutSupplementalItemInfo *supplementalInfo = [[BSHGridLayoutSupplementalItemInfo alloc] init];
    _placeholder = supplementalInfo;
    return supplementalInfo;
}

- (BSHGridLayoutSupplementalItemInfo *)addSupplementalItemOfKind:(NSString *)supplementalKind
{
	BSHGridLayoutSupplementalItemInfo *supplementalInfo = [[BSHGridLayoutSupplementalItemInfo alloc] init];
	NSMutableArray *items = _supplementalItemArraysByKind[supplementalKind];
	if (!items) {
		items = [NSMutableArray array];
		_supplementalItemArraysByKind[supplementalKind] = items;
	}
	[items addObject:supplementalInfo];
	return supplementalInfo;
}

- (void)enumerateArraysOfOtherSupplementalItems:(void(^)(NSString *kind, NSArray *items, BOOL *stop))block
{
	NSParameterAssert(block != nil);
	[_supplementalItemArraysByKind enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSArray *items, BOOL *stahp) {
		if ([kind isEqual:UICollectionElementKindSectionHeader] || [kind isEqual:UICollectionElementKindSectionFooter]) return;
		block(kind, items, stahp);
	}];
}

- (BSHGridLayoutItemInfo *)addItem
{
    BSHGridLayoutItemInfo *itemInfo = [[BSHGridLayoutItemInfo alloc] init];
    [self.items addObject:itemInfo];
    return itemInfo;
}

- (CGFloat)columnWidth
{
	CGFloat width = self.layoutInfo.size.width;
    UIEdgeInsets margins = self.insets;
    CGFloat columnWidth = (width - margins.left - margins.right);
    return columnWidth;
}

/// Layout all the items in this section and return the total height of the section
- (void)computeLayoutForSection:(NSUInteger)sectionIndex origin:(CGPoint)start measureItem:(CGSize(^)(NSIndexPath *, CGRect))measureItemBlock measureSupplementaryItem:(CGSize(^)(NSString *, NSIndexPath *, CGRect))measureSupplementaryItemBlock
{
	NSIndexPath *(^indexPath)(NSUInteger) = ^(NSUInteger itemIndex){
		if (sectionIndex == BSHGlobalSection) {
			return [NSIndexPath indexPathWithIndex:itemIndex];
		}
		return [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
	};
	
	const CGSize size = self.layoutInfo.size;
	const CGFloat availableHeight = size.height - start.y;
	const CGSize sizeForMeasuring = { size.width, UILayoutFittingExpandedSize.height };
	const UIEdgeInsets margins = self.insets;
	const NSUInteger numberOfItems = self.items.count;
	
	__block CGPoint origin = start;
	
	NSArray *headers = _supplementalItemArraysByKind[UICollectionElementKindSectionHeader],
			*footers = _supplementalItemArraysByKind[UICollectionElementKindSectionFooter];
	
	// First lay out headers
	[headers enumerateObjectsUsingBlock:^(BSHGridLayoutSupplementalItemInfo *headerInfo, NSUInteger headerIndex, BOOL *stop) {
		// skip headers if there are no items and the header isn't a global header
		if (!numberOfItems && !headerInfo.visibleWhileShowingPlaceholder) { return; }
		
		// skip headers that are hidden
		if (headerInfo.hidden) { return; }
		
		// This header needs to be measured!
		if (!headerInfo.height && measureSupplementaryItemBlock) {
			headerInfo.frame = (CGRect){ origin, sizeForMeasuring };
			headerInfo.height = measureSupplementaryItemBlock(UICollectionElementKindSectionHeader, indexPath(headerIndex), headerInfo.frame).height;
		}
		
		headerInfo.frame = (CGRect){ origin, { size.width, headerInfo.height }};
		origin.y += headerInfo.height;
	}];
	
	BSHGridLayoutSupplementalItemInfo *placeholder = self.placeholder;
	if (placeholder) {
		// Height of the placeholder is equal to the height of the collection view minus the height of the headers
		CGFloat height = availableHeight - (origin.y - start.y);
		placeholder.height = height;
		placeholder.frame = (CGRect){ origin, { size.width, height }};
		origin.y += height;
	}

	NSAssert(!placeholder || !numberOfItems, @"Can't have both a placeholder and items");

	// Lay out items, footers, and misc. items only if there actually ARE items.
	if (numberOfItems) {
		CGFloat contentBeginY = origin.y + margins.top;
		__block CGFloat backgroundEndY = contentBeginY;

		[_supplementalItemArraysByKind enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSArray *obj, BOOL *stopA) {
			if ([kind isEqual:UICollectionElementKindSectionHeader] || [kind isEqual:UICollectionElementKindSectionFooter]) { return; }

			[obj enumerateObjectsUsingBlock:^(BSHGridLayoutSupplementalItemInfo *item, NSUInteger itemIndex, BOOL *stopb) {
				// skip hidden supplementary items
				if (item.hidden)
					return;

				// This header needs to be measured!
				if (!item.height && measureSupplementaryItemBlock) {
					item.frame = (CGRect){ origin, sizeForMeasuring };
					item.height = measureSupplementaryItemBlock(kind, indexPath(itemIndex), item.frame).height;
				}

				item.frame = (CGRect){ origin, { size.width, item.height }};
				origin.y += item.height;

				backgroundEndY = MAX(backgroundEndY, origin.y);
			}];

			origin.y = contentBeginY;
		}];
        
        __block CGPoint itemOrigin = CGPointMake( start.x + margins.left, contentBeginY );
        const CGFloat itemWidth = self.columnWidth;
        
        // TODO: Put Waterfall Layout size in here
        
        // Balanced Flow Layout
        if (self.showsItemsInBalancedFlowLayout){
            
            NSInteger itemIndex = 0;
            CGFloat totalItemSize = 0;
            NSMutableArray *weights = [NSMutableArray array];
            for(BSHGridLayoutItemInfo *item in self.items) {
                // Better have the measure block here or it'll not work
                // might want to add an assert that makes you
                if (item.needSizeUpdate && measureItemBlock) {
                    CGSize preferredSize = measureItemBlock(indexPath(itemIndex), CGRectZero);
                    NSInteger aspectRatio = roundf((preferredSize.width / preferredSize.height) * 100);
                    [weights addObject:@(aspectRatio)];
                    if (preferredSize.height > 0) {
                        totalItemSize += (preferredSize.width / preferredSize.height) * availableHeight/1.61803399;
                    }
                }
                else {
                    item.frame = CGRectZero;
                }
                itemIndex++;
            }
            NSInteger numberOfRows = MAX(roundf(totalItemSize / availableHeight), 1);
            
            NSArray *partition = [BSHLinearPartition linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
            
            int i = 0;
            
            //Offset for each Row
            CGPoint offset = itemOrigin;

            // Size of this Row
            CGFloat previousItemSize = 0;
            
            // Amount to add after items are calculated
            CGFloat contentMaxValueInScrollDirection = 0;
            
            for (NSArray *row in partition) {
                
                CGFloat summedRatios = 0;
                for (NSInteger j = i, n = i + [row count]; j < n; j++) {
                    CGSize preferredSize = measureItemBlock(indexPath(j), CGRectZero);
                    summedRatios += preferredSize.width / preferredSize.height;
                }
                
                CGFloat rowSize = (size.width - (margins.left + margins.right)) - (([row count] - 1) * margins.bottom);
                for (NSInteger j = i, n = i + [row count]; j < n; j++) {
                    CGSize preferredSize = measureItemBlock(indexPath(j), CGRectZero);
                    
                    CGSize actualSize = CGSizeZero;
                    actualSize = CGSizeMake(roundf(rowSize / summedRatios * (preferredSize.width / preferredSize.height)), roundf(rowSize / summedRatios));
                    CGRect frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height);
                    
                    BSHGridLayoutItemInfo *item = self.items[j];
                    item.frame = frame;

                    offset.x += actualSize.width + margins.bottom;
                    previousItemSize = actualSize.height;
                    contentMaxValueInScrollDirection = CGRectGetMaxY(frame);
                }
                
                /**
                 * Check if row actually contains any items before changing offset,
                 * because linear partitioning algorithm might return a row with no items.
                 */
                if ([row count] > 0) {
                    // move offset to next line
                    offset = CGPointMake(itemOrigin.x, offset.y + previousItemSize + margins.bottom);
                }
                
                i += [row count];
            }
            origin.y = MAX(backgroundEndY, offset.y) + margins.bottom;
        }
        // Grid Layout
        else{
            [self.items enumerateObjectsUsingBlock:^(BSHGridLayoutItemInfo *item, NSUInteger itemIndex, BOOL *stop) {
                CGRect itemFrame = (CGRect){ itemOrigin, { itemWidth, CGRectGetHeight(item.frame) }};
                if (itemFrame.size.height == BSHRowHeightRemainder) {
                    itemFrame.size.height = size.height - itemFrame.origin.y;
                }

                if (item.needSizeUpdate && measureItemBlock) {
                    item.needSizeUpdate = NO;
                    item.frame = itemFrame;
                    itemFrame.size.height = measureItemBlock(indexPath(itemIndex), itemFrame).height;
                    item.frame = itemFrame;
                }
                else {
                    item.frame = itemFrame;
                }

                itemOrigin.y += itemFrame.size.height;
            }];
            origin.y = MAX(backgroundEndY, itemOrigin.y) + margins.bottom;
        }
        

		// lay out all footers
		for (BSHGridLayoutSupplementalItemInfo *footerInfo in footers) {
			// skip hidden footers
			if (footerInfo.hidden)
				continue;
			// When showing the placeholder, we don't show footers
			CGFloat height = footerInfo.height;
			footerInfo.frame = (CGRect){ origin, { size.width, height }};
			origin.y += height;
		}

	}

	self.frame = (CGRect){ start, { size.width, origin.y - start.y }};
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p %@>", NSStringFromClass(self.class), (__bridge void *)self, NSStringFromCGRect(_frame)];
}

#if DEBUG
- (NSString *)recursiveDescription __unused
{
    NSMutableString *result = [NSMutableString string];
    [result appendString:[self description]];

	NSArray *headers = _supplementalItemArraysByKind[UICollectionElementKindSectionHeader];
	NSArray *footers = _supplementalItemArraysByKind[UICollectionElementKindSectionFooter];
	NSUInteger others = _supplementalItemArraysByKind.count - (headers ? 1 : 0) - (footers ? 1 : 0);

	if (headers.count) {
        [result appendString:@"\n    headers = @[\n"];

		for (BSHGridLayoutSupplementalItemInfo *header in headers) {
            [result appendFormat:@"        %@\n", header];
        }

		[result appendString:@"    ]"];
    }

    if (_placeholder) {
        [result appendFormat:@"\n    placeholder = %@", _placeholder];
    }

	if (_items.count) {
		[result appendString:@"\n    items = @[\n"];

		for (BSHGridLayoutItemInfo *items in _items) {
			[result appendFormat:@"        %@\n", items];
		}

        [result appendString:@"    ]"];
	}

	if (footers.count) {
		[result appendString:@"\n    footers = @[\n"];
		for (BSHGridLayoutSupplementalItemInfo *footer in footers) {
			[result appendFormat:@"        %@\n", footer];
		}
		[result appendString:@"     ]"];
	}

	if (others) {
		[result appendString:@"\n    others = @[\n"];

		[self enumerateArraysOfOtherSupplementalItems:^(NSString *kind, NSArray *items, BOOL *stahp) {
			[result appendFormat:@"        %@ = @[\n", kind];

			for (BSHGridLayoutSupplementalItemInfo *item in items) {
				[result appendFormat:@"            %@\n", item];
			}

			[result appendString:@"         ]\n"];
		}];

		[result appendString:@"     ]"];
	}

    return result;
}
#endif

@end



@implementation BSHGridLayoutInfo

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    _sections = [NSMutableDictionary dictionary];
    return self;
}

- (BSHGridLayoutSectionInfo *)addSectionWithIndex:(NSInteger)sectionIndex
{
    BSHGridLayoutSectionInfo *section = [[BSHGridLayoutSectionInfo alloc] init];
    section.layoutInfo = self;
    self.sections[@(sectionIndex)] = section;
    return section;
}

- (void)invalidate
{
    [self.sections removeAllObjects];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p size=%@ contentOffsetY=%g>", NSStringFromClass([self class]), (__bridge void *)self, NSStringFromCGSize(_size), _contentOffsetY];
}

#if DEBUG
- (NSString *)recursiveDescription __unused
{
    NSMutableString *result = [NSMutableString string];
    [result appendString:[self description]];

    if ([_sections count]) {
        [result appendString:@"\n    sections = @[\n"];

        NSArray *descriptions = [_sections valueForKey:@"recursiveDescription"];
        [result appendFormat:@"        %@\n", [descriptions componentsJoinedByString:@"\n        "]];
        [result appendString:@"    ]"];
    }

    return result;
}
#endif

@end

@implementation BSHIndexPathKind

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath kind:(NSString *)kind
{
	self = [super init];
	if (!self) return nil;
	
	_indexPath = [indexPath copy];
	_kind = [kind copy];
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSUInteger)hash
{
	NSUInteger prime = 31;
	NSUInteger result = 1;
	
	result = prime * result + [_indexPath hash];
	result = prime * result + [_kind hash];
	return result;
}

- (BOOL)isEqual:(id)object
{
	if (self == object)
		return YES;
	
	if (![object isKindOfClass:BSHIndexPathKind.class])
		return NO;
	
	BSHIndexPathKind *other = object;
	
	if (_indexPath == other->_indexPath && _kind == other->_kind)
		return YES;
	
	if (!_indexPath || ![_indexPath isEqual:other->_indexPath])
		return NO;
	
	return _kind && [_kind isEqualToString:other->_kind];
}

@end
