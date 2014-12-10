//
//  BSHDynamicImagesDataSource.m
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDynamicImagesDataSource.h"
#import "BSHDataSource+Subclasses.h"
#import "BSHArtworkObject.h"
#import "BSHDynamicImageCell.h"
#import "BSHDataAccessManager.h"
#import "UICollectionReusableView+BSHGridLayout.h"
#import "BSHInfiniteScrollFooterView.h"

@implementation BSHDynamicImagesDataSource

- (instancetype) init{
    self = [super init];
    if (self) {
        self.page = 0;
        self.moreContentAvailable = YES;
        
        BSHLayoutSupplementaryMetrics *footer = [self.defaultMetrics newFooter];
        footer.supplementaryViewClass = [BSHInfiniteScrollFooterView class];
        footer.backgroundColor = [UIColor clearColor];
        footer.height = 44;
        [footer configureWithBlock:^(BSHInfiniteScrollFooterView *view, BSHDynamicImagesDataSource *dataSource, NSIndexPath *indexPath) {
            if (self.moreContentAvailable) {
                [view.activityIndicator startAnimating];
                [dataSource loadNextPage:^(BOOL finished) {
                    
                }];
            }
            else{
                [view.activityIndicator stopAnimating];
            }
        }];
    }
    return self;
}

- (void)refreshControlAction:(UIRefreshControl *)incRefreshControl{
    if(self.refreshControl != incRefreshControl){
        return;
    }
    self.page = 0;
    self.moreContentAvailable = YES;
    [self resetContent];
    [self setNeedsLoadContent];
}

- (BSHArtworkObject *)itemWithID:(NSString *)idString{
    __block BSHArtworkObject *foundArtwork = nil;
    
    [self.items enumerateObjectsUsingBlock:^(BSHArtworkObject *artwork, NSUInteger idx, BOOL *stop) {
        if ([artwork.uid isEqualToString:idString]) {
            foundArtwork = artwork;
            *stop = YES;
        }
    }];
    
    return foundArtwork;
}

- (void)loadContent
{
    [self.refreshControl endRefreshing];
    [self loadContentWithBlock:^(BSHLoading *loading) {
        if (self.items.count > 0) {
            return;
        }
        [[BSHDataAccessManager manager]
         fetchTop100ArtworkWithPage:self.page
         completionHandler:^(NSArray *artworks, NSError *error) {
             if (!loading.current) {
                 [loading ignore];
                 return;
             }
             if (error) {
                 [loading done:YES error:error];
                 return;
             }
             if (artworks.count == 0) {
                 [loading done:YES error:error];
             }
             else{
                 [loading updateWithContent:^(BSHDynamicImagesDataSource *me){
                     me.items = artworks;
                     me.page++;
                 }];
             }
         }];
    }];
}

- (void)loadNextPage:(void(^)(BOOL finished))handler{
    [self loadContentWithBlock:^(BSHLoading *loading) {
        [[BSHDataAccessManager manager]
         fetchTop100ArtworkWithPage:self.page
         completionHandler:^(NSArray *artworks, NSError *error) {
             
             if (!loading.current) {
                 [loading ignore];
                 return;
             }
             if (error) {
                 [loading done:YES error:error];
                 [self.refreshControl endRefreshing];
                 self.moreContentAvailable = NO;
                 if (handler) {
                     handler(NO);
                 }
                 return;
             }
             if (artworks.count == 0) {
                 [loading done:YES error:error];
                 [self.refreshControl endRefreshing];
                 self.moreContentAvailable = NO;
                 if (handler) {
                     handler(NO);
                 }
             }
             else{
                 [loading updateWithContent:^(BSHDynamicImagesDataSource *me){
                     NSMutableArray *appender = [NSMutableArray arrayWithArray:self.items];
                     [appender addObjectsFromArray:artworks];
                     [self setItems:appender];
                     self.page++;
                     
                     // If you know the page size you can be smarter here!
                     self.moreContentAvailable = YES;
                     
                     if (handler) {
                         handler(YES);
                     }
                 }];
             }
         }];
    }];
}

- (void)registerReusableViewsWithCollectionView:(UICollectionView *)collectionView
{
    [super registerReusableViewsWithCollectionView:collectionView];
    [collectionView registerClass:[BSHDynamicImageCell class] forCellWithReuseIdentifier:NSStringFromClass([BSHDynamicImageCell class])];
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeFittingSize:(CGSize)size forItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize fittingSize = [[self itemAtIndexPath:indexPath] imageSize];
    return fittingSize;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHDynamicImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BSHDynamicImageCell class]) forIndexPath:indexPath];
    BSHArtworkObject *artwork = [self itemAtIndexPath:indexPath];
    [cell configureWithObject:artwork];
    return cell;
}

@end
