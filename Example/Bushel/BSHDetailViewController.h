//
//  BSHDetailViewController.h
//  Bushel
//
//  Created by Paul Wood on 12/4/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import <Bushel/BSHCollectionViewController.h>

@class BSHArtworkObject;

@interface BSHDetailViewController : BSHCollectionViewController

@property (nonatomic, strong) BSHArtworkObject *artwork;

@end
