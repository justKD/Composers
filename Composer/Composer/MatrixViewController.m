//
//  MatrixViewController.m
//
//  Created by Cady Holmes on 10/9/15.
//  Copyright © 2015-present Cady Holmes. All rights reserved.
//

#import "MatrixViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SoundBankPlayer.h"
#import "NNKeyboard.h"
#import "ScrabbleView.h"
#import "MatrixView.h"
#import "nnKit.h"
#import "PrimeForm.h"
#import "MONActivityIndicatorView.h"
#import "kdPrimitiveDataStore.h"
#import <StoreKit/StoreKit.h>

#define kFadeTime 0.3

//static inline CGFloat SH() { return [[UIScreen mainScreen] bounds].size.height; }
//static inline CGFloat SW() { return [[UIScreen mainScreen] bounds].size.width; }
//static inline CGFloat SB() { return [UIApplication sharedApplication].statusBarFrame.size.height; }
//static inline CGFloat OX(UIView *view) { return view.frame.origin.x; }
//static inline CGFloat OY(UIView *view) { return view.frame.origin.y; }
//static inline CGFloat VH(UIView *view) { return view.frame.size.height; }
//static inline CGFloat VW(UIView *view) { return view.frame.size.width; }

@interface MatrixViewController () <ScrabbleViewDelegate,NNKeyboardDelegate, MONActivityIndicatorViewDelegate>
{
    NNKeyboard *kb;
    ScrabbleView *scrabbleView;
    MatrixView *matrixView;
    UIView *toolbar;
    int lastSliderValue;
    
    BOOL initial;
    BOOL singleSelect;
    BOOL justOne;
    BOOL oneAlert;
    BOOL tapTempUnlock;
    BOOL tempUnlock;
    BOOL testAds;
    
    UIView *helpView;
    UIView *helpPopup;
    BOOL helpPopupVisible;
    UIView *popup;
    UILabel *warning;
    NSMutableArray *chord;
    ScrabbleView *chordView;
    NSString *selectedTile;
    
    UILabel *nn;
    
    UIView *primeView;
    UIButton *getPrime;
    UIButton *helpButton;
    UIButton *setCollection;
    UIButton *proButton;
    
    UIColor *bgColor;
    
    // SoundBankPlayer properties
    SoundBankPlayer *soundBankPlayer;
    NSTimer *timer;
    BOOL playingArpeggio;
    NSArray *arpeggioNotes;
    NSUInteger arpeggioIndex;
    CFTimeInterval arpeggioStartTime;
    CFTimeInterval arpeggioDelay;
    
    CGFloat iAdHeight;
    BOOL removeAds;
    BOOL bannerIsVisible;
    
    MONActivityIndicatorView *spinner;
    NSArray* colorTheme;
    
    kdPrimitiveDataStore *globalSettings;
}

@property (nonatomic, strong) UIView *parentView;

@end

@implementation MatrixViewController

//#define kRemoveAdsProductIdentifier @"co.notnatural.composer.removeads"

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeSoundBankPlayer];
    [self loadEverything];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appIsActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self handleOpenCount];
}

- (void)handleOpenCount {
    if (!globalSettings.data) {
        int openCount = 1;
        [globalSettings save:@[[NSNumber numberWithInt:openCount]]];
    } else {
        int openCount = [[globalSettings.data lastObject] intValue];
        openCount++;
        openCount = openCount % 10;
        openCount = MAX(openCount, 1);
        
        [globalSettings save:@[[NSNumber numberWithInt:openCount]]];
        
        if (openCount == 3) {
            [SKStoreReviewController requestReview];
        }
    }
}

- (void)appIsActive {
    [self makeSlider];
    //[self animatePulse];
}

- (void)loadEverything {
//    removeAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeAds"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //testAds = YES;
    removeAds = YES;
    
    bgColor = [UIColor colorWithRed:242/255. green:240/255. blue:241/255. alpha:1]; //UIColorFromHex(0xF2F0F1);
    
//    if (!removeAds) {
//        if ([nnKit isIPad]) {
//            iAdHeight = 90;
//        } else {
//            iAdHeight = 50;
//        }
//    } else {
//        iAdHeight = 0;
//    }
    
    [self.view setBackgroundColor:bgColor];
    lastSliderValue = 12;
    [self makeKeyboard];
    [self makeScrabbleView:12];
    [self makeMatrixView];
    [self makeToolbar];
    
    [self.view bringSubviewToFront:scrabbleView];
    
//    if (!removeAds) {
//        [self addAds];
//        [self addProModeButton];
//
//        [GADRewardBasedVideoAd sharedInstance].delegate = self;
//        [self loadRewardedAd];
//        //[self createAndLoadInterstitial];
//    }
}

//- (void)addProModeButton {
//    proButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"exclamation.pdf"] frame:CGRectMake(0, 0, SW()/5, SW()/5) method:@"tapProMode:" fromClass:self];
//    proButton.center = CGPointMake(SW()*.15, SH()*.83);
//
//    proButton.layer.shadowColor = [UIColor flatOrangeColor].CGColor;
//    proButton.layer.shadowRadius = SW()/12;
//    proButton.layer.shadowOpacity = 1;
//    proButton.layer.masksToBounds = NO;
//
////    UIImageView *prolabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"promode.pdf"]];
////    prolabel.frame = CGRectMake(proButton.center.x, proButton.frame.origin.y, SW()/3, SW()/3);
////    prolabel.center = CGPointMake(prolabel.center.x, proButton.center.y);
////    prolabel.userInteractionEnabled = NO;
//
//    [self.view addSubview:proButton];
//    //[self.view addSubview:prolabel];
//
//}

- (void)animatePulse {
    if (proButton) {
        [nnKit animatePulse:proButton.layer shrinkTo:.75 withDuration:.8];
    }
}

//- (void)tapProMode:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//
//    if (!tapTempUnlock) {
//        [UIView animateWithDuration:0.3
//                              delay:0.1
//                            options: (UIViewAnimationOptionAllowUserInteraction |
//                                      UIViewAnimationOptionCurveEaseInOut)
//                         animations:^{
//                             [proButton setFrame:CGRectMake(0, 0, SW()/9, SW()/9)];
//                             [proButton setCenter:CGPointMake(SW()*.1, SH()*.875)];
//                         } completion:^(BOOL finished){
//                             if (finished) {
//                                 [proButton.layer removeAllAnimations];
//                             }
//                         }
//         ];
//        tapTempUnlock = TRUE;
//    }
//
//    [self showAdPopup];
//}

