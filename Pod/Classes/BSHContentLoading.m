/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHContentLoading.h"

NSString *const BSHLoadStateInitial = @"Initial";
NSString *const BSHLoadStateLoadingContent = @"LoadingState";
NSString *const BSHLoadStateRefreshingContent = @"RefreshingState";
NSString *const BSHLoadStateContentLoaded = @"LoadedState";
NSString *const BSHLoadStateNoContent = @"NoContentState";
NSString *const BSHLoadStateError = @"ErrorState";

@interface BSHLoading ()

@property (nonatomic, copy) BSHLoadingCompletionBlock block;

@end

@implementation BSHLoading

- (instancetype)initWithCompletionHandler:(BSHLoadingCompletionBlock)handler
{
	NSParameterAssert(handler != nil);
	self = [super init];
	if (!self) return nil;
	self.block = handler;
	self.current = YES;
	return self;
}

- (void)doneWithNewState:(NSString *)newState error:(NSError *)error update:(BSHLoadingUpdateBlock)update
{
	BSHLoadingCompletionBlock block = self.block;
	self.block = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        block(newState, error, update);
    });
}

- (void)ignore
{
    [self doneWithNewState:nil error:nil update:NULL];
}

- (void)updateWithContent:(BSHLoadingUpdateBlock)update
{
    [self doneWithNewState:BSHLoadStateContentLoaded error:nil update:update];
}

- (void)done:(BOOL)success error:(NSError *)error
{
	NSString *newState = success ? BSHLoadStateContentLoaded : BSHLoadStateError;
	[self doneWithNewState:newState error:error update:NULL];
}

- (void)updateWithNoContent:(BSHLoadingUpdateBlock)update
{
    [self doneWithNewState:BSHLoadStateNoContent error:nil update:update];
}

@end

@implementation BSHStateMachine (BSHLoadableContentStateMachine)

+ (instancetype)loadableContentStateMachine
{
	BSHStateMachine *sm = [[BSHStateMachine alloc] init];
    sm.currentState = BSHLoadStateInitial;
    sm.validTransitions = @{
        BSHLoadStateInitial : @[BSHLoadStateLoadingContent],
        BSHLoadStateLoadingContent : @[BSHLoadStateContentLoaded, BSHLoadStateNoContent, BSHLoadStateError],
        BSHLoadStateRefreshingContent : @[BSHLoadStateContentLoaded, BSHLoadStateNoContent, BSHLoadStateError],
        BSHLoadStateContentLoaded : @[BSHLoadStateRefreshingContent, BSHLoadStateNoContent, BSHLoadStateError],
        BSHLoadStateNoContent : @[BSHLoadStateRefreshingContent, BSHLoadStateContentLoaded, BSHLoadStateError],
        BSHLoadStateError : @[BSHLoadStateLoadingContent, BSHLoadStateRefreshingContent, BSHLoadStateNoContent, BSHLoadStateContentLoaded]
    };
    return sm;
}

@end
