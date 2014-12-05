//
//  SZAImageTextCell.h
//  Shazart
//
//  Created by Paul Wood III on 11/28/14.
//  Copyright (c) 2014 TMCL. All rights reserved.
//

#import "BSHCollectionViewCell.h"

@interface BSHImageTextCell : BSHCollectionViewCell

@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *primaryLabel;


@end
