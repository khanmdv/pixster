//
//  PixterScrollView.m
//  pixster
//
//  Created by Mohtashim Khan on 8/26/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "PixterScrollView.h"

#define kShiftFactor    170.0

@interface PixterScrollView ()

@property (assign, nonatomic) CGPoint touchDown;

@end

@implementation PixterScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    self.touchDown = [touch locationInView:self];
    NSLog(@"TouchDown");
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    
    // Two touches could be zoom, It has to be single touch
    if (touches.count > 1) return;
    
    CGPoint xy = [touch locationInView:self];
    CGRect scrollViewFrame = self.frame;
    
    float offset = xy.y - self.touchDown.y;
    
    // If movement is in the down direction
    if ( offset > 0 && fabs(offset) < kShiftFactor && scrollViewFrame.origin.y < 0){
        scrollViewFrame.origin.y+=10;
        self.frame = scrollViewFrame;
    } else if ( offset > 0 && fabs(offset) < kShiftFactor && scrollViewFrame.origin.y > 0){ // Swping up
        scrollViewFrame.origin.y-=10;
        self.frame = scrollViewFrame;
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    
    // Two touches could be zoom, It has to be single touch
    if (touches.count > 1) return;
    
    CGPoint xy = [touch locationInView:self];
    CGRect scrollViewFrame = self.frame;
    
    float offset = xy.y - self.touchDown.y;
    
    if (offset < 0){
        scrollViewFrame.origin.y = -kShiftFactor;
    }else{
        scrollViewFrame.origin.y = 0;
    }
    
    if (offset == 0.0) return;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = scrollViewFrame;
    }];
}

@end
