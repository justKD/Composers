//
//  ViewController.m
//
//  Created by Cady Holmes on 10/2/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "ViewController.h"
#import "MatrixViewController.h"
#import "NNSplashScreenView.h"
#import "SoundBankPlayer.h"

@interface ViewController () 
{
    NNSplashScreenView *ss;
    BOOL removeAds;
    
    // SoundBankPlayer properties
    SoundBankPlayer *soundBankPlayer;
    NSTimer *timer;
    BOOL playingArpeggio;
    NSArray *arpeggioNotes;
    NSUInteger arpeggioIndex;
    CFTimeInterval arpeggioStartTime;
    CFTimeInterval arpeggioDelay;
}

@end

@implementation ViewController

static CGFloat const kGain = .25;

- (void)wait:(double)delayInSeconds then:(void(^)(void))callback {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        if(callback){
            callback();
        }
    });
}

-(BOOL)shouldAutorotate {
    return NO;
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
//    {
//        NSLog(@"Change to custom UI for landscape");
//        ss.layer.position = self.view.center;
//    }
//    else if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
//             toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//    {
//        NSLog(@"Change to custom UI for portrait");
//        ss.layer.position = self.view.center;
//        
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:242/255. green:240/255. blue:241/255. alpha:1]];
    
//    removeAds = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeAds"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    removeAds = YES;
//
//    soundBankPlayer = [[SoundBankPlayer alloc] init];
//    [soundBankPlayer setSoundBank:@"Piano"];
}
- (void)viewDidAppear:(BOOL)animated {

    if (!removeAds) {
//        [self wait:.05f then:^{
//            [self loadSplashScreen];
//            [self wait:.05f then:^{
//                [self playAMinorChord];
//                [self wait:.15f then:^{
//                    [self arpeggiateCoolChord];
//                }];
//            }];
//        }];
    } else {
        MatrixViewController *vc = [[MatrixViewController alloc] init];
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:vc animated:YES completion:nil];
    }

    // temp for testing
//    MatrixViewController *vc = [[MatrixViewController alloc] init];
//    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:vc animated:YES completion:nil];
}

//- (void)loadIntroUI
//{
//    //temporary
//    UIImageView *shosView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shostakovich.pdf"]];
//    shosView.frame = self.view.frame;
//    shosView.contentMode = UIViewContentModeScaleAspectFit;
//    shosView.userInteractionEnabled = YES;
//
//    UITapGestureRecognizer *tapShos = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMatrixVC:)];
//    [shosView addGestureRecognizer:tapShos];
//
//    [self.view addSubview:shosView];
//    [shosView.layer addAnimation:showAnimation() forKey:nil];
//}
//
//- (void)loadMatrixVC:(UITapGestureRecognizer*)sender {
//    [self animateViewJiggle:sender.view];
//    MatrixViewController *vc = [[MatrixViewController alloc] init];
//    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:vc animated:YES completion:nil];
//}

//static CAAnimation* showAnimation()
//{
//    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
//    NSMutableArray *values = [NSMutableArray array];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
//    transform.values = values;
//
//    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    [opacity setFromValue:@0.0];
//    [opacity setToValue:@1.0];
//
//    CAAnimationGroup *group = [CAAnimationGroup animation];
//    group.duration = 0.3;
//    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    [group setAnimations:@[transform, opacity]];
//    return group;
//}

//- (void)animateViewJiggle:(UIView*)view {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.15f
//                              delay:0.0f
//             usingSpringWithDamping:.2f
//              initialSpringVelocity:10.f
//                            options:(UIViewAnimationOptionAllowUserInteraction |
//                                     UIViewAnimationOptionCurveEaseOut)
//                         animations:^{
//                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
//                         }
//                         completion:^(BOOL finished) {
//                             [UIView animateWithDuration:0.3f
//                                                   delay:0.0f
//                                  usingSpringWithDamping:.3f
//                                   initialSpringVelocity:10.0f
//                                                 options:(UIViewAnimationOptionAllowUserInteraction |
//                                                          UIViewAnimationOptionCurveEaseOut)
//                                              animations:^{
//                                                  view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
//                                              }
//                                              completion:^(BOOL finished) {
//                                              }];
//                         }];
//    });
//}

