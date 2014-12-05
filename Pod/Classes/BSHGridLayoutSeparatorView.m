/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHGridLayoutSeparatorView.h"
#import "BSHCollectionViewGridLayoutAttributes.h"

@implementation BSHGridLayoutSeparatorView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
	if ([layoutAttributes isKindOfClass:BSHCollectionViewGridLayoutAttributes.class]) {
		self.backgroundColor = ((BSHCollectionViewGridLayoutAttributes *)layoutAttributes).backgroundColor;
	} else {
		self.backgroundColor = nil;
	}
}

@end
