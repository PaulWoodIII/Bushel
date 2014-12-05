/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 */

#import <Foundation/Foundation.h>

extern NSString *const BSHInvalidStateTransitionException;

@protocol BSHStateMachineDelegate <NSObject>

@optional

- (BOOL)shouldChangeToState:(NSString *)newState;
- (void)stateWillChangeFrom:(NSString *)oldState to:(NSString *)newState;
- (void)stateDidChangeFrom:(NSString *)oldState to:(NSString *)newState;

/// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

@interface BSHStateMachine : NSObject

@property (copy) NSString *currentState;
@property (copy) NSDictionary *validTransitions;

/// If set, BSHStateMachine invokes transition methods on this delegate instead of self. This allows BSHStateMachine to be used where subclassing doesn't make sense. The delegate is invoked on the same thread as -setCurrentState:
@property (weak) id <BSHStateMachineDelegate> delegate;

/// For subclasses. Base implementation raises BSHInvalidStateTransitionException. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