//- (void)showAdPopup {
//    helpPopupVisible = YES;
//
//    [nnKit addCloseViewTo:self.view withAlpha:0 withCloseMethod:@"closeHelpPopup" fromClass:self];
//    helpPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, matrixView.frame.size.width*.9, matrixView.frame.size.height*.9)];
//    helpPopup.backgroundColor = [UIColor colorWithRed:242/255. green:240/255. blue:241/255. alpha:1];
//    helpPopup.center = matrixView.center;
//
//    [self addShadowTo:helpPopup.layer];
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHelpPopup)];
//    [helpPopup addGestureRecognizer:tap];
//
//    CGFloat fontSize = SW()/24;
//    if ([nnKit isIPad]) {
//        fontSize = SW()/36;
//    }
//    if ([nnKit isIPhone4]) {
//        fontSize = SW()/30;
//    }
//    UIFont *font = [UIFont fontWithName:nnKitGlobalFont size:fontSize];
//    UIColor *textColor = [UIColor blackColor];
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
//                                                                        0,
//                                                                        matrixView.frame.size.width*.8,
//                                                                        matrixView.frame.size.height*.8)];
//    NSString *text = [NSString stringWithFormat:@"Hey, so you can watch a short video to unlock Prime Form calculations and Easy Set Input just for this session.\n\n(•̀ᴗ•́)و ̑̑"];
//
//    [textView setCenter:CGPointMake(VW(helpPopup)/2,VH(helpPopup)/2)];
//    [textView setBackgroundColor:[UIColor clearColor]];
//    [textView setTextAlignment:NSTextAlignmentCenter];
//    [textView setTextColor:textColor];
//    [textView setFont:font];
//    [textView setText:text];
//    textView.userInteractionEnabled = NO;
//
//    UIButton *ok = [nnKit makeButtonWithCenter:CGPointMake(helpPopup.bounds.size.width/2, helpPopup.bounds.size.height*.55) fontSize:[nnKit fontSize:1]*2 title:@"OK!" method:@"watchAd" fromClass:self];
//    UIButton *no = [nnKit makeButtonWithCenter:CGPointMake(helpPopup.bounds.size.width/2, helpPopup.bounds.size.height*.8) fontSize:[nnKit fontSize:4] title:@"Not now..." method:@"tapNo" fromClass:self];
//
//    [helpPopup addSubview:textView];
//    [helpPopup addSubview:ok];
//    [helpPopup addSubview:no];
//    [self.view addSubview:helpPopup];
//    [nnKit animateViewGrowAndShow:helpPopup or:nil completion:nil];
//}

//- (void)watchAd {
//    [self closeHelpPopup];
//
//    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
//        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self];
//    }
//}

- (void)tapNo {
    [self closeHelpPopup];
}

- (void)createParentView {
    self.parentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.parentView setBackgroundColor:[UIColor clearColor]];
    [self.parentView setUserInteractionEnabled:NO];
    [self.view addSubview:self.parentView];
}

- (void)makeSoundBankPlayer {
    soundBankPlayer = [[SoundBankPlayer alloc] init];
    [soundBankPlayer setSoundBank:@"Piano"];
}

- (void)makeScrabbleView:(int)cardinality {
    
    if (scrabbleView) {
        [scrabbleView removeFromSuperview];
        scrabbleView = nil;
    }
    
    NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:cardinality];
    
    for (int i = 0; i < cardinality; i++) {
        NSString *num = [NSString stringWithFormat:@"%d",i];
        [chars addObject:num];
    }
    
    CGFloat height = SW()/12+2;
    CGFloat offset = 20;
    if ([nnKit isIPhone4]) {
        offset = 5;
    }
    scrabbleView = [[ScrabbleView alloc] initWithFrame:CGRectMake(0, SH()-(VH(kb)+iAdHeight)-height-offset, SW(), height) andCharacters:chars];
    [scrabbleView setDelegate:self];
    [scrabbleView setUseLetters:YES];
    [scrabbleView makeTiles];
    
    [self.view addSubview:scrabbleView];
    [self.view bringSubviewToFront:scrabbleView];
}

- (void)viewDidAppear:(BOOL)animated {
//    if (!removeAds && !tempUnlock) {
//        [self loadHelp];
//    }
    [self animatePulse];
}

- (void)addLPtoView:(UIView*)view withSelector:(NSString*)selector {
    UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:NSSelectorFromString(selector)];
    [view addGestureRecognizer:lp];
}

//- (void)loadHelp {
//    justOne = YES;
//    NSString *text = [NSString stringWithFormat:@"Welcome, Important Human!\n\nCheck out the (?) button!! \n\n(This message doesn't appear for PRO USERS)\n\n\n•|龴◡龴|•"];
//    if (!helpPopupVisible) {
//        [self showHelpPopupWithText:text withLP:nil andLink:0];
//    }
//    [nnKit animatePulse:helpButton.layer to:.5];
//}

#pragma mark - scrabble view delegate
- (void)longPressTile:(UILongPressGestureRecognizer *)sender {
    [self tileHelp:sender];
}

- (void)tapTile:(UITapGestureRecognizer *)sender {
    [scrabbleView bringSubviewToFront:sender.view];
    [nnKit animateSize:sender.view size:1.5];
    
    singleSelect = YES;
    UILabel *tile = (UILabel*)sender.view;
    selectedTile = tile.text;
    if ([selectedTile isEqualToString:@"t"]) {
        selectedTile = @"10";
    }
    if ([selectedTile isEqualToString:@"e"]) {
        selectedTile = @"11";
    }
    
    if (!justOne) {
        justOne = YES;
        [self openSetCollectionPopupWithText:@"Select a number."];
    }
}

- (void)collectionDidUpdate:(ScrabbleView *)view {
    //NSLog(@"%@",scrabbleView.collection);
    if (chordView) {
        
    } else {
        [matrixView updateMatrixWithRow:scrabbleView.collection];
    }
}
/*-------------------------------*/
/*-------------------------------*/
/*-------------------------------*/

- (void)makeKeyboard {
    CGFloat height = (SH()*.25)-iAdHeight;
    //    if ([nnKit isIPad]) {
    //        height = (SH()*.15)-iAdHeight;
    //    }
    
    if (kb) {
        [kb removeFromSuperview];
        kb = nil;
    }
    kb = [[NNKeyboard alloc] initWithFrame:CGRectMake(3,SH()-(SH()*.25)-3,SW()-6,height)];
    [kb addTarget:self action:@selector(handleKB:) forControlEvents:UIControlEventValueChanged];
    kb.shouldDoCoolAnimation = YES;
    kb.startupAnimationDuration = .4;
    kb.lowestOctave = 1;
    kb.octaves = 9;
    kb.roundness = 5;
    kb.delegate = self;
    if ([nnKit isIPad]) {
        kb.visibleKeys = 15;
    }
    [self.view addSubview:kb];
    
    [self addLPtoView:kb withSelector:@"pianoHelp:"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [kb scrollTo:3 withAnimation:YES];
    });
    
    //    kb.bgColor = [UIColor blueColor];
    //    kb.touchesForScroll = 2;
    //    kb.visibleKeys = 8;
    //    kb.borderSize = 6;
}

- (void)handleKB:(NNKeyboard *)sender {
    [soundBankPlayer noteOn:sender.value gain:.5f];
}

