/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHCollectionViewGridLayoutAttributes.h"

@implementation BSHCollectionViewGridLayoutAttributes

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [super hash];
    result = prime * result + _pinnedHeader;
    result = prime * result + [_backgroundColor hash];
    result = prime * result + [_selectedBackgroundColor hash];
    result = (NSUInteger)(prime * result + _padding.top);
    result = (NSUInteger)(prime * result + _padding.left);
    result = (NSUInteger)(prime * result + _padding.bottom);
    result = (NSUInteger)(prime * result + _padding.right);

	return result;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[BSHCollectionViewGridLayoutAttributes class]])
        return NO;

    BSHCollectionViewGridLayoutAttributes *other = object;
    if (![super isEqual:other])
        return NO;

    if (_pinnedHeader != other->_pinnedHeader)
        return NO;

    if (_backgroundColor != other->_backgroundColor && ![_backgroundColor isEqual:other->_backgroundColor])
        return NO;

    if (_selectedBackgroundColor != other->_selectedBackgroundColor && ![_selectedBackgroundColor isEqual:other->_selectedBackgroundColor])
        return NO;

	return UIEdgeInsetsEqualToEdgeInsets(_padding, other->_padding);
}

- (id)copyWithZone:(NSZone *)zone
{
    BSHCollectionViewGridLayoutAttributes *attributes = (BSHCollectionViewGridLayoutAttributes *)[super copyWithZone:zone];
    attributes->_backgroundColor = _backgroundColor;
    attributes->_pinnedHeader = _pinnedHeader;
    attributes->_backgroundColor = _backgroundColor;
    attributes->_selectedBackgroundColor = _selectedBackgroundColor;
    attributes->_padding = _padding;
    attributes->_unpinnedY = _unpinnedY;
    return attributes;
}

@end

#pragma mark -

@implementation BSHGridLayoutInvalidationContext

- (instancetype)init
{
	self = [super init];
	if (!self)
		return nil;
	_invalidateLayoutMetrics = YES;
	return self;
}

@end
