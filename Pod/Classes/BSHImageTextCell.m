//
//  SZAImageTextCell.m
//  Shazart
//
//  Created by Paul Wood III on 11/28/14.
//  Copyright (c) 2014 TMCL. All rights reserved.
//

#import "BSHImageTextCell.h"

@interface BSHImageTextCell ()
@property (nonatomic, strong, readwrite) UILabel *primaryLabel;
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *constraints;
@end

@implementation BSHImageTextCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    UIView *contentView = self.contentView;
    UIFont *defaultFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    _primaryLabel = [[UILabel alloc] init];
    _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _primaryLabel.numberOfLines = 1;
    _primaryLabel.font = defaultFont;
    _primaryLabel.textAlignment = NSTextAlignmentLeft;
    [contentView addSubview:_primaryLabel];

    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.contentMode = UIViewContentModeCenter;
    [contentView addSubview:_imageView];
    
    return self;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets(contentInsets, _contentInsets))
        return;
    _contentInsets = contentInsets;
    [self invalidateConstraints];
}

- (void)updateConstraints
{
    if (_constraints) {
        [super updateConstraints];
        return;
    }
    
    UIView *contentView = self.contentView;
    
    _constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_primaryLabel, _imageView);

    [_constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_imageView(44)]-10-[_primaryLabel]-10-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:views]];
    [_constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_constraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [_constraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:contentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self.contentView addConstraints:_constraints];
    
    [super updateConstraints];
}

- (void)invalidateConstraints
{
    if (_constraints) {
        [self.contentView removeConstraints:_constraints];
    }
    _constraints = nil;
    [self setNeedsUpdateConstraints];
}

@end
