//
//  BSHDetailViewController.m
//  Bushel
//
//  Created by Paul Wood on 12/4/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDetailViewController.h"
#import "BSHDetailDataSource.h"

@interface BSHDetailViewController ()
@property (nonatomic, strong) BSHDetailDataSource *dataSource;
@end

@implementation BSHDetailViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    self.dataSource = [self newCompsedDataSource];
    self.collectionView.dataSource = self.dataSource;
    
    // View Did Load Goes Last because super does some work as well.
    [super viewDidLoad];

}

- (BSHDetailDataSource *)newCompsedDataSource{
    BSHDetailDataSource *dataSource = [[BSHDetailDataSource alloc] init];
    return dataSource;
}

@end
