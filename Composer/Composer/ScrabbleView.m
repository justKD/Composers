//
//  ScrabbleView.m
//
//  Created by Cady Holmes on 10/9/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import "ScrabbleView.h"
#import "nnKit.h"

@implementation ScrabbleView

- (instancetype)initWithFrame:(CGRect)frame andCharacters:(NSArray*)arrayOfStrings
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.characters = arrayOfStrings;
        tileArray = [[NSMutableArray alloc] initWithCapacity:[self.characters count]];
        tileCenterArray = [[NSMutableArray alloc] initWithCapacity:[self.characters count]];
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    self.userInteractionEnabled = YES;
    
    if (!self.tilePadding) {
        self.tilePadding = 2;
    }
    if (!self.tileColor) {
        self.tileColor = [UIColor whiteColor];
    }
}

- (void)getTileWidth {
    float width = self.frame.size.width;
    float count = 12; //[self.characters count];
    float paddingOffset = self.tilePadding * (count + 1);
    tileWidth = (width - paddingOffset) / count;
}

- (void)makeTiles {
    
    [self getTileWidth];
    
    float offset = 0;
    if (self.characters.count < 12) {
        float offsetCount = (12 - (float)self.characters.count) / 2;
        offset = (tileWidth*offsetCount)+(self.tilePadding*offsetCount);
    }

    NSString *ten = @"10";
    NSString *eleven = @"11";
    for (int i = 0; i < [self.characters count]; i++) {
        NSString *charString = [self.characters objectAtIndex:i];
        
        UILabel *charLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset+((tileWidth*i)+(self.tilePadding*i)+self.tilePadding), 0, tileWidth, tileWidth)];
        charLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:tileWidth*.8];
        charLabel.textAlignment = NSTextAlignmentCenter;
        charLabel.layer.borderColor = [UIColor blackColor].CGColor;
        charLabel.layer.borderWidth = self.tilePadding;
        charLabel.backgroundColor = self.tileColor;
        charLabel.center = CGPointMake(charLabel.center.x, self.bounds.size.height/2);
        charLabel.tag = [charString intValue];
        
        if (self.useLetters) {
            if ([charString isEqualToString:ten]) {
                charString = @"t";
            } else if ([charString isEqualToString:eleven]) {
                charString = @"e";
            }
        }
        charLabel.text = charString;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [charLabel addGestureRecognizer:pan];
        
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLP:)];
        [charLabel addGestureRecognizer:lp];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [charLabel addGestureRecognizer:tap];
        
        charLabel.userInteractionEnabled = YES;
        
        [self addSubview:charLabel];
        [tileArray addObject:charLabel];
        
        NSArray *center = @[[NSNumber numberWithFloat:charLabel.center.x],[NSNumber numberWithFloat:charLabel.center.y]];
        [tileCenterArray addObject:center];
    }
    
    [self getCollection];
}

- (void)handleLP:(UILongPressGestureRecognizer*)sender {
//    UILabel *label = (UILabel*)sender.view;
//    NSString *title = label.text;
    //[nnKit animateViewJiggle:sender.view];
    
    id<ScrabbleViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(longPressTile:)]) {
        [strongDelegate longPressTile:sender];
    }
}

- (void)handleTap:(UITapGestureRecognizer*)sender {
//    UILabel *label = (UILabel*)sender.view;
//    NSString *title = label.text;
    //[nnKit animateViewJiggle:sender.view];
    
    id<ScrabbleViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(tapTile:)]) {
        [strongDelegate tapTile:sender];
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)sender {

    //NSLog(@"%ld",sender.view.tag);
    
    //    if (sender.state == UIGestureRecognizerStateChanged) {
    //
    //    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self bringSubviewToFront:sender.view];
        [self animateView:sender.view toSize:1.5f withYDif:-tileWidth andAlpha:1];
        
    }
    
    long currentIndex = [tileArray indexOfObject:sender.view];
    long comparedIndex = -1;
    
    //NSLog(@"current index %ld",currentIndex);
    
    float x = [sender locationInView:self].x;
    //sender.view.center = [sender locationInView:self];
    
    for (UILabel *tile in tileArray) {
        if (tile != sender.view) {
            float tileX = tile.center.x;
            float minBoundary = tileX - ((tileWidth/2)+(self.tilePadding/2)) + 1;
            float maxBoundary = tileX + ((tileWidth/2)+(self.tilePadding/2)) - 1;
            
            if (x > minBoundary && x < maxBoundary) {
                if ([tileArray indexOfObject:tile] != currentIndex) {
                    comparedIndex = [tileArray indexOfObject:tile];
                }
            }
        }
    }
    
    if (comparedIndex < 0) {
        comparedIndex = currentIndex;
    }
    
    if (comparedIndex != currentIndex) {
        [tileArray removeObjectAtIndex:currentIndex];
        [tileArray insertObject:sender.view atIndex:comparedIndex];
        
        for (int i = 0; i < [tileArray count]; i++) {
            NSArray *centerArray = [tileCenterArray objectAtIndex:i];
            CGPoint center = CGPointMake([[centerArray objectAtIndex:0] floatValue], [[centerArray objectAtIndex:1] floatValue]);
            [self animateViewToCenter:[tileArray objectAtIndex:i] toCenter:center];
        }
        
    } else {
        NSArray *centerArray = [tileCenterArray objectAtIndex:(int)comparedIndex];
        CGPoint center = CGPointMake([[centerArray objectAtIndex:0] floatValue], [[centerArray objectAtIndex:1] floatValue]);
        [self animateViewToCenter:sender.view toCenter:center];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self animateView:sender.view toSize:1.f withYDif:0 andAlpha:1];
        
        [self getCollection];
        
        id<ScrabbleViewDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(collectionDidUpdate:)]) {
            [strongDelegate collectionDidUpdate:self];
        }
    }
}

- (void)getCollection {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:tileArray.count];
    NSString *text;
    NSString *ten = @"t";
    NSString *eleven = @"e";
    
    for (int i = 0; i < tileArray.count; i++) {
        UILabel *tile = [tileArray objectAtIndex:i];
        text = tile.text;
        
        if (text == ten) {
            text = @"10";
        } else if (text == eleven) {
            text = @"11";
        }

        [arr addObject:text];
    }
    
    self.collection = [NSArray arrayWithArray:arr];
}

- (void)animateViewToCenter:(UIView*)view toCenter:(CGPoint)center {
    [UIView animateWithDuration:.3f
                          delay:0.0
         usingSpringWithDamping:.65f
          initialSpringVelocity:.08f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.center = center;
                     }completion:^(BOOL finished){
                     }];
}

- (void)animateView:(UIView*)view toSize:(CGFloat)size withYDif:(CGFloat)yDif andAlpha:(CGFloat)alpha {
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:.3f
          initialSpringVelocity:10.0f
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity, size, size);
                         CGAffineTransform translate = CGAffineTransformMakeTranslation(0, yDif);
                         CGAffineTransform transform = CGAffineTransformConcat(scale, translate);
                         view.transform = transform;
                         view.alpha = alpha;
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
