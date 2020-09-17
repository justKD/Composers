//
//  NNSplashScreenView.h
//
//  Created by Cady Holmes on 10/2/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol NNSplashScreenViewDelegate;
@interface NNSplashScreenView : UIView {
    NSString *titleText;
    CAShapeLayer *titleLayer;
    CAShapeLayer *nnLayer;
    CTFontRef nnFont;
    
    BOOL secondAnim;
}

@property (nonatomic, weak) id<NNSplashScreenViewDelegate> delegate;

@property (nonatomic, strong) UIColor *textOutlineColor;
@property (nonatomic, strong) UIColor *textFillColor;
@property (nonatomic) CTFontRef titleFont;
//CTFontCreateWithName(CFSTR("Zapfino"), 72.0f, NULL);
@property (nonatomic) float titleOutlineAnimationDuration;
@property (nonatomic) float titleFillAnimationDuration;

- (void)loadSplashScreenWithTitle:(NSString*)title;

@end

@protocol NNSplashScreenViewDelegate <NSObject>
- (void)titleDidFinish:(NNSplashScreenView*)view;
- (void)subTitleDidFinish:(NNSplashScreenView*)view;
- (void)splashDidFinish:(NNSplashScreenView*)view;
@end
