//
//  PrimeForm.h
//
//  Created by Cady Holmes on 3/14/16.
//  Copyright © 2016-present Cady Holmes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrimeForm : NSObject {
    NSMutableArray *poss;
}

@property (nonatomic, strong) NSArray *primeForm;
@property (nonatomic, strong) NSArray *primeInversion;

- (void)findPrimeForm:(NSArray*)set;
- (NSArray*)transformSet:(NSArray*)set withTransposition:(int)t andInversion:(BOOL)inv;

@end


/*
 
 - (void)testPrimeForm {
 
 // Expects an array of numbers as strings.
 
 NSArray *set = @[@"0",@"1",@"3",@"5",@"9",@"10"];
 
 PrimeForm *prime = [[PrimeForm alloc] init];
 [prime findPrimeForm:set];
 
 NSLog(@"%@",prime.primeForm);
 }
 
 */
