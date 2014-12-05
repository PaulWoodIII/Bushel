/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A simple BSHCollectionViewCell that displays a large block of text.
  
 */

#import "BSHTextValueCell.h"

@interface BSHTextValueCell ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation BSHTextValueCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;

    UIView *contentView = self.contentView;

    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.font = [UIFont systemFontOfSize:12];
    _label.textColor = [UIColor colorWithWhite:77/255.0 alpha:1];
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.numberOfLines = 0;
    [contentView addSubview:_label];

    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_label);

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_label]-15-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_label]-3-|" options:0 metrics:nil views:views]];

    [contentView addConstraints:constraints];

    return self;
}

- (void)configureWithText:(NSString *)text
{
    _label.text = text;
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;
    _label.preferredMaxLayoutWidth = CGRectGetWidth(bounds) - 30;
    [super layoutSubviews];
}

@end
