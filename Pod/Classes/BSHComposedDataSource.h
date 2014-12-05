/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHDataSource.h"

/// A data source that is composed of other data sources.
@interface BSHComposedDataSource : BSHDataSource

/// Add a data source to the data source.
- (void)addDataSource:(BSHDataSource *)dataSource;

/// Remove the specified data source from this data source.
- (void)removeDataSource:(BSHDataSource *)dataSource __unused;

@end