- (void)makeMatrixView {
    //        matrixView = [[MatrixView alloc] initWithWidth:SW() andRow:scrabbleView.collection];
    //        [matrixView setOrigin:CGPointMake(0, SB())];
    //        [matrixView addMarginPadding:2];
    //        [matrixView setUseLetters:YES];
    
    MatrixView *newView;
    if ([nnKit isIPad]) {
        newView = [[MatrixView alloc] initWithWidth:SW()*.75 andRow:scrabbleView.collection];
    } else {
        if ([nnKit isIPhone4]) {
            newView = [[MatrixView alloc] initWithWidth:SW()*.85 andRow:scrabbleView.collection];
        } else {
            newView = [[MatrixView alloc] initWithWidth:SW() andRow:scrabbleView.collection];
        }
    }
    
    [newView setOrigin:CGPointMake(0, SB())];
    [newView setCenter:CGPointMake(SW()/2, newView.center.y)];
    [newView addMarginPadding:2];
    [newView setUseLetters:YES];
    newView.backgroundColor = bgColor;
    
    [self addLPtoView:newView withSelector:@"matrixHelp:"];
    
    if (!matrixView) {
        matrixView = newView;
        [self.view addSubview:matrixView];
    } else {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options: (UIViewAnimationOptionAllowUserInteraction |
                                      UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             [matrixView setAlpha:0];
                         } completion:^(BOOL finished){
                             if (finished) {
                                 [matrixView removeFromSuperview];
                                 matrixView = newView;
                                 [matrixView setAlpha:0];
                                 [self.view addSubview:matrixView];
                                 [UIView animateWithDuration:0.15
                                                       delay:0.0
                                                     options: (UIViewAnimationOptionAllowUserInteraction |
                                                               UIViewAnimationOptionCurveEaseInOut)
                                                  animations:^{
                                                      [matrixView setAlpha:1];
                                                  } completion:^(BOOL finished){
                                                      if (finished) {
                                                          
                                                      }
                                                  }
                                  ];
                             }
                         }
         ];
    }

    //matrixView.backgroundColor = [UIColor blueColor];
}

- (void)makeToolbar {
    if (toolbar) {
        [toolbar removeFromSuperview];
        toolbar = nil;
    }
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, matrixView.frame.origin.y+matrixView.frame.size.height+5, SW(), SH()*.06)];
    //toolbar.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:toolbar];
    
    CGFloat toolSize = toolbar.frame.size.height*.8;
    CGFloat toolBuffer = SW()*.1;

    [self makeSlider];
    
    if (getPrime) {
        [getPrime removeFromSuperview];
        getPrime = nil;
    }
    getPrime = [nnKit makeButtonWithImage:[UIImage imageNamed:@"prime.pdf"] frame:CGRectMake(0, 0, toolSize, toolSize) method:@"handlePrimeForm:" fromClass:self];
    getPrime.center = CGPointMake(self.sizeSlider.frame.origin.x+self.sizeSlider.frame.size.width+toolBuffer+(SW()*.05), toolbar.center.y);
    [self addLPtoView:getPrime withSelector:@"primeHelp:"];
    
    if (setCollection) {
        [setCollection removeFromSuperview];
        setCollection = nil;
    }
    setCollection = [nnKit makeButtonWithImage:[UIImage imageNamed:@"chord.pdf"] frame:CGRectMake(0, 0, toolSize, toolSize) method:@"handleSetCollection:" fromClass:self];
    setCollection.center = CGPointMake(getPrime.frame.origin.x+getPrime.frame.size.width+toolBuffer, toolbar.center.y);
    [self addLPtoView:setCollection withSelector:@"enterHelp:"];
    
    if (helpButton) {
        [helpButton removeFromSuperview];
        helpButton = nil;
    }
    helpButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"question.pdf"] frame:CGRectMake(0, 0, toolSize, toolSize) method:@"handleHelpButton:" fromClass:self];
    helpButton.center = CGPointMake(setCollection.frame.origin.x+setCollection.frame.size.width+toolBuffer, toolbar.center.y);
    [self addLPtoView:helpButton withSelector:@"helpHelp:"];
    
    [self.view addSubview:getPrime];
    [self.view addSubview:setCollection];
    [self.view addSubview:helpButton];
    
    [nnKit animateViewGrowAndShow:self.sizeSlider or:nil completion:nil];
    [nnKit animateViewGrowAndShow:getPrime or:nil completion:nil];
    [nnKit animateViewGrowAndShow:setCollection or:nil completion:nil];
    [nnKit animateViewGrowAndShow:helpButton or:nil completion:nil];
    
//    if (!removeAds) {
//        getPrime.alpha = .3;
//        setCollection.alpha = .3;
//    }
}

- (void)makeSlider {
    CGFloat toolSize = toolbar.frame.size.height*.8;
    CGFloat xOffset = SW()/12.5;
    
    if (self.sizeSlider) {
        [self.sizeSlider removeFromSuperview];
        self.sizeSlider = nil;
    }
    self.sizeSlider = [[NNSlider alloc] initWithFrame:CGRectMake(xOffset, 0, SW()*.4, toolSize)];
    self.sizeSlider.center = CGPointMake(self.sizeSlider.center.x, toolbar.center.y);
    self.sizeSlider.shouldDoCoolAnimation = NO;
    self.sizeSlider.isInt = YES;
    self.sizeSlider.isSegmented = YES;
    self.sizeSlider.segments = 10;
    self.sizeSlider.minValue = 2;
    self.sizeSlider.valueScale = 10;
    self.sizeSlider.value = 12;
    self.sizeSlider.hasPopup = NO;
    self.sizeSlider.lineColor = [UIColor flatBlueColor];
    self.sizeSlider.knobColor = [UIColor flatDarkBlueColor];
    [self.sizeSlider addTarget:self action:@selector(handleSizeSlider:) forControlEvents:UIControlEventValueChanged];
    
    [self addLPtoView:self.sizeSlider withSelector:@"sliderHelp:"];
    [self.view addSubview:self.sizeSlider];
    
    if (scrabbleView) {
        [self.view bringSubviewToFront:scrabbleView];
    }
}

- (void)handleSizeSlider:(NNSlider*)sender {
    if (!initial) {
        initial = YES;
    } else {
        int value = (int)sender.value;
        if (value != lastSliderValue) {
            [self makeScrabbleView:value];
            [self makeMatrixView];
            lastSliderValue = value;
        }
    }
}

