//
//  BSHViewController.m
//  Bushel
//
//  Created by paulwoodiii on 12/03/2014.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHViewController.h"
#import "BSHExampleDataSource.h"
#import <Bushel/BSHSectionHeaderView.h>

@interface BSHViewController ()
@property (nonatomic, strong) BSHExampleDataSource *dataSource;
@end

@implementation BSHViewController

- (void)viewDidLoad
{
	// Do any additional setup after loading the view, typically from a nib.
    BSHExampleDataSource *dataSource = [[BSHExampleDataSource alloc] init];
    self.dataSource = dataSource;
    self.collectionView.dataSource = self.dataSource;
    
    // We still need to set our own title but we can share it with the data source
    self.title = dataSource.title;
    
    BSHLayoutSupplementaryMetrics *globalHeader = [self.dataSource newHeaderForKey:@"HeaderView"];
    globalHeader.visibleWhileShowingPlaceholder = YES;
    globalHeader.supplementaryViewClass = [BSHSectionHeaderView class];
    globalHeader.height = 72;
    globalHeader.configureView = ^(BSHSectionHeaderView *view, BSHDataSource *dataSource, NSIndexPath *indexPath) {
        view.leftLabel.text = @"Heres some Examples";
    };

    [super viewDidLoad];
}


- (BSHExampleDataSource *)newExampleDataSource
{
    BSHExampleDataSource *dataSource = [[BSHExampleDataSource alloc] init];
    
    // This doesn't show up on the navigation bar, but will be used in some places such as combined data sources and segmented data sources
    dataSource.title = NSLocalizedString(@"Examples", @"Title for examples list");
    
    // Heres how you add some seperator lines to the cells
    BSHLayoutSectionMetrics *metrics = dataSource.defaultMetrics;
    metrics.separatorColor = [UIColor colorWithWhite:224/255.0 alpha:1];
    metrics.separatorInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    
    return dataSource;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Don't set items until we know the view has been created
    [self.dataSource setItems:@[
                                @{BSHDataSourceTitleKey:NSLocalizedString(@"Dynamicly Sized Image List", nil),
                                  BSHDataSourceActionKey:@"ShowArtworkList",
                                  BSHDataSourceImageNameKey:@"ArtworksIcon",
                                  BSHDataSourceActiveKey:@1},
                                @{BSHDataSourceTitleKey:NSLocalizedString(@"Detail View Example", nil),
                                  BSHDataSourceActionKey:@"ShowDetail",
                                  BSHDataSourceImageNameKey:@"ShowDetailIcon",
                                  BSHDataSourceActiveKey:@1},
                                @{BSHDataSourceTitleKey:NSLocalizedString(@"Contact List", nil),
                                  BSHDataSourceActionKey:@"ContactList",
                                  BSHDataSourceImageNameKey:@"ContactListIcon",
                                  BSHDataSourceActiveKey:@0},
                                @{BSHDataSourceTitleKey:NSLocalizedString(@"Wait and Show Failed", nil),
                                  BSHDataSourceActionKey:@"ShowFailure",
                                  BSHDataSourceImageNameKey:@"ShowFailureIcon",
                                  BSHDataSourceActiveKey:@1},
                                @{BSHDataSourceTitleKey:NSLocalizedString(@"Wait and Show No Content", nil),
                                  BSHDataSourceActionKey:@"ShowNoContent",
                                  BSHDataSourceImageNameKey:@"ShowNoContentIcon",
                                  BSHDataSourceActiveKey:@1},
                                ]];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item[BSHDataSourceActiveKey] boolValue]) {
        NSString *action = item[BSHDataSourceActionKey];
        [self performSegueWithIdentifier:action sender:self];
    }
    else{
        //[self showShouldRegisterAlert];
    }
}


@end
