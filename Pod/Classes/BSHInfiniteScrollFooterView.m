//
//  BSHInfiniteScrollFooterView.m
//  Pods
//
//  Created by Paul Wood on 12/10/14.
//
//

#import "BSHInfiniteScrollFooterView.h"

@implementation BSHInfiniteScrollFooterView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [_activityIndicator setColor:[UIColor lightGrayColor]];
    [self addSubview:_activityIndicator];
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraints:constraints];
    
    
    return self;
}
@end