- (void)handlePrimeForm:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    
    if (removeAds || tempUnlock) {
        PrimeForm *prime = [[PrimeForm alloc] init];
        NSArray *set = [NSArray arrayWithArray:scrabbleView.collection];
        [prime findPrimeForm:set];
        
        if (!primeView) {
            [nnKit addCloseViewTo:self.view withAlpha:0 withCloseMethod:@"closePrimeForm" fromClass:self];
            
            primeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SW()*.5, SH()*.1)];
            primeView.backgroundColor = [UIColor flatWhiteColor];
            primeView.center = getPrime.center; //CGPointMake(getPrime.center.x, getPrime.frame.origin.y+(getPrime.frame.size.height*1.25)+3);
            
            primeView.layer.masksToBounds = NO;
            primeView.layer.cornerRadius = 8;
            primeView.layer.shadowRadius = 10;
            primeView.layer.shadowOffset = CGSizeMake(3, 3);
            primeView.layer.shadowOpacity = 1;
            primeView.layer.shadowColor = [UIColor blackColor].CGColor;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePrimeForm)];
            [primeView addGestureRecognizer:tap];
            
            UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePrimeForm)];
            [primeView addGestureRecognizer:swipe];
            
            CGFloat textSize = SW()/30;
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, primeView.frame.size.width, SW()/30)];
            titleLabel.font = [UIFont fontWithName:nnKitGlobalFont size:textSize];
            titleLabel.textColor = [UIColor flatGrayColor];
            titleLabel.text = @"Prime Form";
            
            UILabel *primeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, primeView.frame.size.width, primeView.frame.size.height)];
            primeLabel.textAlignment = NSTextAlignmentCenter;
            
            CGFloat countSize = (float)set.count;
            countSize = MIN(countSize, 10);
            countSize = MAX(countSize, 3);
            textSize = SW() / (countSize * 2.75);
            
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for (int i = 0; i < prime.primeForm.count; i++) {
                if ([[prime.primeForm objectAtIndex:i] intValue] == 10) {
                    [temp addObject:@"t"];
                } else if ([[prime.primeForm objectAtIndex:i] intValue] == 11) {
                    [temp addObject:@"e"];
                } else {
                    [temp addObject:[prime.primeForm objectAtIndex:i]];
                }
            }
            
            primeLabel.font = [UIFont fontWithName:nnKitGlobalFont size:textSize];
            NSString *str = [[temp valueForKey:@"description"] componentsJoinedByString:@", "];
            primeLabel.text = [NSString stringWithFormat:@"(%@)",str];
            
            [primeView addSubview:titleLabel];
            [primeView addSubview:primeLabel];
            
            [self.view addSubview:primeView];
            [nnKit animateViewGrowAndShow:primeView or:nil completion:nil];
        } else {
            [self closePrimeForm];
        }
    } else {
        [self primeHelp:nil];
    }
    //NSLog(@"%@",prime.primeForm);
}

- (void)closePrimeForm {
    [nnKit animateViewJiggle:getPrime];
    [nnKit dismissCloseViewFrom:self.view];
    [nnKit animateViewShrinkAndWink:primeView or:nil andRemoveFromSuperview:YES completion:nil];
    primeView = nil;
}

- (void)swipePrimeForm {
    PrimeForm *prime = [[PrimeForm alloc] init];
    NSArray *set = [NSArray arrayWithArray:scrabbleView.collection];
    [prime findPrimeForm:set];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < prime.primeForm.count; i++) {
        NSString *str = [NSString stringWithFormat:@"%@",[prime.primeForm objectAtIndex:i]];
        
        if ([str isEqualToString:@"10"]) {
            str = @"t";
        } else if ([str isEqualToString:@"11"]) {
            str = @"e";
        }
        
        [temp addObject:str];
    }
    
    CGFloat height = SW()/12+2;
    
    if (scrabbleView) {
        [scrabbleView removeFromSuperview];
        scrabbleView = nil;
    }
    
    CGFloat offset = 20;
    if ([nnKit isIPhone4]) {
        offset = 5;
    }
    scrabbleView = [[ScrabbleView alloc] initWithFrame:CGRectMake(0, SH()-VH(kb)-height-offset-iAdHeight, SW(), height) andCharacters:temp];
    [scrabbleView setDelegate:self];
    [scrabbleView setUseLetters:YES];
    [scrabbleView makeTiles];
    [self.view addSubview:scrabbleView];
    
    [self makeMatrixView];
    
    [self closePrimeForm];
}

- (void)handleSetCollection:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    
    if (removeAds || tempUnlock) {
        singleSelect = NO;
        [self openSetCollectionPopupWithText:@"Create a set of any cardinality!"];
    } else {
        [self enterHelp:nil];
    }

}

- (void)openSetCollectionPopupWithText:(NSString*)text {
    
    [nnKit addCloseViewTo:self.view withAlpha:0 withCloseMethod:@"closeSetView" fromClass:self];
    
    CGFloat height;
    CGFloat width;
    if (singleSelect) {
        width = SW()*.5;
        height = SH()*.3;
        if ([nnKit isIPhone4]) {
            height = SH()*.4;
        }
        popup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    } else {
        width = SW()*.9;
        height = SH()*.6;
        if ([nnKit isIPhone4]) {
            height = SH()*.7;
        }
    }
    
    popup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    popup.center = self.view.center;
    popup.backgroundColor = bgColor;
    
    [self addShadowTo:popup.layer];
    
    [self.view addSubview:popup];
    [nnKit animateViewGrowAndShow:popup or:nil completion:nil];
    
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, popup.frame.size.width*.8, popup.frame.size.width*.8)];
    labelView.center = CGPointMake(popup.frame.size.width/2, popup.frame.size.height*.65);
    
    [popup addSubview:labelView];
    
    height = SW()/12+2;
    CGFloat yOriginOffset = .2;
    if (singleSelect) {
        yOriginOffset = .1;
    }
    warning = [[UILabel alloc] initWithFrame:CGRectMake(0, popup.frame.size.height*yOriginOffset, popup.frame.size.width, height)];
    warning.font = [UIFont fontWithName:nnKitGlobalFont size:SW()/20];
    warning.textAlignment = NSTextAlignmentCenter;
    warning.text = text;
    [popup addSubview:warning];
    [nnKit animateViewGrowAndShow:warning or:nil completion:nil];
    
    CGFloat labelSize = labelView.frame.size.width/5;
    if ([nnKit isIPad]) {
        labelSize = labelView.frame.size.width/6;
    }
    CGFloat count = 0;
    for (int i = 1; i < 13; i++) {
        
        int c = i - 1;
        CGFloat x = (labelSize*(c%4))+((labelSize/4)*(c%4))+((labelSize/4)/2);
        CGFloat y = (labelSize*count)+((labelSize/2)*count)+(labelSize/2);
        if ([nnKit isIPad]) {
            x = x+labelSize/2;
            y = y+labelSize/3;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, labelSize, labelSize)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:nnKitGlobalFont size:SW()/12];
        label.tag = c;
        label.userInteractionEnabled = YES;
        
        label.backgroundColor = [UIColor lightGrayColor];
        label.layer.cornerRadius = 8;
        label.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [label addGestureRecognizer:tapLabel];
        
        NSString *str = [NSString stringWithFormat:@"%d",c];
        switch (c) {
            case 10:
                str = @"t";
                break;
            case 11:
                str = @"e";
                break;
                
            default:
                break;
        }
        label.text = str;
        [labelView addSubview:label];
        
        if (i % 4 == 0) {
            count = count + 1;
        }
    }
}

