//
//  BSHArtworkObject.m
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHArtworkObject.h"

@implementation BSHArtworkObject

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    if (self) {
        
        if (dictionary[@"artistContentId"]){self.artistContentId = dictionary[@"artistContentId"];}
        if (dictionary[@"id"]){self.uid = dictionary[@"id"];}
        if (dictionary[@"artistName"]){self.artistName = dictionary[@"artistName"];}
        if (dictionary[@"image"]){self.image = dictionary[@"image"];}
        if (dictionary[@"title"]){self.title = dictionary[@"title"];}
        if (dictionary[@"yearAsString"]){self.yearAsString = dictionary[@"yearAsString"];}
        
        if ([dictionary[@"completitionYear"] isKindOfClass:[NSNumber class]]) {
            _completitionYear = [dictionary[@"completitionYear"] integerValue];
        }
        if ([dictionary[@"contentId"] isKindOfClass:[NSNumber class]]) {
            _contentId = [dictionary[@"contentId"] integerValue];
        }
        if ([dictionary[@"height"] isKindOfClass:[NSString class]]) {
            _height = [dictionary[@"height"] integerValue];
        }
        if ([dictionary[@"width"] isKindOfClass:[NSString class]]) {
            _width = [dictionary[@"width"] integerValue];
        }
        if ([dictionary[@"height"] isKindOfClass:[NSNumber class]]) {
            _height = [dictionary[@"height"] integerValue];
        }
        if ([dictionary[@"width"] isKindOfClass:[NSNumber class]]) {
            _width = [dictionary[@"width"] integerValue];
        }
    }
    return self;
}

- (id)valueForUndefinedKey:(NSString *)key{
    return nil;
    //    return @"Fusce euismod bibendum iaculis. Donec id facilisis sapien. Quisque eget ornare diam. Nam sed rutrum felis, at hendrerit tellus. Maecenas eget gravida nisl, non viverra nisl. Phasellus egestas mauris non odio pulvinar, eu pharetra enim bibendum. Vivamus viverra porta varius. Ut tempus aliquet elementum. Fusce erat eros, facilisis eu malesuada eu, egestas vel diam. Fusce sit amet malesuada erat.\n\nMauris at vestibulum leo. Ut ac pharetra leo. Suspendisse quis luctus ante. Nam varius velit eget euismod vehicula. Aliquam sed leo at dolor ullamcorper rutrum. Curabitur vitae laoreet mauris. Nullam dapibus, urna ac egestas mollis, enim eros varius lectus, eu fringilla dolor dolor a diam. In fringilla, nisi a dapibus elementum, purus lectus vehicula tortor, rutrum dapibus lorem felis nec nisi. Fusce quis varius enim. Fusce tincidunt leo sed tellus interdum porttitor. Aliquam in risus imperdiet, mattis ligula ut, ullamcorper purus. Vestibulum placerat, mauris eu luctus tempus, est odio viverra lectus, ac accumsan dolor odio tempus erat. Sed id rutrum felis.\n\nNullam mattis sem tellus, ac iaculis mauris rhoncus sed. Ut molestie dictum pharetra. Curabitur convallis molestie augue, ut sagittis nisl. Nam euismod vehicula velit sed tristique. Sed at mi ac sem adipiscing convallis eu commodo urna. Vivamus non lobortis leo. Duis elementum vehicula nunc vitae luctus. Curabitur id ante a lectus gravida tempor sed id justo. Maecenas dignissim accumsan feugiat. Quisque at lobortis augue. In hac habitasse platea dictumst.";
}

- (CGSize)imageSize{
    if (self.width && self.width > 0 && self.height && self.height > 0) {
        return CGSizeMake(self.width,self.height);
    }
    else{
        return CGSizeMake(100, 100);
    }
    
}

- (NSURL *)url{
    return [NSURL URLWithString:self.image];
}

- (NSURL *)mediumImageURL{
    NSString *replacementURLString = [self.image stringByReplacingOccurrencesOfString:@".small.jpg" withString:@".mid.jpg"];
    return [NSURL URLWithString:replacementURLString];
}


- (NSURL *)largeImageURL{
    NSString *replacementURLString = [self.image stringByReplacingOccurrencesOfString:@".small.jpg" withString:@".big.jpg"];
    return [NSURL URLWithString:replacementURLString];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@ Title: %@",super.description,self.title];
}

@end
