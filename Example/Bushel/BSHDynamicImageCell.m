//
//  SZAArtworkCell.m
//  Shazart
//
//  Created by Paul Wood III on 10/9/14.
//  Copyright (c) 2014 TMCL. All rights reserved.
//

#import "BSHDynamicImageCell.h"
#import "BSHArtworkObject.h"
#import "SZAPlaceholderView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BSHDynamicImageCell ()
@property (nonatomic, strong) SZAPlaceholderView *placeholder;
@end

@implementation BSHDynamicImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    UIView *contentView = self.contentView;
    
    _placeholder = [[SZAPlaceholderView alloc] init];
    _placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    [_placeholder setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [contentView addSubview:_placeholder];

    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [contentView addSubview:_imageView];
    
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _placeholder);
    
    //Placeholder
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_placeholder]-0-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_placeholder]-0-|" options:0 metrics:nil views:views]];
    
    //ImageView
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]-0-|" options:0 metrics:nil views:views]];

    [contentView addConstraints:constraints];
    
    return self;
}

- (void)prepareForReuse{
    [_placeholder setNeedsDisplay];
}

- (void)configureWithObject:(id)obj
{
    BSHArtworkObject *artwork = (BSHArtworkObject *)obj;
    [_imageView setImage:nil];
    [_imageView sd_setImageWithURL:artwork.url placeholderImage:nil];
}

@end