#pragma mark - SoundBankPlayer Example Methods
//- (void)playAMinorChord
//{
//    [soundBankPlayer queueNote:33 gain:kGain];
//    [soundBankPlayer queueNote:45 gain:kGain];
//    [soundBankPlayer queueNote:52 gain:kGain];
//    [soundBankPlayer queueNote:57 gain:kGain];
//    [soundBankPlayer queueNote:60 gain:kGain];
//    [soundBankPlayer playQueuedNotes];
//}

//- (void)arpeggiateCoolChord
//{
//    [self playArpeggioWithNotes:@[@48,@50,@53,@55,@59,@63,@65,@67,@71,@74,@76,@79,@82,@84] delay:0.03f timeInterval:.01f];
//}

//- (void)playArpeggioWithNotes:(NSArray *)notes delay:(CFTimeInterval)delay timeInterval:(NSTimeInterval)timeInterval
//{
//    if (!timer) {
//        [self startTimerWithInterval:timeInterval];
//    }
//
//    if (!playingArpeggio)
//    {
//        playingArpeggio = YES;
//        arpeggioNotes = [notes copy];
//        arpeggioIndex = 0;
//        arpeggioDelay = delay;
//        arpeggioStartTime = CACurrentMediaTime();
//    }
//}

//- (void)startTimerWithInterval:(NSTimeInterval)timeInterval
//{
//    timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval  // 50 ms
//                                              target:self
//                                            selector:@selector(handleTimer:)
//                                            userInfo:nil
//                                             repeats:YES];
//}
//
//- (void)stopTimer
//{
//    if (timer != nil && [timer isValid])
//    {
//        [timer invalidate];
//        timer = nil;
//    }
//}

//- (void)handleTimer:(NSTimer *)timer
//{
//    if (playingArpeggio)
//    {
//        // Play each note of the arpeggio after "arpeggioDelay" seconds.
//        CFTimeInterval now = CACurrentMediaTime();
//        if (now - arpeggioStartTime >= arpeggioDelay)
//        {
//            NSNumber *number = arpeggioNotes[arpeggioIndex];
//            [soundBankPlayer noteOn:[number intValue] gain:kGain];
//
//            arpeggioIndex += 1;
//            if (arpeggioIndex == [arpeggioNotes count])
//            {
//                playingArpeggio = NO;
//                arpeggioNotes = nil;
//                [self stopTimer];
//            }
//            else  // schedule next note
//            {
//                arpeggioStartTime = now;
//            }
//        }
//    }
//}

#pragma mark - Splash Screen
//- (void)loadSplashScreen {
//    [self.view setUserInteractionEnabled:NO];
//
//    ss = [[NNSplashScreenView alloc] initWithFrame:self.view.frame];
//    ss.delegate = self;
//    [ss setTitleFont:CTFontCreateWithName(CFSTR("Zapfino"), self.view.frame.size.width/8, NULL)];
//    [ss loadSplashScreenWithTitle:@"Composers"];
//    [self.view addSubview:ss];
//}
//
//- (void)splashDidFinish:(NNSplashScreenView *)view {
//    [self.view setUserInteractionEnabled:YES];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //[self loadIntroUI];
//
//        MatrixViewController *vc = [[MatrixViewController alloc] init];
//        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:vc animated:YES completion:nil];
//    });
//}
//
//- (void)titleDidFinish:(NNSplashScreenView *)view {
//}

//- (void)subTitleDidFinish:(NNSplashScreenView *)view {
//    [soundBankPlayer queueNote:36 gain:kGain];
//    [soundBankPlayer queueNote:43 gain:kGain];
//    [soundBankPlayer queueNote:48 gain:kGain];
//    [soundBankPlayer queueNote:52 gain:kGain];
//    [soundBankPlayer queueNote:60 gain:kGain];
//    [soundBankPlayer playQueuedNotes];
//}

@end
