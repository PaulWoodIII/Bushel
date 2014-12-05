/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHPinnableHeaderView.h"

@interface BSHSectionHeaderView : BSHPinnableHeaderView

@property (nonatomic, readonly) UILabel *leftLabel;
@property (nonatomic, readonly) UILabel *rightLabel;

/// The action button is only created when first accessed. Section headers will not have an action button unless it is configured. When an action button is configured, the right text value becomes the label for the button.
@property (nonatomic, strong, readonly) UIButton *actionButton;

@end