- (void)addShadowTo:(CALayer*)layer {
    layer.masksToBounds = NO;
    layer.cornerRadius = 6;
    layer.shadowRadius = 10;
    layer.shadowOffset = CGSizeMake(3, 3);
    layer.shadowOpacity = 1;
    layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)handleTap:(UITapGestureRecognizer*)sender {
    
    if (!chord) {
        chord = [[NSMutableArray alloc] init];
    }
    
    if (singleSelect) {
        [nnKit animateViewBigJiggle:sender.view];
        //NSLog(@"%@",scrabbleView.collection);
        UILabel *tile = (UILabel*)sender.view;
        NSString *text = tile.text;
        //NSLog(@"%@",text);
        if ([text isEqualToString:@"t"]) {
            text = @"10";
        }
        if ([text isEqualToString:@"e"]) {
            text = @"11";
        }
        
        int replace = -1;
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:scrabbleView.collection];
        for (int i = 0; i < arr.count; i++) {
            if ([arr objectAtIndex:i] == text) {
                replace = i;
            }
        }
        
        if (replace > -1) {
            for (int i = 0; i < arr.count; i++) {
                // NSLog(@"%@ %@",[arr objectAtIndex:replace],text);
                if ([arr objectAtIndex:i] == selectedTile) {
                    [arr replaceObjectAtIndex:i withObject:[arr objectAtIndex:replace]];
                }
            }
            
            [arr replaceObjectAtIndex:replace withObject:selectedTile];
        } else {
            for (int i = 0; i < arr.count; i++) {
                if ([arr objectAtIndex:i] == selectedTile) {
                    [arr replaceObjectAtIndex:i withObject:text];
                }
            }
        }
        chord = arr;
        
        //NSLog(@"%@",arr);
        
        [self closeSetView];
        
    } else {
        [nnKit animateViewJiggle:sender.view];
        
        NSString *pc = [NSString stringWithFormat:@"%d",(int)sender.view.tag];
        if (sender.view.backgroundColor == [UIColor lightGrayColor]) {
            sender.view.backgroundColor = [UIColor flatYellowColor];
            [chord addObject:pc];
        } else {
            sender.view.backgroundColor = [UIColor lightGrayColor];
            NSMutableArray *tempArr = [chord mutableCopy];
            for (NSString *str in chord) {
                if ([str isEqualToString:pc]) {
                    [tempArr removeObject:pc];
                }
            }
            chord = tempArr;
        }
        
        if (chordView) {
            [chordView removeFromSuperview];
            chordView = nil;
        }
        chordView = [[ScrabbleView alloc] initWithFrame:CGRectMake(0, 0, popup.frame.size.width, popup.frame.size.height*.2) andCharacters:chord];
        [chordView setDelegate:self];
        [chordView setUseLetters:YES];
        [chordView makeTiles];
        [popup addSubview:chordView];
        
        if (chord.count < 1) {
            chord = nil;
        }
    }
}

- (void)closeSetView {
    if (singleSelect) {
        if (chord.count > 0) {
            [self resetScrabbleViewWithChord];
            
            [self makeMatrixView];
        } else {
            for (UILabel* tile in scrabbleView.subviews) {
                [nnKit animateSize:tile size:1.];
            }
        }
        
        [self dismissPopup];
        
    } else {
        if (chord) {
            if (chord.count > 1) {
                chord = [NSMutableArray arrayWithArray:chordView.collection];
                
                [self resetScrabbleViewWithChord];
                
                [self makeMatrixView];
                
                [self dismissPopup];
            } else {
                [self.view setUserInteractionEnabled:NO];
                
                [nnKit animateViewShrinkAndWink:warning or:nil andRemoveFromSuperview:NO completion:nil];
                warning.text = [NSString stringWithFormat:@"Please select more than one pitch class!"];
                //[popup addSubview:warning];
                [nnKit animateViewGrowAndShow:warning or:nil completion:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [nnKit animateViewShrinkAndWink:warning or:nil andRemoveFromSuperview:NO completion:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (singleSelect) {
                            warning.text = [NSString stringWithFormat:@"Select a number."];
                        } else {
                            warning.text = [NSString stringWithFormat:@"Tap on the numbers to create a set!"];
                        }
                        
                        [nnKit animateViewGrowAndShow:warning or:nil completion:nil];
                        
                        [self.view setUserInteractionEnabled:YES];
                    });
                });
            }
        } else {
            [self dismissPopup];
        }
    }
    //NSLog(@"%@",scrabbleView.collection);
}

- (void)resetScrabbleViewWithChord {
    CGFloat height = SW()/12+2;
    
    if (scrabbleView) {
        [scrabbleView removeFromSuperview];
        scrabbleView = nil;
    }
    
    CGFloat offset = 20;
    if ([nnKit isIPhone4]) {
        offset = 5;
    }
    scrabbleView = [[ScrabbleView alloc] initWithFrame:CGRectMake(0, SH()-VH(kb)-height-offset-iAdHeight, SW(), height) andCharacters:chord];
    [scrabbleView setDelegate:self];
    [scrabbleView setUseLetters:YES];
    [scrabbleView makeTiles];
    [self.view addSubview:scrabbleView];
    [nnKit animateViewGrowAndShow:scrabbleView or:nil completion:nil];
}

- (void)dismissPopup {
    [nnKit dismissCloseViewFrom:self.view];
    [nnKit animateViewShrinkAndWink:popup or:nil andRemoveFromSuperview:YES completion:nil];
    popup = nil;
    chordView = nil;
    chord = nil;
    if (justOne) {
        justOne = NO;
    }
    if (selectedTile) {
        selectedTile = nil;
    }
    
    [self.sizeSlider setValueTo:scrabbleView.collection.count];
}

- (void)handleHelpButton:(UIButton*)sender {
    [nnKit addCloseViewTo:self.view withAlpha:0 withCloseMethod:@"closeHelpView" fromClass:self];
    helpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SW()*.95, SH()*.95)];
    helpView.backgroundColor = bgColor;
    helpView.center = self.view.center;

    [self addShadowTo:helpView.layer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHelpView)];
    [helpView addGestureRecognizer:tap];
    [self.view addSubview:helpView];
    [nnKit animateViewGrowAndShow:helpView or:nil completion:nil];
    
    CGFloat fontSize = SW()/18;
    if ([nnKit isIPad]) {
        fontSize = SW()/24;
    }
    UIFont *font = [UIFont fontWithName:nnKitGlobalFont size:fontSize];
    UIColor *textColor = [UIColor blackColor];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        matrixView.frame.size.width*.8,
                                                                        matrixView.frame.size.height*.8)];
    
    NSString *title;
    if (!removeAds) {
        title = @"Composers\nhttp://notnatural.co\n\n\nLong press on something to get more specific help. Try the buttons, slider, keyboard, number tiles, and the grid thing!\n\nTap here to dismiss this message or tap below to find out about...";
    } else {
        title = @"Composers\nhttp://notnatural.co\n\n\nLong press on something to get more specific help. Try the buttons, slider, keyboard, number tiles, and the grid thing!\n\nTap anywhere to dismiss this message...";
    }
    [textView setCenter:CGPointMake(VW(helpView)/2, VH(helpView)/3)];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setTextColor:textColor];
    [textView setFont:font];
    [textView setText:title];
    textView.userInteractionEnabled = NO;
    
//    CGFloat size = SW()/1.5;
//    if (removeAds) {
//        title = @"You're Pro!";
//    } else {
//        title = @"PRO EDITION";
//    }
    
//    UIButton *inAppPurchase = [nnKit makeButtonWithFrame:CGRectMake(0, SH()-size, size, size/3) fontSize:SW()/10 title:title method:@"tapRemoveAds:" fromClass:self];
//    CGFloat offset = 0;
//    if ([nnKit isIPad]) {
//        offset = 50;
//    }
//    inAppPurchase.center = CGPointMake(VW(helpView)/2,inAppPurchase.center.y+offset);
//    inAppPurchase.backgroundColor = bgColor;
//
//    offset = 1.6;
//    if ([nnKit isIPad]) {
//        offset = 1.8;
//    }
//
//    UIButton *restorePurchases = [nnKit makeButtonWithFrame:CGRectMake(0, SH()-size/offset, size, size/3) fontSize:SW()/14 title:@"Restore Pro Edition!" method:@"tapRestorePurchases:" fromClass:self];
//    restorePurchases.center = CGPointMake(VW(helpView)/2,restorePurchases.center.y);
//    restorePurchases.backgroundColor = bgColor;
    
