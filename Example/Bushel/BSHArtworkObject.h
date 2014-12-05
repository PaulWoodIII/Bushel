//
//  BSHArtworkObject.h
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSHArtworkObject : NSObject

@property (nonatomic, copy) NSString *artistContentId;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *uid;
@property NSInteger completitionYear;
@property NSInteger contentId;
@property NSInteger height;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *title;
@property NSInteger width;
@property (nonatomic, copy) NSString *yearAsString;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

- (NSURL *)url;
- (NSURL *)mediumImageURL;
- (NSURL *)largeImageURL;
- (NSURL *)sourcePageURL;
- (CGSize)imageSize;

@end
