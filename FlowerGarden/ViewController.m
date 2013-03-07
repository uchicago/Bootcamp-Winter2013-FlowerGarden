//
//  ViewController.m
//  FlowerGarden
//
//  Created by T. Andrew Binkowski on 3/7/13.
//  Copyright (c) 2013 T. Andrew Binkowski. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

// Class Extension (Private) ///////////////////////////////////////////////////
@interface ViewController ()
@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;
- (void)animateSun;
- (void)playSoundEffect:(NSString*)soundName; 
@end

// Class ///////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

/*******************************************************************************
 * @method          viewDidAppear
 * @abstract
 * @description
 *******************************************************************************/
- (void)viewDidAppear:(BOOL)animated
{
    [self animateSun];
    [self playBackgroundMusic];
}


/*******************************************************************************
 * @method          didReceiveMemoryWarning
 * @abstract
 * @description     
 *******************************************************************************/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Gesture Handling

/*******************************************************************************
 * @method          tapToAddFlower:
 * @abstract        Action for single tap gesture recognizer
 * @description     Add an UIImage to the parentview 
 *******************************************************************************/
- (IBAction)tapToAddFlower:(UITapGestureRecognizer *)sender
{
    NSLog(@">>>>> tapToAddFlower: %@", sender);

    // Get the view that was tapped
    UIView *field = sender.view;

    // Get the location of the tap on the field view
    CGPoint touchPoint = [sender locationInView:[field superview]];
    NSLog(@"\t\t Field was tapped at location: x:%5.2f y:%5.2f",touchPoint.x,touchPoint.y);
    
    // Create an image to add to the field view
    UIImage *flower = [UIImage imageNamed:@"red"];
    
    // Add an image view with flower as image
    UIImageView *flowerImageView = [[UIImageView alloc] initWithImage:flower];
    
    // Place it at the touch point
    flowerImageView.center = touchPoint;
    
    // Add our image view to the field view
    [field addSubview:flowerImageView];
    
    // Create a "drag" pan gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    
    // Enable view to receive touches and add the gesture
    flowerImageView.userInteractionEnabled = YES;
    [flowerImageView addGestureRecognizer:panGesture];
    
    // Play sound when adding  
    [self playSoundEffect:@"Tink"];

}


/*******************************************************************************
 * @method      panPiece:
 * @abstract    <# abstract #>
 * @description shift the piece's center by the pan amount
 *              reset the gesture recognizer's translation to {0, 0} after applying so the next
 *              callback is a delta from the current position
 *******************************************************************************/
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    [[piece superview] bringSubviewToFront:piece];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

#pragma mark - Shake Event Detection
/*******************************************************************************
 * @method      canBecomeFirstResponder
 * @abstract    To receive motion events, the responder object that is to handle them must be the first responder.
 * @description
 *******************************************************************************/
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/*******************************************************************************
 * @method          motionEnded:withEvent
 * @abstract
 * @description
 ******************************************************************************/
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    // Test what kind of UIEventt type is recognized
    if (motion == UIEventTypeMotion && event.type == UIEventSubtypeMotionShake) {
        NSLog(@">>>>> Shake detected: %@", [NSDate date]);
        
        // Get the field view by using its tag (alternative to setting a property for the view)
        UIView *field = [self.view viewWithTag:100];

        // Get all subviews into an array
        NSArray *flowersOnTheField = [field subviews];

        // Iterate through array and remove each flower
        for (UIView *subview in flowersOnTheField) {
            [subview removeFromSuperview];
        }

        // Play a sound effect
        [self playSoundEffect:@"Cartoon Boing"];
    }
}

#pragma mark - Animation Effects
/*******************************************************************************
 * @method          animateSun
 * @abstract        Animate the star offscreen to the top of the tree
 * @description     Add to the tree image view
 ******************************************************************************/
- (void)animateSun
{
    // Find the field view
    UIView *field = [self.view viewWithTag:100];

    // Create offscreen image view
    CGRect offscreen = CGRectMake(500, 500, 100, 100);
    UIImageView *sun = [[UIImageView alloc] initWithFrame:offscreen];
    sun.image = [UIImage imageNamed:@"sun"];
    [field addSubview:sun];
    
    // Call animation to move onscreen after 2s delay
    [UIView animateWithDuration:2.0 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         sun.center = CGPointMake(50, 50);
                     }
                     completion:^(BOOL  completed) {
                         NSLog(@">>>> Sun has risen");
                     }
     ];
}

#pragma mark - Sound Effect
/*******************************************************************************
 * @method          playSoundEffect
 * @abstract        Play a short sound when a flower is added
 * @description     
 ******************************************************************************/
- (void)playSoundEffect:(NSString*)soundName
{
    NSLog(@">>> Play sound named: %@",soundName);
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"caf"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

/*******************************************************************************
 * @method      playBackgroundMusic
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)playBackgroundMusic
{
    NSError *error;
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"She loves you" ofType:@"mp3"];
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    
    _backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    [self.backgroundMusic prepareToPlay];
    [self.backgroundMusic play];
}
@end