//    if ([nnKit isIPhone4]) {
//        inAppPurchase.center = CGPointMake(matrixView.center.x, matrixView.center.y+(matrixView.frame.size.height*.4));
//    } else {
//        inAppPurchase.center = CGPointMake(matrixView.center.x, matrixView.center.y+(matrixView.frame.size.height*.35));
//    }
    
    [helpView addSubview:textView];
//    [helpView addSubview:inAppPurchase];
//    [helpView addSubview:restorePurchases];
}

- (void)closeHelpView {
    [nnKit dismissCloseViewFrom:self.view];
    [nnKit animateViewShrinkAndWink:helpView or:nil andRemoveFromSuperview:YES completion:nil];
    helpView = nil;
}

//# pragma Remove Ads
///* http://stackoverflow.com/questions/19556336/how-do-you-add-an-in-app-purchase-to-an-ios-application */

//- (void)tapRestorePurchases:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//    [self closeHelpView];
//    [self restore];
//}
//
//- (void)tapRemoveAds:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//    [self closeHelpView];
//    if (removeAds) {
//        NSString *text = [NSString stringWithFormat:@"\n\nYou're Already Pro!\n\n\n\n( ˘ ³˘)❤"];
//        if (!helpPopupVisible) {
//            [self showHelpPopupWithText:text withLP:nil andLink:1000];
//        }
//    } else {
//        [self showRemoveAdPopup];
//    }
//}

//- (void)showRemoveAdPopup {
//    helpPopupVisible = YES;
//
//    [nnKit addCloseViewTo:self.view withAlpha:0 withCloseMethod:@"closeHelpPopup" fromClass:self];
//    helpPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, matrixView.frame.size.width*.9, matrixView.frame.size.height*.9)];
//    helpPopup.backgroundColor = [UIColor colorWithRed:242/255. green:240/255. blue:241/255. alpha:1];
//    helpPopup.center = matrixView.center;
//
//    [self addShadowTo:helpPopup.layer];
//
//    CGFloat fontSize = SW()/24;
//    if ([nnKit isIPad]) {
//        fontSize = SW()/36;
//    }
//    if ([nnKit isIPhone4]) {
//        fontSize = SW()/30;
//    }
//    UIFont *font = [UIFont fontWithName:nnKitGlobalFont size:fontSize];
//    UIColor *textColor = [UIColor blackColor];
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
//                                                                        0,
//                                                                        matrixView.frame.size.width*.8,
//                                                                        matrixView.frame.size.height*.8)];
//
//    NSString *text = [NSString stringWithFormat:@"UNLOCK PRO EDITION for $0.99(USD)\n\n`(˚Õ˚)ر\n\n• Calculate Prime Form\n• Quickly Input A Set With Something That Looks Like A Calculator\n• REMOVE ADS\n• REMOVE ANNOYING SPLASH INTRO"];
//    [textView setCenter:CGPointMake(VW(helpPopup)/2,VH(helpPopup)/2)];
//    [textView setBackgroundColor:[UIColor clearColor]];
//    [textView setTextAlignment:NSTextAlignmentCenter];
//    [textView setTextColor:textColor];
//    [textView setFont:font];
//    [textView setText:text];
//    textView.userInteractionEnabled = NO;
//
//    UIButton *ok = [nnKit makeButtonWithCenter:CGPointMake(textView.center.x, VH(helpPopup)-(VH(helpPopup)/3.5)) fontSize:fontSize*2 title:@"Yes, Please." method:@"tapOk:" fromClass:self];
//    UIButton *no = [nnKit makeButtonWithCenter:CGPointMake(textView.center.x, VH(helpPopup)-(VH(helpPopup)/8)) fontSize:fontSize*1.25 title:@"No, Thanks." method:@"tapNo:" fromClass:self];
//
//    [helpPopup addSubview:ok];
//    [helpPopup addSubview:no];
//    [helpPopup addSubview:textView];
//    [self.view addSubview:helpPopup];
//    [nnKit animateViewGrowAndShow:helpPopup or:nil completion:nil];
//}

//- (void)tapOk:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//
//    [nnKit addCloseViewTo:self.view withAlpha:1 withCloseMethod:@"cancelPurchase" fromClass:self];
//    [self makeSpinner];
//    [self startSpinner];
//    [self removeAds];
//}
//- (void)tapNo:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//    [self closeHelpPopup];
//}
//- (void)cancelPurchase {
//    [self stopSpinner];
//    [nnKit dismissCloseViewFrom:self.view];
//    [self closeHelpPopup];
//}
//
//- (void)handleRemovingCurrentAds {
//    bannerIsVisible = NO;
//    [bannerView removeFromSuperview];
//    bannerView = nil;
//    if (spinner) {
//        [self cancelPurchase];
//    }
//}

//- (void)removeAds {
//    NSLog(@"User requests to remove ads");
//
//    if([SKPaymentQueue canMakePayments]){
//        NSLog(@"User can make payments");
//
//        //If you have more than one in-app purchase, and would like
//        //to have the user purchase a different product, simply define
//        //another function and replace kRemoveAdsProductIdentifier with
//        //the identifier for the other product
//
//        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
//        productsRequest.delegate = self;
//        [productsRequest start];
//
//    }
//    else{
//        NSLog(@"User cannot make payments due to parental controls");
//        //this is called the user cannot make payments, most likely due to parental controls
//        [self cancelPurchase];
//    }
//}

//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    SKProduct *validProduct = nil;
//    int count = (int)[response.products count];
//    if(count > 0){
//        validProduct = [response.products objectAtIndex:0];
//        NSLog(@"Products Available!");
//        [self purchase:validProduct];
//    }
//    else if(!validProduct){
//        NSLog(@"No products available");
//        [self cancelPurchase];
//        //this is called if your product id is not valid, this shouldn't be called unless that happens.
//    }
//}
//
//- (void)purchase:(SKProduct *)product{
//    SKPayment *payment = [SKPayment paymentWithProduct:product];
//
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}
//
//- (void)restore {
//    //this is called when the user restores purchases, you should hook this up to a button
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//}
//
//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
//{
//    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
//    for(SKPaymentTransaction *transaction in queue.transactions){
//        if(transaction.transactionState == SKPaymentTransactionStateRestored){
//            //called when the user successfully restores a purchase
//            NSLog(@"Transaction state -> Restored");
//
//            //if you have more than one in-app purchase product,
//            //you restore the correct product for the identifier.
//            //For example, you could use
//            //if(productID == kRemoveAdsProductIdentifier)
//            //to get the product identifier for the
//            //restored purchases, you can use
//            //
//            //NSString *productID = transaction.payment.productIdentifier;
//            [self doRemoveAds];
//            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            break;
//        }
//    }
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
//    for(SKPaymentTransaction *transaction in transactions){
//        switch(transaction.transactionState){
//            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
//                //called when the user is in the process of purchasing, do not add any of your own code here.
//                break;
//            case SKPaymentTransactionStatePurchased:
//                //this is called when the user has successfully purchased the package (Cha-Ching!)
//                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                NSLog(@"Transaction state -> Purchased");
//                break;
//            case SKPaymentTransactionStateRestored:
//                NSLog(@"Transaction state -> Restored");
//                [self doRemoveAds];
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//            case SKPaymentTransactionStateFailed:
//                NSLog(@"Transaction state -> Cancelled");
//                [self cancelPurchase];
//                //called when the transaction does not finish
//                if(transaction.error.code == SKErrorPaymentCancelled){
//
//                    //the user cancelled the payment ;(
//                }
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//            case SKPaymentTransactionStateDeferred:
//                NSLog(@"Transaction state -> Deferred");
//                [self doRemoveAds];
//                //add the same code as you did from SKPaymentTransactionStatePurchased here
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//        }
//    }
//}
//
//- (void)doRemoveAds {
//    removeAds = YES;
//    [[NSUserDefaults standardUserDefaults] setBool:removeAds forKey:@"removeAds"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    [self handleRemovingCurrentAds];
//    [self loadEverything];
//}

