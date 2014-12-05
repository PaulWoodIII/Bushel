//
//  BSHDynamicImagesViewController.m
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDynamicImagesViewController.h"
#import "BSHDynamicImagesDataSource.h"
#import <UIScrollView-InfiniteScroll/UIScrollView+InfiniteScroll.h>
#import <Bushel/BSHBalancedFlowLayout.h>
#import <Bushel/BSHSectionHeaderView.h>
#import "BSHArtworkObject.h"

@interface BSHDynamicImagesViewController () <BSHBalancedFlowLayoutDelegate>
@property (nonatomic, strong) BSHDynamicImagesDataSource *dataSource;
@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) NSString *selectedArtworkID;
@property (nonatomic, weak) UIRefreshControl *refreshControl;
@end

@implementation BSHDynamicImagesViewController

- (void)viewDidLoad {
    self.dataSource = [self newTopArtDataSource];
    self.collectionView.dataSource = self.dataSource;
    
    UIRefreshControl *myRefreshControl = [[UIRefreshControl alloc] init];
    myRefreshControl.tintColor = [UIColor grayColor];
    self.dataSource.refreshControl = myRefreshControl;
    [myRefreshControl addTarget:self.dataSource action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:myRefreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    self.refreshControl = myRefreshControl;
    
    self.collectionView.delegate = self;
    
    __weak typeof(&*self) weakself = self;
    
    // Add infinite scroll handler
    [self.collectionView addInfiniteScrollWithHandler:^(UIScrollView* scrollView) {
        __strong typeof(weakself) strongSelf = weakself;
        
        [strongSelf.dataSource loadNextPage:^{
            // Finish infinite scroll animations
            [scrollView finishInfiniteScroll];
        }];
    }];
    
    BSHLayoutSupplementaryMetrics *globalHeader = [self.dataSource newHeaderForKey:@"HeaderView"];
    globalHeader.visibleWhileShowingPlaceholder = YES;
    globalHeader.supplementaryViewClass = [BSHSectionHeaderView class];
    globalHeader.height = 72;
    globalHeader.configureView = ^(BSHSectionHeaderView *view, BSHDataSource *dataSource, NSIndexPath *indexPath) {
        view.leftLabel.text = @"Left Label";
        view.rightLabel.text = @"Right Label";
    };
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BSHDynamicImagesDataSource *)newTopArtDataSource
{
    BSHDynamicImagesDataSource *dataSource = [[BSHDynamicImagesDataSource alloc] init];
    
    dataSource.title = NSLocalizedString(@"Discover", @"Title for Top Artworks");
    dataSource.noContentMessage = NSLocalizedString(@"There are currently no Top Artworks available. Please try again later.", @"The message to show when no Top Artworks are available");
    dataSource.noContentTitle = NSLocalizedString(@"No Top Artworks", @"The title to show when no top arts are available");
    dataSource.errorMessage = NSLocalizedString(@"A problem with the network prevented loading the available artworks.\nPlease, check your network settings.", @"Message to show when unable to load top arts");
    dataSource.errorTitle = NSLocalizedString(@"Unable To Load Top Artworks", @"Title of message to show when unable to load top arts");
    dataSource.defaultMetrics.padding = UIEdgeInsetsMake(5,5,5,5);
    dataSource.defaultMetrics.rowHeight = BSHRowHeightPartition;
    dataSource.page = 0;
    return dataSource;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *av = [[UIAlertView alloc]
                       initWithTitle:@"Selected"
                       message:@"selected an artwork"
                       delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"Cance", nil)
                       otherButtonTitles:nil];
    [av show];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(BSHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSHArtworkObject *artwork = [self.dataSource itemAtIndexPath:indexPath];
    return CGSizeMake(artwork.width, artwork.height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
