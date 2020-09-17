//
//  MatrixView.m
//
//  Created by Cady Holmes on 10/19/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import "MatrixView.h"
#import "UIColor+NNColors.h"

@implementation MatrixView

- (instancetype)initWithWidth:(CGFloat)width andRow:(NSArray*)row {
    self = [super initWithFrame:CGRectMake(0, 0, width, width)];
    if (self) {
        
        initRow = row;
        [self setDefaults];
        [self drawLines];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self makeTiles];
            [self addTiles];
            
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            [self addGestureRecognizer:swipe];
        });
    }

    return self;
}

- (void)setDefaults {
    colorArray = @[[UIColor flatYellowColor],
                   [UIColor flatBlueColor],
                   [UIColor flatRedColor],
                   [UIColor flatGreenColor],
                   [UIColor flatPurpleColor],
                   [UIColor flatTealColor],
                   
                   [UIColor flatDarkGreenColor],
                   [UIColor flatGrayColor],
                   [UIColor flatDarkBlueColor],
                   [UIColor flatDarkRedColor],
                   [UIColor flatDarkPurpleColor],
                   [UIColor flatGrayColor],
                   ];
    numberSelectedTiles = -1;
    selectedTilesCount = 0;
    
    if (!self.lineColor) {
        self.lineColor = [UIColor blackColor];
    }
    if (!self.lineWidth) {
        self.lineWidth = 1;
    }
    if (!self.row) {
        self.row = initRow;
    }
}

- (void)drawLines {
    float count = initRow.count;
    float startX;
    float startY;
    float endX;
    float endY;

    for (int i = 1; i < count; i++) {
        
        startX = (self.frame.size.width / initRow.count) * i;
        startY = self.bounds.origin.y;
        endY = self.frame.size.width;
        [self drawLineFrom:CGPointMake(startX, startY) to:CGPointMake(startX, endY)];
        
        startX = self.bounds.origin.x;
        startY = (self.frame.size.width / initRow.count) * i;
        endX = self.frame.size.width;
        [self drawLineFrom:CGPointMake(startX, startY) to:CGPointMake(endX, startY)];
    }
}

- (void)makeTiles {

    CGFloat tileWidth = self.frame.size.width / self.row.count;
    _tiles = [[NSMutableArray alloc] init];
   
//    NSMutableArray *random = [self randomRowOfCardinality:12];
//    NSMutableArray *matrix = [self calculateMatrix:random];
    NSMutableArray *matrix = [self calculateMatrix:self.row];
    NSMutableArray *aRow;
    
    for (int x = 0; x < matrix.count; x++) {
        aRow = [NSMutableArray arrayWithArray:[matrix objectAtIndex:x]];
        for (int y = 0; y < aRow.count; y++) {
            
            CGRect frame = CGRectMake(0 + (tileWidth * y), 0 + (tileWidth * x), tileWidth, tileWidth);
            UILabel *tile = [[UILabel alloc] initWithFrame:frame];
            
            NSString *text = [NSString stringWithFormat:@"%@",[aRow objectAtIndex:y]];
            tile.tag = [text intValue];;
            if (self.useLetters) {
                if ([text isEqualToString:@"10"]) {
                    text = @"t";
                } else if ([text isEqualToString:@"11"]) {
                    text = @"e";
                }
            }
            
            tile.text = text;
            tile.textAlignment = NSTextAlignmentCenter;
            tile.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:tileWidth*.8];
            tile.userInteractionEnabled = YES;
            tile.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            UITapGestureRecognizer *tapTile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTile:)];
            [tile addGestureRecognizer:tapTile];
            
            [_tiles addObject:tile];
        }
    }
    
    self.tiles = [NSArray arrayWithArray:_tiles];
}

- (void)tapTile:(UITapGestureRecognizer*)sender {
    UIColor *color;
    numberSelectedTiles = (numberSelectedTiles+1) % 12;
    if (sender.view.layer.backgroundColor != [UIColor clearColor].CGColor) {
        selectedTilesCount = selectedTilesCount - 1;
        color = [UIColor clearColor];
    } else {
        selectedTilesCount = selectedTilesCount + 1;
        if (selectedTilesCount == 1) {
            numberSelectedTiles = 0;
        }
        color = [colorArray objectAtIndex:numberSelectedTiles];
    }
    
    for (int i = 0; i < _tiles.count; i++) {
        UILabel *tile = [_tiles objectAtIndex:i];
        //tile.layer.backgroundColor = [UIColor clearColor].CGColor;
        if (tile.tag == sender.view.tag) {
            selectedTiles = (int)tile.tag;
            
            CGFloat del = ((arc4random() % 10) * .01) + .01;
            [UIView animateWithDuration:.3
                                  delay:del
                                options: (UIViewAnimationOptionAllowUserInteraction |
                                          UIViewAnimationOptionCurveEaseInOut)
                             animations:^{
                                 tile.layer.backgroundColor = color.CGColor;
                             } completion:^(BOOL finished){
                                 if (finished) {
                                     
                                 }
                             }
             ];
        }
    }

}

