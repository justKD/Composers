//
//  ScrabbleView.h
//
//  Created by Cady Holmes on 10/9/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrabbleViewDelegate;
@interface ScrabbleView : UIView
{
    NSMutableArray *tileArray;
    NSMutableArray *tileCenterArray;
    float tileWidth;
}

@property (nonatomic, strong) NSArray *collection;
@property (nonatomic, weak) id<ScrabbleViewDelegate> delegate;
@property (nonatomic, strong) NSArray *characters;
@property (nonatomic) float tilePadding;
@property (nonatomic, strong) UIColor *tileColor;
@property (nonatomic) BOOL useLetters;

- (instancetype)initWithFrame:(CGRect)frame andCharacters:(NSArray*)arrayOfStrings;
- (void)makeTiles;

@end

@protocol ScrabbleViewDelegate <NSObject>
- (void)longPressTile:(UILongPressGestureRecognizer *)sender;
- (void)tapTile:(UITapGestureRecognizer *)sender;
- (void)collectionDidUpdate:(ScrabbleView *)view;
@end
