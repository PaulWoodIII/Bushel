//
//  BSHDisplayNoContentViewController.m
//  Bushel
//
//  Created by Paul Wood on 12/7/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDisplayNoContentViewController.h"
#import "BSHDataAccessManager.h"

@interface BSHDisplayNoContentViewController ()
@property (nonatomic, strong) BSHDisplayNoContentDataSource *dataSource;
@end

@implementation BSHDisplayNoContentViewController

- (void)viewDidLoad {
    _dataSource = [[BSHDisplayNoContentDataSource alloc] init];
    // If you want feedback about loading these all need to be set
    _dataSource.errorTitle = @"Error Title";
    _dataSource.errorMessage = @"Error Message, this should never show";
    _dataSource.noContentImage = nil;
    _dataSource.noContentTitle = @"No Content";
    _dataSource.noContentMessage = @"No Content message, this should always show";
    self.collectionView.dataSource = self.dataSource;
    [super viewDidLoad];
}

@end

@implementation BSHDisplayNoContentDataSource

- (void)loadContent
{
    [self loadContentWithBlock:^(BSHLoading *loading) {
        
        [[BSHDataAccessManager manager]
         waitAndNoContentWithCompletionHandler:^(NSArray *content, NSError *error) {
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
             else if (!content){
                 [self loadContentWithBlock:^(BSHLoading *loading) {
                     [loading updateWithNoContent:nil];
                 }];
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