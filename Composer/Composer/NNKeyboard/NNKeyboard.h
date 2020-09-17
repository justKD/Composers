//
//  NNKeyboard.h
//
//  Created by Cady Holmes.
//  Copyright (c) 2015-present Cady Holmes.
//

#import <UIKit/UIKit.h>
#import "OBShapedButton.h"

@protocol NNKeyboardDelegate;
@interface NNKeyboard : UIControl
{
@protected
    UIScrollView *keyboard;
    int lowestNote;
}

@property (nonatomic, weak) id<NNKeyboardDelegate> delegate;

@property (nonatomic) BOOL hidesNumbers;
@property (nonatomic) BOOL shouldDoCoolAnimation;
@property (nonatomic) float value;
@property (nonatomic) float borderSize;
@property (nonatomic) float roundness;
@property (nonatomic) float startupAnimationDuration;
@property (nonatomic) uint visibleKeys;
@property (nonatomic) uint octaves;
@property (nonatomic) uint touchesForScroll;
@property (nonatomic) uint lowestOctave;
@property (nonatomic) UIControlEvents touchBehavior;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *bgColor;

- (void)scrollTo:(float)octave withAnimation:(BOOL)animated;
- (void)drawKeyboard;
- (void)setNumberTouchesForScroll:(int)num;

@end

@protocol NNKeyboardDelegate <NSObject>
- (void)keyboardTouchDownEvent:(NNKeyboard*)keyboard;
- (void)keyboardTouchUpEvent:(NNKeyboard*)keyboard;
@end


