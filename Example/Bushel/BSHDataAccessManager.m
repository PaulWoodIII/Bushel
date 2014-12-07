//
//  BSHDataAccessManager.m
//  Bushel
//
//  Created by Paul Wood on 12/3/14.
//  Copyright (c) 2014 paulwoodiii. All rights reserved.
//

#import "BSHDataAccessManager.h"
#import "BSHArtworkObject.h"

@implementation BSHDataAccessManager

+ (BSHDataAccessManager *)manager
{
    static BSHDataAccessManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BSHDataAccessManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    // Might need to add something here later
    return self;
}

- (void)fetchJSONResourceWithName:(NSString *)name completionHandler:(void(^)(NSDictionary *json, NSError *error))handler
{
    NSParameterAssert(handler != nil);
    
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"json"];
    if (!resourceURL) {
        // Should create an NSError and pass it to the completion handler
        NSAssert(NO, @"Could not find resource: %@", name);
    }
    
    NSError *error;
    
    // Fetch the json data. If there's an error, call the handler and return.
    NSData *jsonData = [NSData dataWithContentsOfURL:resourceURL options:NSDataReadingMappedIfSafe error:&error];
    if (!jsonData) {
        handler(nil, error);
        return;
    }
    
    // Parse the json data. If there's an error parsing the json data, call the handler and return.
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!json) {
        handler(nil, error);
        return;
    }
    
    // If the json data specified that we should delay the results, do so before calling the handler
    NSNumber *delayResults = json[@"delayResults"];
    if (delayResults && [delayResults isKindOfClass:[NSNumber class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([delayResults floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            handler(json, nil);
        });
    }
    else {
        handler(json, nil);
    }
}

- (void)fetchTop100ArtworkWithPage:(NSInteger)page completionHandler:(void(^)(NSArray *artworks, NSError *error))handler{
    [self fetchJSONResourceWithName:@"artworks" completionHandler:^(NSDictionary *json, NSError *error) {
        if (error) {
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil, error);
                });
            }
            return;
        }
        
        NSArray *results = json[@"data"];
        NSAssert([results isKindOfClass:[NSArray class]], @"results property should be an array");
        
        NSMutableArray *artworks = [NSMutableArray array];
        for (NSDictionary *dict in results) {
            BSHArtworkObject *art = [[BSHArtworkObject alloc] initWithDictionary:dict];
            if (!art)
                continue;
            [artworks addObject:art];
        }
        
        NSInteger pageStart = page * 20;
        NSRange returnRange = NSMakeRange(pageStart, 20);
        NSArray *returnArray = nil;
        if (artworks.count > (returnRange.location + returnRange.length)) {
            returnArray = [artworks subarrayWithRange:returnRange];
        }
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(returnArray, nil);
            });
        }
    }];
}

- (void)waitAndFailWithCompletionHandler:(void(^)(NSArray *content, NSError *error))handler{
    // If the json data specified that we should delay the results, do so before calling the handler
    float delayTime = 3.0;
    NSError *error = [NSError errorWithDomain:@"ExampleErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"This is an example error description"}];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        handler(nil, error);
    });
}

- (void)waitAndNoContentWithCompletionHandler:(void(^)(NSArray *content, NSError *error))handler{
    float delayTime = 3.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        handler(nil,nil);
    });
}

@end
