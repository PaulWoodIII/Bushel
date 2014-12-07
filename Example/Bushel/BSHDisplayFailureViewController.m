//
//  BSHDisplayFailureViewController.m
//  Bushel
//
//  Created by Paul Wood on 12/7/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDisplayFailureViewController.h"
#import "BSHDataAccessManager.h"

@interface BSHDisplayFailureViewController ()
@property (nonatomic, strong) BSHDisplayFailureDataSource *dataSource;
@end

@implementation BSHDisplayFailureViewController

- (void)viewDidLoad {
    _dataSource = [[BSHDisplayFailureDataSource alloc] init];
    // If you want feedback about loading these all need to be set
    _dataSource.errorTitle = @"Error Title";
    _dataSource.errorMessage = @"Error Message, this should always show";
    _dataSource.noContentImage = nil;
    _dataSource.noContentTitle = @"No Content";
    _dataSource.noContentMessage = @"No Content message, this should never show";
    self.collectionView.dataSource = self.dataSource;
    [super viewDidLoad];
}

@end

@implementation BSHDisplayFailureDataSource

- (void)loadContent
{
    [self loadContentWithBlock:^(BSHLoading *loading) {
 
        [[BSHDataAccessManager manager]
         waitAndFailWithCompletionHandler:^(NSArray *content, NSError *error) {
             if (!loading.current) {
                 [loading ignore];
                 return;
             }
             if (error) {
                 // NOTE:
                 // This should always return true for this example
                 // I've included this template I use for my completion handlers
                 [loading done:NO error:error];
                 return;
             }
         }];
    }];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should never be called");
    return nil;
}

@end