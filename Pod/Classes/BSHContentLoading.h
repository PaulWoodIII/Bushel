/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import "BSHStateMachine.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"

/// The initial state.
extern NSString *const BSHLoadStateInitial;
/// The first load of content.
extern NSString *const BSHLoadStateLoadingContent;
/// Subsequent loads after the first.
extern NSString *const BSHLoadStateRefreshingContent;
/// After content is loaded successfully.
extern NSString *const BSHLoadStateContentLoaded;
/// No content is available.
extern NSString *const BSHLoadStateNoContent;
/// An error occurred while loading content.
extern NSString *const BSHLoadStateError;

/// A block that performs updates on the object that is loading. The object parameter is the original object that received the -loadContentWithBlock: message.
typedef void (^BSHLoadingUpdateBlock)(id object);

/// A block called when loading completes.
typedef void (^BSHLoadingCompletionBlock)(NSString *state, NSError *error, BSHLoadingUpdateBlock update);

/// A helper class passed to the content loading block of an BSHLoadableContentViewController.
@interface BSHLoading : NSObject

/// Signals that this result should be ignored. Sends a nil value for the state to the completion handler.
- (void)ignore;
/// Signals that loading is complete. This triggers a transition to either the Loaded or Error state.
- (void)done:(BOOL)success error:(NSError *)error;
/// Signals that loading is complete, transitions into the Loaded state and then runs the update block.
- (void)updateWithContent:(BSHLoadingUpdateBlock)update;
/// Signals that loading completed with no content, transitions to the No Content state and then runs the update block.
- (void)updateWithNoContent:(BSHLoadingUpdateBlock)update;

/// Is this the current loading operation? When -loadContentWithBlock: is called it should inform previous instances of BSHLoading that they are no longer the current instance.
@property (nonatomic, getter=isCurrent) BOOL current;

- (instancetype)initWithCompletionHandler:(BSHLoadingCompletionBlock)handler;

@end

/// A protocol that defines content loading behavior
@protocol BSHContentLoading <NSObject, BSHStateMachineDelegate>

/// The current state of the content loading operation
@property (nonatomic, copy) NSString *loadingState;
/// Any error that occurred during content loading.
@property (nonatomic, strong) NSError *loadingError;

/// Public method used to begin loading the content.
- (void)loadContent;
/// Public method used to reset the content of the receiver.
- (void)resetContent;

/// Method used by implementers of -loadContent to manage the loading operation. Usually implemented by the base class that adopts ITCContentLoading.
- (void)loadContentWithBlock:(void(^)(BSHLoading *loading))block;

@end

@interface BSHStateMachine (BSHLoadableContentStateMachine)

+ (instancetype)loadableContentStateMachine;

@end

#pragma clang diagnostic pop
