//
//  BSHDetailDataSource.m
//  Bushel
//
//  Created by Paul Wood on 12/5/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDetailDataSource.h"
#import <Bushel/BSHDataSource+Subclasses.h>
#import <Bushel/BSHSectionHeaderView.h>
#import <Bushel/BSHKeyValueDataSource.h>
#import <Bushel/BSHTextValueDataSource.h>

static NSString *const kDataSourceTitleHeaderKey = @"DataSourceTitleHeaderKey";

@interface BSHDetailDataSource ()
@property (nonatomic, strong) BSHKeyValueDataSource *classificationDataSource;
@property (nonatomic, strong) BSHTextValueDataSource *descriptionDataSource;
@end


@implementation BSHDetailDataSource



- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    NSDictionary *dict = @{@"thingOne":@"Wow a thing goes here",
                           @"thingTwo":@"Looks like a children's book",
                           @"thingThree":@"Watch out for the cat",
                           @"description":@"Okay kidding aside this is a way to set up a detail view. Its got three major sections a header, a list of key value cells and a few bits of long text at the end that show how variable length text gets handled in the collection view.",
                           @"oneMoreThing":@"actually not really i just needed to test some short text down here."
                           };
    
    _classificationDataSource = [[BSHKeyValueDataSource alloc] initWithObject:dict];
    _classificationDataSource.defaultMetrics.rowHeight = 22;
    _classificationDataSource.title = NSLocalizedString(@"Title for Sub Datasource", @"Title of the classification data section");
    
    if (![_classificationDataSource headerForKey:kDataSourceTitleHeaderKey]) {
        BSHLayoutSupplementaryMetrics *header = [_classificationDataSource newHeaderForKey:kDataSourceTitleHeaderKey];
        header.supplementaryViewClass = BSHSectionHeaderView.class;
        [header configureWithBlock:^(BSHSectionHeaderView *headerView, BSHDataSource *dataSource, NSIndexPath *indexPath) {
            headerView.leftLabel.text = dataSource.title;
        }];
    }
    
    [self addDataSource:_classificationDataSource];
    
    _descriptionDataSource = [[BSHTextValueDataSource alloc] initWithObject:dict];
    _descriptionDataSource.defaultMetrics.rowHeight = BSHRowHeightVariable;
    
    [self addDataSource:_descriptionDataSource];
    
    return self;
}


- (void)updateChildDataSources
{
    self.classificationDataSource.items = @[
                                            @{ @"label" : NSLocalizedString(@"This First Thing", @"label for kingdom cell"), @"keyPath" : @"thingOne" },
                                            @{ @"label" : NSLocalizedString(@"The Second Thing", @"label for the phylum cell"), @"keyPath" : @"thingTwo" },
                                            @{ @"label" : NSLocalizedString(@"The Third Thing", @"label for the class cell"), @"keyPath" : @"thingThree" },
                                            ];
    
    self.descriptionDataSource.items = @[
                                         @{ @"label" : NSLocalizedString(@"Description", @"Title of the description data section"), @"keyPath" : @"description" },
                                         @{ @"label" : NSLocalizedString(@"And theres one more thing", @"Title of the habitat data section"), @"keyPath" : @"oneMoreThing" }
                                         ];
}

- (void)loadContent
{
    [self loadContentWithBlock:^(BSHLoading *loading) {
        // There's always content
        [loading updateWithContent:^(BSHDetailDataSource *me) {
            [me updateChildDataSources];
        }];
    }];
}

@end
