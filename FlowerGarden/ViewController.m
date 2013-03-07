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

- (void)addGestureRecognizersToFlower:(UIView *)piece;
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer;
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
    flowerImageView.userInteractionEnabled = YES;
    [field addSubview:flowerImageView];
    
    [self addGestureRecognizersToFlower:flowerImageView];
    
    // Play sound when adding  
    [self playSoundEffect:@"Tink"];

}

/*******************************************************************************
 * @method          addGestureToFlower: 
 * @abstract        Add gestures to the added flower to detect rotation, translation, and scaling
 * @description
 ******************************************************************************/
- (void)addGestureRecognizersToFlower:(UIView *)piece
{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [piece addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [piece addGestureRecognizer:pinchGesture]; 
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
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

/*******************************************************************************
 * @method      rotatePiece:
 * @abstract    <# abstract #>
 * @description rotate the piece by the current rotation
 *              reset the gesture recognizer's rotation to 0 after applying so
 *              the next callback is a delta from the current rotation
 *******************************************************************************/
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

/*******************************************************************************
 * @method      scalePiece
 * @abstract
 * @description Scale the piece by the current scale; reset the gesture recognizer's
 *              rotation to 0 after applying so the next callback is a delta from the current scale
 *******************************************************************************/
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
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

#pragma mark - Buttons

/*******************************************************************************
 * @method          tapInfoButton
 * @abstract        Show an alert dialogue on tap
 * @description
 ******************************************************************************/
- (IBAction)tapInfoButton:(UIButton *)sender
{
    UIActionSheet *msg = [[UIActionSheet alloc]
                          initWithTitle:
                          @"1. Tap the field to add ornaments.\n"
                          "2. Move ornaments by dragging.\n"
                          "3. Shake to start over.\n"
                          delegate:nil
                          cancelButtonTitle:nil  destructiveButtonTitle:nil
                          otherButtonTitles:@"Okay", nil];
    [msg showInView:self.view];
}

@end
