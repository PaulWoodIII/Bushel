//
//  SZAArtworkCell.h
//  Shazart
//
//  Created by Paul Wood III on 10/9/14.
//  Copyright (c) 2014 TMCL. All rights reserved.
//

#import "BSHCollectionViewCell.h"

@interface BSHDynamicImageCell : BSHCollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

- (void)configureWithObject:(id)object;

@end
