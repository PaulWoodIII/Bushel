//
//  BSHDynamicImagesDataSource.h
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHBasicDataSource.h"

@class BSHArtworkObject;

@interface BSHDynamicImagesDataSource : BSHBasicDataSource

@property (nonatomic, weak) UIRefreshControl *refreshControl;
@property NSInteger page;

- (BSHArtworkObject *)itemWithID:(NSString *)idString;
- (void)refreshControlAction:(UIRefreshControl *)refreshControl;
- (void)loadNextPage:(void(^)(void))handler;

@end
