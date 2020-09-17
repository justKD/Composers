//
//  NNSplashScreenView.m
//
//  Created by Cady Holmes on 10/2/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import "NNSplashScreenView.h"

@implementation NNSplashScreenView

- (void)loadSplashScreenWithTitle:(NSString*)title {
    [self setBackgroundColor:[UIColor colorWithRed:242/255. green:240/255. blue:241/255. alpha:1]];
    [self setDefaults];
    titleText = title;
    CGFloat yOrigin = self.frame.size.height*.225;
    [self createTextPath:titleLayer frame:CGRectMake(0, yOrigin, self.frame.size.width, self.frame.size.height*.25) font:self.titleFont text:titleText];
    [self animateTitleLayer];
}

- (void)setDefaults {
    nnFont = CTFontCreateWithName(CFSTR("Georgia"), self.frame.size.width/10, NULL);

    if (!self.textOutlineColor) {
        self.textOutlineColor = [UIColor blackColor];
    }
    if (!self.textFillColor) {
        self.textFillColor = [UIColor blackColor];
    }
    if (!self.titleOutlineAnimationDuration) {
        self.titleOutlineAnimationDuration = 1.0;
    }
    if (!self.titleFillAnimationDuration) {
        self.titleFillAnimationDuration = .75;
    }
    if (!self.titleFont) {
        self.titleFont = CTFontCreateWithName(CFSTR("HelveticaNeue-CondensedBold"), self.frame.size.width/5, NULL);
    }
}

- (void)animateTitleLayer
{
    [titleLayer removeAllAnimations];
    
    titleLayer.hidden = NO;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = self.titleOutlineAnimationDuration;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillAnimation.duration = self.titleFillAnimationDuration;
    fillAnimation.fillMode = kCAFillModeForwards;
    fillAnimation.removedOnCompletion = NO;
    fillAnimation.fromValue = CFBridgingRelease([[UIColor clearColor] CGColor]);
    fillAnimation.toValue = CFBridgingRelease(self.textFillColor.CGColor);
    
    [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [titleLayer addAnimation:fillAnimation forKey:@"fillColor"];
            
            id<NNSplashScreenViewDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(titleDidFinish:)]) {
                [strongDelegate titleDidFinish:self];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self createTextPath:nnLayer frame:CGRectMake(0, self.frame.size.height*.375, self.frame.size.width, self.frame.size.height*.25) font:nnFont text:[NSString stringWithFormat:@"by notnatural"]];
                
                [self animateNNLayer];
            });
        }];
        [titleLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    [CATransaction commit];
}

- (void)animateNNLayer
{
    [nnLayer removeAllAnimations];
    
    nnLayer.hidden = NO;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = .45;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    fillAnimation.duration = .5;
    fillAnimation.fillMode = kCAFillModeForwards;
    fillAnimation.removedOnCompletion = NO;
    fillAnimation.fromValue = CFBridgingRelease([[UIColor clearColor] CGColor]);
    fillAnimation.toValue = CFBridgingRelease(self.textFillColor.CGColor);
    
    [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [nnLayer addAnimation:fillAnimation forKey:@"fillColor"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateNNLogo];
                
                id<NNSplashScreenViewDelegate> strongDelegate = self.delegate;
                if ([strongDelegate respondsToSelector:@selector(subTitleDidFinish:)]) {
                    [strongDelegate subTitleDidFinish:self];
                }
            });
        }];
        [nnLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    [CATransaction commit];
}

- (void)animateNNLogo
{
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small logo.pdf"]];
    logo.frame = CGRectMake(0, 0, 70, 70);
    logo.center = CGPointMake(self.frame.size.width/2, nnLayer.frame.origin.y+nnLayer.frame.size.height+70);
    [self addSubview:logo];
    
    UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logo.frame.origin.y+logo.frame.size.height, self.frame.size.width, 70)];
    urlLabel.textAlignment = NSTextAlignmentCenter;
    urlLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:self.frame.size.width/18];
    urlLabel.text = @"notnatural.co";
    [self addSubview:urlLabel];
    
    [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeSplash];
                
                id<NNSplashScreenViewDelegate> strongDelegate = self.delegate;
                if ([strongDelegate respondsToSelector:@selector(splashDidFinish:)]) {
                    [strongDelegate splashDidFinish:self];
                }
            });
        }];
        [logo.layer addAnimation:showAnimation() forKey:nil];
        [urlLabel.layer addAnimation:showAnimation() forKey:nil];
    [CATransaction commit];
}

- (void)removeSplash {
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished){
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }
     ];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
}

- (void)createTextPath:(CAShapeLayer*)layer frame:(CGRect)frame font:(CTFontRef)font text:(NSString*)text
{
    if (!secondAnim) {
        if (titleLayer != nil) {
            [titleLayer removeFromSuperlayer];
            titleLayer = nil;
        }
    } else {
        if (nnLayer != nil) {
            [nnLayer removeFromSuperlayer];
            nnLayer = nil;
        }
    }

    // Create path from text
    // See: http://www.codeproject.com/KB/iPhone/Glyph.aspx
    // License: The Code Project Open License (CPOL) 1.02 http://www.codeproject.com/info/cpol10.aspx
    CGMutablePathRef letters = CGPathCreateMutable();

    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)CFBridgingRelease(font), kCTFontAttributeName,
                           nil];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text
                                                                     attributes:attrs];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);

    // for each RUN
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++)
    {
        // Get FONT for this run
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // for each GLYPH in run
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++)
        {
            // get Glyph & Glyph-data
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            // Get PATH of outline
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];

    CGPathRelease(letters);
    CFRelease(font);

    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = frame;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = self.textOutlineColor.CGColor;
    pathLayer.fillColor = [[UIColor clearColor] CGColor];
    pathLayer.lineWidth = 4.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    if (!secondAnim) {
        titleLayer = pathLayer;
        [self.layer addSublayer:titleLayer];
        secondAnim = YES;
    } else {
        nnLayer = pathLayer;
        [self.layer addSublayer:nnLayer];
        secondAnim = NO;
        CFRelease(line);
    }
}

static CAAnimation* showAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@0.0];
    [opacity setToValue:@1.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.3;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}

@end
