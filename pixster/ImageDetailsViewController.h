//
//  ImageDetailsViewController.h
//  pixster
//
//  Created by Mohtashim Khan on 8/26/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixterScrollView.h"

@interface ImageDetailsViewController : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UIView *landscapeView;
@property (strong, nonatomic) IBOutlet UIView *portraitView;

@property (nonatomic, strong) NSDictionary* imageDetails;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *dimensions;

@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet PixterScrollView *imgScrollVIew;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIScrollView *lanscapeScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *landscapeImgView;

- (IBAction)share:(id)sender;

@end