- (void)handleSwipe:(UISwipeGestureRecognizer*)sender {
    numberSelectedTiles = -1;
    selectedTilesCount = 0;
    for (UILabel *tile in _tiles) {
        CGFloat del = ((arc4random() % 10) * .01) + .01;
        
        [UIView animateWithDuration:.3
                              delay:del
                            options: (UIViewAnimationOptionAllowUserInteraction |
                                      UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             tile.layer.backgroundColor = [UIColor clearColor].CGColor;
                         } completion:^(BOOL finished){
                             if (finished) {
                                 
                             }
                         }
         ];
    }
}

- (void)addTiles {
    for (UILabel *tile in _tiles) {
        [self addSubview:tile];
    }
}

- (void)updateTiles {
    oldTiles = [NSArray arrayWithArray:_tiles];
    [self makeTiles];
    
    for (int i = 0; i < oldTiles.count; i++) {
        [UIView transitionFromView:[oldTiles objectAtIndex:i]
                            toView:[_tiles objectAtIndex:i]
                          duration:1
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:nil];
    }
    
    oldTiles = nil;
}

- (void)updateMatrixWithRow:(NSArray *)arrayOfStrings {
    self.row = arrayOfStrings;
    [self updateTiles];
}

- (void)drawLineFrom:(CGPoint)start to:(CGPoint)end {
    
    UIGraphicsBeginImageContext(self.bounds.size);
    
    UIBezierPath* path = [UIBezierPath bezierPath];

    [path moveToPoint: CGPointMake(start.x, start.y)];
    [path addLineToPoint:CGPointMake(end.x, end.y)];
    [path stroke];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
        
    layer.path = path.CGPath;
    layer.strokeColor = [self.lineColor CGColor];
    layer.lineWidth = self.lineWidth;
    layer.lineJoin = kCALineJoinBevel;
    layer.drawsAsynchronously = YES;
    layer.lineCap = kCALineCapRound;
    [self.layer addSublayer:layer];
    
    UIGraphicsEndImageContext();
}

- (void)addMarginPadding:(float)padding {
    marginPadding = padding;
    self.frame = CGRectMake(self.frame.origin.x+marginPadding, self.frame.origin.y+marginPadding, self.frame.size.width-(marginPadding*2), self.frame.size.height-(marginPadding*2));

    if (self.layer.sublayers) {
        self.layer.sublayers = nil;
    }

    [self drawLines];
}

- (void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x+marginPadding, origin.y+marginPadding, self.frame.size.width, self.frame.size.width);
}


- (int)fixMod:(int)a b:(int)b
{
    if(b < 0) {                         //you can check for b == 0 separately and do what you want
        return [self fixMod:-a b:-b];
    }
    int ret = a % b;
    if(ret < 0) {
        ret+=b;
    }
    return ret;
}

- (NSMutableArray*)randomRowOfCardinality:(int)count {
    NSMutableArray *randomPrime = [[NSMutableArray alloc]initWithCapacity:count];
    
    bool writing = true;
    
    while (writing) {
        //fill array without repeating numbers
        int pitch = arc4random_uniform(count);
        if (![randomPrime containsObject:[NSNumber numberWithInt:pitch]]) {
            [randomPrime addObject:[NSNumber numberWithInt:pitch]];
        }
        
        if ([randomPrime count] == count) {
            writing = !writing;
        }
    }
    
    //NSLog(@"%@", randomPrime);
    return  randomPrime;
}


- (NSMutableArray*)calculateMatrix:(NSArray*)prime {
    NSMutableArray *matrix = [[NSMutableArray alloc ]initWithCapacity:[prime count]];
    
    //add prime
    [matrix addObject:prime];
    
    //add empty arrays for rest of matrix
    for (int i = 0; i <[prime count] - 1; i++){
        [matrix addObject:[[NSMutableArray alloc] initWithCapacity:[prime count]]];
    }
    
    for (int i = 0; i < [prime count]; i++) {
        for (int j = 1; j < [prime count]; j++) {
            NSMutableArray *row = [matrix objectAtIndex:j];
            int x = [(NSNumber *)[prime objectAtIndex:i] intValue];
            int y = [(NSNumber *)[prime objectAtIndex:j] intValue];
            int z = [(NSNumber *)[prime objectAtIndex:0] intValue];
            int pitch = [self fixMod:(x + ((y - z) * -1)) b:12];
            [row insertObject:[NSNumber numberWithInt:pitch] atIndex:i];
        }
    }
    //NSLog(@"%@", matrix);
    return matrix;
}

@end
