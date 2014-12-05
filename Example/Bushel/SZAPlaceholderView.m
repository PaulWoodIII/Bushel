//
//  SZAPlaceholderView.m
//  Shazart
//
//  Created by Paul Wood III on 10/24/14.
//  Copyright (c) 2014 TMCL. All rights reserved.
//

#import "SZAPlaceholderView.h"

@implementation SZAPlaceholderView

- (void)drawRect:(CGRect)rect{
    [self drawImagePlaceholderWithFrame:rect];
}

- (void)drawImagePlaceholderWithFrame: (CGRect)frame
{
    //// Color Declarations
    UIColor* color16 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    
    //// Subframes
    CGRect iconFrame = CGRectMake(CGRectGetMinX(frame) + floor((CGRectGetWidth(frame) - 42) * 0.50459 + 0.5), CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 34) * 0.50000 + 0.5), 42, 34);
    CGRect icon = CGRectMake(CGRectGetMinX(iconFrame) + floor((CGRectGetWidth(iconFrame) - 38) * 0.50000 + 0.5), CGRectGetMinY(iconFrame) + 2.25, 38, 28.75);
    
    
    //// Rectangle 5 Drawing
    UIBezierPath* rectangle5Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [color16 setFill];
    [rectangle5Path fill];
    
    
    //// Icon
    {
        //// Bezier 3 Drawing
        UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
        [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(icon) + 34.29, CGRectGetMinY(icon) + 3.83)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 3.71, CGRectGetMinY(icon) + 3.83)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 3.71, CGRectGetMinY(icon) + 25.88)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 34.29, CGRectGetMinY(icon) + 25.88)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 34.29, CGRectGetMinY(icon) + 3.83)];
        [bezier3Path closePath];
        [bezier3Path moveToPoint: CGPointMake(CGRectGetMinX(icon) + 36.14, CGRectGetMinY(icon) + 0.19)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 36.24, CGRectGetMinY(icon) + 0.22)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 37.79, CGRectGetMinY(icon) + 1.82) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 36.96, CGRectGetMinY(icon) + 0.49) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 37.53, CGRectGetMinY(icon) + 1.07)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 38, CGRectGetMinY(icon) + 4.39) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 38, CGRectGetMinY(icon) + 2.5) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 38, CGRectGetMinY(icon) + 3.13)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 38, CGRectGetMinY(icon) + 24.36)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 37.82, CGRectGetMinY(icon) + 26.82) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 38, CGRectGetMinY(icon) + 25.62) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 38, CGRectGetMinY(icon) + 26.25)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 37.79, CGRectGetMinY(icon) + 26.93)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 36.24, CGRectGetMinY(icon) + 28.53) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 37.53, CGRectGetMinY(icon) + 27.68) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 36.96, CGRectGetMinY(icon) + 28.26)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 33.75, CGRectGetMinY(icon) + 28.75) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 35.59, CGRectGetMinY(icon) + 28.75) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 34.97, CGRectGetMinY(icon) + 28.75)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 4.25, CGRectGetMinY(icon) + 28.75)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 1.86, CGRectGetMinY(icon) + 28.56) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 3.03, CGRectGetMinY(icon) + 28.75) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 2.41, CGRectGetMinY(icon) + 28.75)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 1.76, CGRectGetMinY(icon) + 28.53)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 0.21, CGRectGetMinY(icon) + 26.93) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 1.04, CGRectGetMinY(icon) + 28.26) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 0.47, CGRectGetMinY(icon) + 27.68)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon), CGRectGetMinY(icon) + 24.36) controlPoint1: CGPointMake(CGRectGetMinX(icon), CGRectGetMinY(icon) + 26.25) controlPoint2: CGPointMake(CGRectGetMinX(icon), CGRectGetMinY(icon) + 25.62)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon), CGRectGetMinY(icon) + 4.39)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 0.18, CGRectGetMinY(icon) + 1.93) controlPoint1: CGPointMake(CGRectGetMinX(icon), CGRectGetMinY(icon) + 3.13) controlPoint2: CGPointMake(CGRectGetMinX(icon), CGRectGetMinY(icon) + 2.5)];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 0.21, CGRectGetMinY(icon) + 1.82)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 1.76, CGRectGetMinY(icon) + 0.22) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 0.47, CGRectGetMinY(icon) + 1.07) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 1.04, CGRectGetMinY(icon) + 0.49)];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 4.25, CGRectGetMinY(icon)) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 2.41, CGRectGetMinY(icon)) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 3.03, CGRectGetMinY(icon))];
        [bezier3Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 33.75, CGRectGetMinY(icon))];
        [bezier3Path addCurveToPoint: CGPointMake(CGRectGetMinX(icon) + 36.14, CGRectGetMinY(icon) + 0.19) controlPoint1: CGPointMake(CGRectGetMinX(icon) + 34.97, CGRectGetMinY(icon)) controlPoint2: CGPointMake(CGRectGetMinX(icon) + 35.59, CGRectGetMinY(icon))];
        [bezier3Path closePath];
        [UIColor.lightGrayColor setFill];
        [bezier3Path fill];
        
        
        //// Oval 2 Drawing
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(icon) + 6.5, CGRectGetMinY(icon) + 5.25, 8, 8)];
        [UIColor.lightGrayColor setFill];
        [oval2Path fill];
        
        
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = UIBezierPath.bezierPath;
        [bezier4Path moveToPoint: CGPointMake(CGRectGetMinX(icon) + 6.49, CGRectGetMinY(icon) + 23)];
        [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 13.9, CGRectGetMinY(icon) + 13.42)];
        [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 16.68, CGRectGetMinY(icon) + 17.25)];
        [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 21.32, CGRectGetMinY(icon) + 10.54)];
        [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 30.59, CGRectGetMinY(icon) + 23)];
        [bezier4Path addLineToPoint: CGPointMake(CGRectGetMinX(icon) + 6.49, CGRectGetMinY(icon) + 23)];
        [bezier4Path closePath];
        bezier4Path.lineJoinStyle = kCGLineJoinRound;
        
        [UIColor.lightGrayColor setFill];
        [bezier4Path fill];
    }
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 4, CGRectGetHeight(frame))];
    [UIColor.lightGrayColor setFill];
    [rectanglePath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - 4, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame)) * 0.00000 + 0.5), 4, CGRectGetHeight(frame) - floor((CGRectGetHeight(frame)) * 0.00000 + 0.5))];
    [UIColor.lightGrayColor setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), 4)];
    [UIColor.lightGrayColor setFill];
    [rectangle3Path fill];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + CGRectGetHeight(frame) - 4, CGRectGetWidth(frame), 4)];
    [UIColor.lightGrayColor setFill];
    [rectangle4Path fill];
}

@end
