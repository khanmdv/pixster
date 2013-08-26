//
//  ImageDetailsViewController.m
//  pixster
//
//  Created by Mohtashim Khan on 8/26/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "ImageDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>


#define kShiftFactor    170.0

@interface ImageDetailsViewController ()

-(void) toggleNavBar:(UITapGestureRecognizer*) gestureRecognizer;
-(void) swipeUpGesture:(UISwipeGestureRecognizer*) gestureRecognizer;

@end

@implementation ImageDetailsViewController

// Shift Image up or down
// shiftBy: +/- value for origin to make the shift down/up
- (void) shiftImage : (int) shiftBy{
    CGRect scrollViewFrame = self.imgScrollVIew.frame;
    scrollViewFrame.origin.y += shiftBy;
    [UIView animateWithDuration:0.3 animations:^{
        self.imgScrollVIew.frame = scrollViewFrame;
    }];
}

-(NSString*) getDimensions : (NSDictionary*) dict{
    NSUInteger width = [[dict valueForKeyPath:@"width"] integerValue];
    NSUInteger height = [[dict valueForKeyPath:@"height"] integerValue];
    NSString* dimensions = [NSString stringWithFormat:@"%dx%d", width, height];
    return dimensions;
}

-(void) toggleNavBar :(UITapGestureRecognizer*) gestureRecognizer{
    CGRect scrollViewFrame = self.imgScrollVIew.frame;
    
    // If the image is shifted up do not hide/show the nav bar, instead shift the image down
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && scrollViewFrame.origin.y < 0){
        [self shiftImage:kShiftFactor];
        return;
    }
    
    BOOL hideNavBar = !self.navigationController.isNavigationBarHidden;
    
    // Hide the status bar as well
    [[UIApplication sharedApplication] setStatusBarHidden:hideNavBar
                                            withAnimation:UIStatusBarAnimationFade];
    // Hid ethe nav bar
    [self.navigationController setNavigationBarHidden:hideNavBar
                                             animated:YES];
}

-(void) swipeUpGesture:(UISwipeGestureRecognizer*) gestureRecognizer{
    [self shiftImage:-kShiftFactor];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.imageDetails != nil){
        self.titleLabel.text = [self.imageDetails valueForKeyPath:@"titleNoFormatting"];
        self.dimensions.text = [self getDimensions:self.imageDetails];
        self.sourceLabel.text = [self.imageDetails valueForKeyPath:@"visibleUrl"];
        
        [self.imageView setImageWithURL:[NSURL URLWithString:[self.imageDetails valueForKeyPath:@"url"]]];
        [self.landscapeImgView setImageWithURL:[NSURL URLWithString:[self.imageDetails valueForKeyPath:@"url"]]];
        
        self.imgScrollVIew.contentSize = CGSizeMake(320, 568);
        self.lanscapeScrollView.contentSize = CGSizeMake(568, 320);
        
        // Add a tap gesture on the imageview to toggle the navigation bar
        UITapGestureRecognizer* tapGesturePortrait = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavBar:)];
        UITapGestureRecognizer* tapGestureLandscape = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavBar:)];
        
        [self.imgScrollVIew addGestureRecognizer:tapGesturePortrait];
        [self.lanscapeScrollView addGestureRecognizer:tapGestureLandscape];
        
        UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpGesture:)];
        swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self.imgScrollVIew addGestureRecognizer:swipeUpGesture];
        
        self.shareButton.layer.cornerRadius = 3.0;
        self.shareButton.layer.borderColor = [UIColor colorWithWhite:0.25 alpha:0.25].CGColor;
        self.shareButton.layer.borderWidth = 1.0;
    }
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)share:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share this image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Facebook", @"Twitter", nil];
    
    [actionSheet showInView:self.shareButton.superview];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        return self.imageView;
    } else{
        return self.landscapeImgView;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)
interfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        self.view = self.portraitView;
    } else{
        self.view = self.landscapeView;
    }
}


#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* service = nil;
    if (buttonIndex == 0){
        // Facebook
        service = SLServiceTypeFacebook;
    } else if(buttonIndex == 1) {
        // Twitter
        service = SLServiceTypeTwitter;
    } else if (buttonIndex == 2){
        return;
    }
    
    //Create the tweet sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:service];
    
    //Customize the tweet sheet here
    //Add a tweet message
    [tweetSheet setInitialText:self.titleLabel.text];
    
    [tweetSheet addImage:self.imageView.image];
    
    //Set a blocking handler for the tweet sheet
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
        [self dismissViewControllerAnimated:YES
                                 completion:^{}];
    };
    
    //Show the tweet sheet!
    [self presentViewController:tweetSheet
                       animated:YES
                     completion:^{}];
    
}

@end