#pragma spinner
- (void)makeSpinner {
    if (spinner) {
        [spinner removeFromSuperview];
        spinner = nil;
    }
    int num = RAND(12);
    colorTheme = [nnKit colorTheme:num];
    
    spinner = [[MONActivityIndicatorView alloc] init];
    spinner.alpha = 0;
    spinner.delegate = self;
    spinner.numberOfCircles = 5;
    spinner.radius = SW()/16;
    spinner.internalSpacing = 3;
    
    [self.view addSubview:spinner];
}

- (void)startSpinner {
    [self makeSpinner];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kFadeTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [spinner setCenter:self.view.center];
    });

    [spinner startAnimating];
    
    [UIView animateWithDuration:kFadeTime*3
                          delay:kFadeTime
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [spinner setAlpha:1];
     } completion:nil];
}

- (void)stopSpinner {
    [UIView animateWithDuration:kFadeTime/2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         spinner.alpha = 0;
     } completion:^(BOOL finished){
         if (finished) {
             [spinner stopAnimating];
             [spinner removeFromSuperview];
             colorTheme = nil;
             spinner = nil;
         }
     }];
}

#pragma mark - MONActivityIndicatorView delegate

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    UIColor *color = [colorTheme objectAtIndex:index%5];
    
    return color;
}

#pragma help views
- (void)matrixHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text = [NSString stringWithFormat:@"The Matrix\n\nThis matrix helps visualize various permutations of a pitch class set. This matrix automagically updates as you change the current pitch class set.\n\n• Tap on a number to highlight all similar numbers. Tap again to unhighlight. Swipe to clear all highlights.\n\n• Pitch classes '10' and '11' are represented with 't' and 'e'\n\n༼ つ ◕_◕ ༽つ   c[_]"];
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:1];
    }
}
- (void)tileHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text = [NSString stringWithFormat:@"The Set\n\nThis is the pitch class set you're currently analyzing.\n\n• Drag a tile to reorder the set.\n\n• Tap on a tile to pick a new number.\n\n• If you pick a number already in the set, the tiles will switch places.\n\n\nＯ(≧▽≦)Ｏ "];
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:2];
    }
}
- (void)pianoHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text = [NSString stringWithFormat:@"The Keyboard\n\nThis is a keyboard.\n\n• Drag the keyboard to change the register.\n\n♫♪.ılılıll|̲̅̅●̲̅̅|̲̅̅=̲̅̅|̲̅̅●̲̅̅|llılılı.♫♪"];
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:3];
    }
}
- (void)helpHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text = [NSString stringWithFormat:@"The Info Button\n\nTap this button to get some general info.\nThis is also where you can access\n\nPRO MODE\n▂▃▅▇█▓^^^^^^^^▓█▇▅▃▂\n\nᕙ(⇀‸↼‶)ᕗ\n\n(╯°□°）╯︵ ┻━┻\n\n...\n\n ┬──┬ ノ( ゜-゜ノ) "];
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:4];
    }
}
- (void)enterHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text;
    if (removeAds) {
        text = [NSString stringWithFormat:@"Create-A-Set\n\nOpen this popup and type in a pitch class set.\n\n• It must have two or more members.\n\n• You can drag and reorder the tiles as they are added!\n\n\n-`ღ´- "];
    } else {
        text = [NSString stringWithFormat:@"Create-A-Set\n\nOpen this popup and type in a pitch class set.\n\n• Must have two or more members.\n\n• You can drag and reorder the tiles as they are added!\n\nUnlock with PRO MODE!\n\n\n-`ღ´- "];
    }
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:5];
    }
}
- (void)primeHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text;
    if (removeAds) {
        text = [NSString stringWithFormat:@"Prime Form\n\nThis popup will show you the prime form for whatever set you are working with.\n\n• Swipe on the popup to change the current pitch class set to the prime form!\n\n• Hexachordal ties are resolved a la Forte's method.\n\n(☞ﾟ∀ﾟ)☞"];
    } else {
        text = [NSString stringWithFormat:@"Prime Form\n\nThis popup will show you the prime form for whatever set you are working with.\n\n• Swipe on the popup to change the current pitch class set to the prime form!\n\n• Hexachordal ties are resolved a la Forte's method.\n\nUnlock with PRO MODE!\n\n(☞ﾟ∀ﾟ)☞"];
    }
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:6];
    }
}
- (void)sliderHelp:(UILongPressGestureRecognizer*)sender {
    NSString *text = [NSString stringWithFormat:@"The Cardinality Slider\n\nThis thing changes the size of the current pitch class set.\n\nThat's it.\n\n\n【ツ】"];
    if (!helpPopupVisible) {
        [self showHelpPopupWithText:text withLP:sender andLink:7];
    }
}

- (void)showHelpPopupWithText:(NSString*)text withLP:(UILongPressGestureRecognizer*)sender andLink:(int)tag {
    helpPopupVisible = YES;
    [nnKit animateViewJiggle:sender.view];
    
    [nnKit addCloseViewTo:self.view withAlpha:0 withCloseMethod:@"closeHelpPopup" fromClass:self];
    helpPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, matrixView.frame.size.width*.9, matrixView.frame.size.height*.9)];
    helpPopup.backgroundColor = [UIColor colorWithRed:242/255. green:240/255. blue:241/255. alpha:1];
    helpPopup.center = matrixView.center;

    [self addShadowTo:helpPopup.layer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHelpPopup)];
    [helpPopup addGestureRecognizer:tap];
    
    CGFloat fontSize = SW()/24;
    if ([nnKit isIPad]) {
        fontSize = SW()/36;
    }
    if ([nnKit isIPhone4]) {
        fontSize = SW()/30;
    }
    UIFont *font = [UIFont fontWithName:nnKitGlobalFont size:fontSize];
    UIColor *textColor = [UIColor blackColor];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        matrixView.frame.size.width*.8,
                                                                        matrixView.frame.size.height*.8)];
    
    [textView setCenter:CGPointMake(VW(helpPopup)/2,VH(helpPopup)/2)];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setTextColor:textColor];
    [textView setFont:font];
    [textView setText:text];
    textView.userInteractionEnabled = NO;
    
    if (!justOne) {
        UIButton *link = [nnKit makeButtonWithOrigin:CGPointMake(8, 3) fontSize:fontSize title:@"More Info" method:@"openLink:" fromClass:self];
        link.tag = tag;
        [helpPopup addSubview:link];
    } else {
        justOne = NO;
    }

    [helpPopup addSubview:textView];
    [self.view addSubview:helpPopup];
    [nnKit animateViewGrowAndShow:helpPopup or:nil completion:nil];
}

