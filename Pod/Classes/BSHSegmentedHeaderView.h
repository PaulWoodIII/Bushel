/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A header view with a UISegmentedControl for displaying the titles of child data sources in a segmented data source.
  
 */

#import "BSHPinnableHeaderView.h"


@interface BSHSegmentedHeaderView : BSHPinnableHeaderView

@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;

@end
