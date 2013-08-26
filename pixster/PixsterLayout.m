//
//  PixsterLayout.m
//  pixster
//
//  Created by Mohtashim Khan on 8/24/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "PixsterLayout.h"

@interface PixsterLayout ()

@end

@implementation PixsterLayout

-(void) setup{
    self.itemInsets = UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f);
    self.itemSize = CGSizeMake(80.0f , 80.0f);
    self.interItemSpacingY = 0.0f;
    self.numberOfColumns = 3;
}

-(id) init{
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

@end