- (void)closeHelpPopup {
    [nnKit dismissCloseViewFrom:self.view];
    [nnKit animateViewShrinkAndWink:helpPopup or:nil andRemoveFromSuperview:YES completion:nil];
    helpPopup = nil;
    helpPopupVisible = NO;
    
    if (helpButton.layer.animationKeys.count > 0) {
        [helpButton.layer removeAllAnimations];
    }
    
    if (spinner) {
        [self stopSpinner];
    }
}

- (void)openLink:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    NSString *link = @"";
    switch ((int)sender.tag) {
        case 1:
            link = @"http://tinyurl.com/zmuluaa";
            break;
        case 2:
            link = @"http://tinyurl.com/j8vedtr";
            break;
        case 3:
            link = @"http://tinyurl.com/o4gfcmc";
            break;
        case 4:
            link = @"http://tinyurl.com/h3ewfdf";
            break;
        case 5:
            link = @"http://tinyurl.com/zegjcl9";
            break;
        case 6:
            link = @"http://tinyurl.com/hllbeoy";
            break;
        case 7:
            link = @"http://tinyurl.com/8n7rn2v";
            break;
        case 1000:
            link = @"http://tinyurl.com/zvboewb";
            break;
        default:
            break;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
}

#pragma keyboard delegate

- (void)keyboardTouchUpEvent:(NNKeyboard*)keyboard {
    
}

- (void)keyboardTouchDownEvent:(NNKeyboard*)keyboard {
    CGFloat sysVol = [[AVAudioSession sharedInstance] outputVolume];
    if (sysVol < .24) {
        [self showVolumeAlert];
    }
}

- (void)showVolumeAlert {
    if (!oneAlert) {
        oneAlert = YES;
        
        UILabel *alert = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SW()*.8, SH()*.15)];
        alert.text = @"Warning: Device volume is low!";
        alert.backgroundColor = bgColor;
        [self addShadowTo:alert.layer];
        alert.font = [UIFont fontWithName:nnKitGlobalFont size:SW()/20];
        alert.textAlignment = NSTextAlignmentCenter;
        alert.center = self.view.center;
        
        [self.view addSubview:alert];
        [nnKit animateViewGrowAndShow:alert or:nil completion:nil];
        
        [UIView animateWithDuration:5.
                              delay:1.
                            options: (UIViewAnimationOptionAllowUserInteraction |
                                      UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             alert.alpha = 0;
                         } completion:^(BOOL finished){
                             if (finished) {
                                 [alert removeFromSuperview];
                             }
                         }
         ];
    }
}

#pragma Ads

//- (void)addAds {
//    if (nn) {
//        [nn removeFromSuperview];
//        nn = nil;
//    }
//    nn = [[UILabel alloc] initWithFrame:CGRectMake(0, SH()-iAdHeight, SW(), iAdHeight)];  // 50 for portrait, 32 for landscape
//    nn.textAlignment = NSTextAlignmentCenter;                                        // 66 for iPad portrait or landscape
//    nn.font = [UIFont fontWithName:nnKitGlobalFont size:SW()/20];
//    nn.text = [NSString stringWithFormat:@"notnatural.co"];
//
//    [self.view addSubview:nn];
//
//    if (bannerView) {
//        [bannerView removeFromSuperview];
//        bannerView = nil;
//    }
//    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
//    bannerView.frame = CGRectMake(0, SH(), bannerView.frame.size.width, bannerView.frame.size.height);
//    bannerView.adUnitID = @"ca-app-pub-8086035338872648/6115546019";
//    bannerView.rootViewController = self;
//    bannerView.delegate = self;
//
//    bannerIsVisible = NO;
//
//    GADRequest *request = [self getGADRequest];
//
//    [self.view addSubview:bannerView];
//    [bannerView loadRequest:request];
//}


//- (void)createAndLoadInterstitial {
//    //Ad unit name: TempUnlock
//    //App ID: ca-app-pub-8086035338872648~4638812818
//    //Ad unit ID: ca-app-pub-8086035338872648/1766056011
//    
//    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-8086035338872648/1766056011"];
//    self.interstitial.delegate = self;
//    
//    GADRequest *request = [self getGADRequest];
//
//    [self.interstitial loadRequest:request];
//}
/// Called before the interstitial is to be animated off the screen.
//- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
//    [self tempUnlock];
//}

- (void)tempUnlock {
    [nnKit animateViewShrinkAndWink:proButton or:nil andRemoveFromSuperview:YES completion:nil];
    tempUnlock = YES;
    getPrime.alpha = 1;
    setCollection.alpha = 1;
}

// Rewarded Interstitial

//- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
//   didRewardUserWithReward:(GADAdReward *)reward {
//    [self tempUnlock];
//
//    NSString *rewardMessage =
//    [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
//     reward.type,
//     [reward.amount doubleValue]];
//    NSLog(rewardMessage);
//}
//
//- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    NSLog(@"Reward based video ad is received.");
//}
//
//- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    NSLog(@"Opened reward based video ad.");
//}
//
//- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    NSLog(@"Reward based video ad started playing.");
//}
//
//- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    NSLog(@"Reward based video ad is closed.");
//    if (!tempUnlock) {
//        [self loadRewardedAd];
//    }
//}
//
//- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    NSLog(@"Reward based video ad will leave application.");
//}
//
//- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
//    didFailToLoadWithError:(NSError *)error {
//    NSLog(@"Reward based video ad failed to load.");
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (!tempUnlock) {
//            [self loadRewardedAd];
//        }
//    });
//}
//
//- (void)loadRewardedAd {
//    [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
//                                           withAdUnitID:@"ca-app-pub-8086035338872648/6282896810"];
//}



// Banner Ads
//
//- (GADRequest*)getGADRequest {
//    GADRequest *request = [GADRequest request];
//    if (testAds) {
//        request.testDevices = @[@"bec0bbadab101b4ce67c4c885d45d9de"];
//    }
//    return request;
//}
//
//- (void)adViewDidReceiveAd:(GADBannerView *)banner {
//    if (!bannerIsVisible)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//            banner.frame = CGRectOffset(bannerView.frame, 0, -iAdHeight);
//            [UIView commitAnimations];
//            bannerIsVisible = YES;
//        });
//    }
//}
//
//- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
//    NSLog(@"adView:didFailToReceiveAdWithError: %@", error.localizedDescription);
//    if (bannerIsVisible)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//            bannerView.frame = CGRectOffset(bannerView.frame, 0, iAdHeight);
//            [UIView commitAnimations];
//            bannerIsVisible = NO;
//        });
//    }
//}

@end
