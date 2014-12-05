/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHPinnableHeaderView.h"
#import "BSHCollectionViewGridLayout.h"
#import "UIView+BSHAdditions.h"

@interface BSHPinnableHeaderView ()
@property (nonatomic) BOOL pinned;
@property (nonatomic) UIView *borderView;
@property (nonatomic) UIColor *backgroundColorBeforePinning;
@end

@implementation BSHPinnableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;

    self.backgroundColor = [UIColor whiteColor];

    _bottomBorderColor = [UIColor colorWithWhite:0.8 alpha:1];
    _bottomBorderColorWhenPinned = [UIColor colorWithWhite:0.8 alpha:1];
	_borderView = [self BSH_addSeparatorToEdge:CGRectMaxYEdge color:_bottomBorderColor];

    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _pinned = NO;
    _bottomBorderColor = [UIColor colorWithWhite:0.8 alpha:1];
    _bottomBorderColorWhenPinned = [UIColor colorWithWhite:0.8 alpha:1];
	_borderView.backgroundColor = _bottomBorderColor;
    _backgroundColorWhenPinned = nil;
	self.highlighted = NO;
}

- (UIEdgeInsets)defaultPadding
{
    return UIEdgeInsetsZero;
}

- (void)setPadding:(UIEdgeInsets)padding
{
    if (UIEdgeInsetsEqualToEdgeInsets(padding, _padding))
        return;
    _padding = padding;
    [self setNeedsUpdateConstraints];
}

- (void)setBottomBorderColor:(UIColor *)bottomBorderColor
{
    _bottomBorderColor = bottomBorderColor;
    if (!self.pinned) {
        _borderView.backgroundColor = bottomBorderColor;
        _borderView.hidden = (bottomBorderColor == nil);
    }
}

- (void)setBottomBorderColorWhenPinned:(UIColor *)bottomBorderColorWhenPinned
{
    _bottomBorderColorWhenPinned = bottomBorderColorWhenPinned;
    if (self.pinned) {
        _borderView.backgroundColor = bottomBorderColorWhenPinned;
        _borderView.hidden = (bottomBorderColorWhenPinned == nil);
    }
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)regularLayoutAttributes {
	self.hidden = regularLayoutAttributes.hidden;
	self.userInteractionEnabled = YES;

	BSHCollectionViewGridLayoutAttributes *layoutAttributes = (BSHCollectionViewGridLayoutAttributes *)regularLayoutAttributes;
	if (![layoutAttributes isKindOfClass:BSHCollectionViewGridLayoutAttributes.class])
		return;

	if (UIEdgeInsetsEqualToEdgeInsets(layoutAttributes.padding, UIEdgeInsetsZero)) {
		self.padding = self.defaultPadding;
	} else {
		self.padding = layoutAttributes.padding;
	}

    // If we're not pinned, then immediately set the background colour, otherwise, remember it for when we restore the background color
    if (!_pinned)
        self.backgroundColor = layoutAttributes.backgroundColor;
    else
        _backgroundColorBeforePinning = layoutAttributes.backgroundColor;

    BOOL isPinned = layoutAttributes.pinnedHeader;

	if (isPinned != _pinned) {
        [UIView animateWithDuration:0.25 animations:^{
            if (isPinned) {
                _backgroundColorBeforePinning = self.backgroundColor;
                if (self.backgroundColorWhenPinned)
                    self.backgroundColor = self.backgroundColorWhenPinned;
            }
            else {
                self.backgroundColor = _backgroundColorBeforePinning;
            }

            self.pinned = isPinned;

            BOOL showBorder = YES;
            UIColor *borderColor = self.bottomBorderColor;

            if (isPinned && self.bottomBorderColorWhenPinned)
                borderColor = self.bottomBorderColorWhenPinned;

            if (!borderColor)
                showBorder = NO;
            
            _borderView.backgroundColor = borderColor;
            _borderView.hidden = !showBorder;
        }];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.highlighted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.highlighted = NO;
}

@end
