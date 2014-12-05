/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHSectionHeaderView.h"

@interface BSHSectionHeaderView ()
@property (nonatomic, readwrite, strong) UILabel *leftLabel;
@property (nonatomic, readwrite, strong) UILabel *rightLabel;
@property (nonatomic, strong, readwrite) UIButton *actionButton;
@property (nonatomic, strong) NSArray *constraints;
@end

@implementation BSHSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;

    // default section header views don't have bottom borders
    self.bottomBorderColor = nil;
    self.bottomBorderColorWhenPinned = nil;

    _leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _leftLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self addSubview:_leftLabel];

    _rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    _rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self addSubview:_rightLabel];

    [self setNeedsUpdateConstraints];

    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_actionButton removeFromSuperview];
    _actionButton = nil;
    _leftLabel.text = nil;
    _rightLabel.text = nil;
    self.bottomBorderColor = nil;
    self.bottomBorderColorWhenPinned = nil;
}

- (UIEdgeInsets)defaultPadding
{
    return UIEdgeInsetsMake(15, 15, 5, 15);
}

- (void)updateConstraints
{
    if (_constraints) {
        [super updateConstraints];
        return;
    }

    UIEdgeInsets padding = self.padding;
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *metrics = @{
        @"TopMargin" : @(padding.top),
        @"LeftMargin" : @(padding.left),
        @"BottomMargin" : @(padding.bottom),
        @"RightMargin" : @(padding.right)
    };
    NSDictionary *views;

    if (_actionButton) {
        views = NSDictionaryOfVariableBindings(_leftLabel, _rightLabel, _actionButton);
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(LeftMargin)-[_leftLabel]-(>=10)-[_rightLabel]-5-[_actionButton]-(RightMargin)-|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:views]];
    }
    else {
        views = NSDictionaryOfVariableBindings(_leftLabel, _rightLabel);
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(LeftMargin)-[_leftLabel]-(>=10)-[_rightLabel]-(RightMargin)-|" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:views]];
    }

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(TopMargin)-[_leftLabel]-(BottomMargin)-|" options:0 metrics:metrics views:views]];

    _constraints = constraints;
    [self addConstraints:constraints];

    [super updateConstraints];
}

- (void)setNeedsUpdateConstraints
{
    if (_constraints)
        [self removeConstraints:_constraints];
    _constraints = nil;
    [super setNeedsUpdateConstraints];
}

- (UIButton *)actionButton
{
    if (_actionButton)
        return _actionButton;

    _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    _actionButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [_actionButton setTitleColor:[UIColor colorWithWhite:116.0f/255.0f alpha:1] forState:UIControlStateDisabled];
    [self addSubview:_actionButton];
    [self setNeedsUpdateConstraints];

    return _actionButton;
}
@end
