//
//  MatrixView.h
//
//  Created by Cady Holmes on 10/19/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatrixView : UIView {
    float marginPadding;
    NSArray *initRow;
    NSMutableArray *_tiles;
    NSArray *oldTiles;
    int selectedTiles;
    int numberSelectedTiles;
    int selectedTilesCount;
    NSArray *colorArray;
}

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL animate;
@property (nonatomic) BOOL useLetters;
@property (nonatomic, strong) UIColor* lineColor;
@property (nonatomic, strong) NSArray *row;
@property (nonatomic, strong) NSArray *tiles;

- (instancetype)initWithWidth:(CGFloat)width andRow:(NSArray*)row;
- (void)addMarginPadding:(float)padding;
- (void)setOrigin:(CGPoint)origin;
- (void)makeTiles;
- (void)updateMatrixWithRow:(NSArray*)array;

@end
