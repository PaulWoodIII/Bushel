//
//  UIView+BSHAdditions.h
//  AdvancedCollectionView
//
//  Created by Zachary Waldowski on 7/10/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "UIView+BSHAdditions.h"

@implementation UIView (BSHAdditions)

- (CGFloat)BSH_hairlineWidth
{
	CGFloat scale = self.window ? self.window.screen.scale : UIScreen.mainScreen.scale;
	return 1 / scale;
}

- (UIView *)BSH_addSeparatorToEdge:(CGRectEdge)edge color:(UIColor *)color
{
	id constraintTarget = self;
	id oppositeLeadingItem = self;
	id oppositeTrailingItem = self;
	
	UIView *stripe = [[UIView alloc] initWithFrame:CGRectZero];
	stripe.backgroundColor = color;
	stripe.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:stripe];
	
	NSMutableArray *constraints = [NSMutableArray array];
	NSDictionary *views = NSDictionaryOfVariableBindings(stripe);
	NSDictionary *metrics = @{ @"length": @(self.BSH_hairlineWidth) };
	switch (edge) {
		case CGRectMinXEdge:
		case CGRectMaxXEdge: {
			[constraints addObject:[NSLayoutConstraint constraintWithItem:stripe attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:oppositeLeadingItem attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
			[constraints addObject:[NSLayoutConstraint constraintWithItem:stripe attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:oppositeTrailingItem attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
			if (edge == CGRectMinXEdge) {
				[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stripe(length)]" options:0 metrics:metrics views:views]];
			} else {
				[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[stripe(length)]|" options:0 metrics:metrics views:views]];
			}
			[stripe setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
			[stripe setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
			break;
		}
		case CGRectMinYEdge:
		case CGRectMaxYEdge: {
			[constraints addObject:[NSLayoutConstraint constraintWithItem:stripe attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:oppositeLeadingItem attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
			[constraints addObject:[NSLayoutConstraint constraintWithItem:stripe attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:oppositeTrailingItem attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
			if (edge == CGRectMinYEdge) {
				[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stripe(length)]" options:0 metrics:metrics views:views]];
			} else {
				[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[stripe(length)]|" options:0 metrics:metrics views:views]];
			}
			[stripe setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
			[stripe setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
			break;
		}
	}
	[constraintTarget addConstraints:constraints];
	
	return stripe;
}

@end
