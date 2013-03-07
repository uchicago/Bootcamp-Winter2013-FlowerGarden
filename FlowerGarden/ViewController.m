//
//  ViewController.m
//  FlowerGarden
//
//  Created by T. Andrew Binkowski on 3/7/13.
//  Copyright (c) 2013 T. Andrew Binkowski. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

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
    
    // Add an image view wit
    UIImageView *flowerImageView = [[UIImageView alloc] initWithImage:flower];
    
    // Place it at the touch point
    flowerImageView.center = touchPoint;
    
    // Add our image view to the field view
    [field addSubview:flowerImageView];
}

@end
