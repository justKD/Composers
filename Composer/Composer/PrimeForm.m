//
//  PrimeForm.m
//
//  Created by Cady Holmes on 3/14/16.
//  Copyright © 2016-present. All rights reserved.
//

#import "PrimeForm.h"

@implementation PrimeForm

- (void)findPrimeForm:(NSArray*)set {
    
    /*------------------*/
    /* The method for "tie-breaking" hexachordal prime form follows Forte's method rather than Rahn's */
    /*------------------*/
    
    /* Check for first candidate for Prime Form */
    NSArray *firstPrime = [self testPrimeForm:set];
    /* Check for the inversion of that candidate */
    NSArray *secondPrime = [self checkPrimeInversion:firstPrime];
    
    /* Determine which is the actual Prime Form and which is the Prime Inversion */
    int first = 0;
    int second = 0;
    
    for (int i = 0; i < firstPrime.count; i++) {
        int val = [[firstPrime objectAtIndex:i] intValue];
        first = first + val;
    }
    
    for (int i = 0; i < secondPrime.count; i++) {
        int val = [[secondPrime objectAtIndex:i] intValue];
        second = second + val;
    }
    
    if (first < second) {
        self.primeForm = firstPrime;
        self.primeInversion = secondPrime;
    } else {
        self.primeForm = secondPrime;
        self.primeInversion = firstPrime;
    }
    
    poss = nil;
    
    //NSLog(@"%@",firstPrime);
    //NSLog(@"%@",secondPrime);
}

- (NSArray*)testPrimeForm:(NSArray*)set {
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil
                                                                     ascending:YES
                                                                    comparator:^(id obj1, id obj2)
                                        {
                                            return [obj1 compare:obj2 options:NSNumericSearch];
                                        }
                                        ];
    
    /* Sort set to be in numerical order */
    NSArray *sortedNumbers = [set sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:sortedNumbers];
    /* Rotate the set and determine which ordering is the most compact interval */
    poss = [NSMutableArray arrayWithObject:[NSArray arrayWithArray:arr]];
    int smallestCompare = 12;
    for (int i = 0; i < arr.count; i++) {
        if (i > 0) {
            for (int j = 1; j > 0; j--) {
                NSObject* obj = [arr lastObject];
                [arr insertObject:obj atIndex:0];
                [arr removeLastObject];
            }
        }
        NSArray *temp = [NSArray arrayWithArray:arr];
        
        int compare = ([[temp objectAtIndex:temp.count-1] intValue] - [[temp objectAtIndex:0] intValue]);
        if (compare < 0) {
            compare = compare + 12;
        }
        
        if (compare < smallestCompare) {
            smallestCompare = compare;
            poss = [NSMutableArray arrayWithObject:temp];
        } else if (compare == smallestCompare) {
            [poss addObject:temp];
        }
        
    }
    
    /* If there are ties for most compact interval, loop through those orderings and determine which have the most compact successive intervals */
    NSArray *result = [NSArray arrayWithArray:poss];
    if (poss.count < 2) {
        result = [NSArray arrayWithArray:[poss objectAtIndex:0]];
    } else {
        
        //        smallestCompare = 12;
        //        NSArray *arr2 = [NSArray arrayWithArray:poss];
        //        for (int i = 0; i < arr2.count; i++) {
        //            arr = [NSMutableArray arrayWithArray:[arr2 objectAtIndex:i]];
        //            for (int j = 1; j < arr.count; j++) {
        //                int compare = ([[arr objectAtIndex:j] intValue] - [[arr objectAtIndex:0] intValue]);
        //                if (compare < 0) {
        //                    compare = compare + 12;
        //                }
        //                if (compare < smallestCompare) {
        //                    smallestCompare = compare;
        //                    poss = [NSMutableArray arrayWithObject:arr];
        //                } else if (compare == smallestCompare) {
        //                    [poss addObject:arr];
        //                }
        //            }
        //        }
        
        if (poss.count < 2) {
            result = [NSArray arrayWithArray:[poss objectAtIndex:0]];
        } else {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            int holdVal = 0;
            for (int i = 0; i < poss.count; i++) {
                NSArray *arr = [poss objectAtIndex:i];
                
                for (int j = 0; j < arr.count; j++) {
                    int val = 0;
                    if ([arr objectAtIndex:0] > 0) {
                        val = [[arr objectAtIndex:j] intValue] - [[arr objectAtIndex:0] intValue];
                        if (val < 0) {
                            val = val + 12;
                        }
                    } else {
                        val = [[arr objectAtIndex:j] intValue];
                    }
                    holdVal = holdVal + val;
                }
                
                [tempArray addObject:[NSNumber numberWithInt:holdVal]];
                holdVal = 0;
            }
            
            int thisOne = 0;
            smallestCompare = [[tempArray objectAtIndex:0] intValue];
            for (int i = 1; i < tempArray.count; i++) {
                if ([[tempArray objectAtIndex:i] intValue] < smallestCompare) {
                    smallestCompare = [[tempArray objectAtIndex:i] intValue];
                    thisOne = i;
                }
            }
            
            result = [poss objectAtIndex:thisOne];
        }
    }
    
    /* If the result does not begin on T0, transpose the set appropriately */
    if ([result objectAtIndex:0] > 0) {
        poss = nil;
        poss = [[NSMutableArray alloc] init];
        int val = [[result objectAtIndex:0] intValue];
        for (int i = 0; i < result.count; i++) {
            int newVal = [[result objectAtIndex:i] intValue] - val;
            if (newVal < 0) {
                newVal = newVal + 12;
            }
            [poss addObject:[NSNumber numberWithInt:newVal]];
        }
        result = [NSArray arrayWithArray:poss];
    }
    
    return result;
}

- (NSArray*)checkPrimeInversion:(NSArray*)set {
    poss = nil;
    poss = [[NSMutableArray alloc] init];
    for (int i = 0; i < set.count; i++) {
        int val = (12 - [[set objectAtIndex:i] intValue]) % 12;
        [poss addObject:[NSString stringWithFormat:@"%d",val]];
    }
    NSArray *result = [self testPrimeForm:poss];
    return result;
}

- (NSArray*)transformSet:(NSArray*)set withTransposition:(int)t andInversion:(BOOL)inv {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < set.count; i++) {
        int pc = [[set objectAtIndex:i] intValue];
        if (inv) {
            pc = (12 - pc) % 12;
        }
        pc = (pc + t) % 12;
        [result addObject:[NSNumber numberWithInt:pc]];
    }
    
    return result;
}

@end
