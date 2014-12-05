//
//  BSHDataAccessManager.h
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSHDataAccessManager : NSObject

- (void)fetchTop100ArtworkWithPage:(NSInteger)page completionHandler:(void(^)(NSArray *artworks, NSError *error))handler;

+ (BSHDataAccessManager *)manager;

@end
