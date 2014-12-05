/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHCollectionViewCell.h"

typedef enum {
    /// Primary and secondary labels are the same size with the primary label left aligned and the secondary right aligned
    BSHBasicCellStyleDefault,
    /// Primary and secondary labels are aligned one above the other. Primary label is larger than the secondary label.
    BSHBasicCellStyleSubtitle
} BSHBasicCellStyle;

/// About as bog simple a collection view cell as you can get.
@interface BSHBasicCell : BSHCollectionViewCell

@property (nonatomic) BSHBasicCellStyle style;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic, readonly) UILabel *primaryLabel;
@property (nonatomic, readonly) UILabel *secondaryLabel;

@end
