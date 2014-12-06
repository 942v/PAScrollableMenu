//
//  PAScrollViewNamePageCell.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 12/5/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollViewNamePageCell.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@implementation PAScrollViewNamePageCell

+ (PAScrollViewNamePageCell*)namePageCell{
    ReallyDebug
    PAScrollViewNamePageCell* newNamePageCell = [[self alloc] initWithFrame:CGRectZero];
    
    return newNamePageCell;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self configure];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure{
    ReallyDebug
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:YES];
    
    self.labelView = [UILabel new];
    [self.labelView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.labelView setBackgroundColor:[UIColor clearColor]];
    [self.labelView setTextAlignment:NSTextAlignmentCenter];
    [self.labelView setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [self.labelView setNumberOfLines:0];
    [self.labelView setLineBreakMode:NSLineBreakByWordWrapping];
    [self.labelView setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    [self.labelView setMinimumScaleFactor:.5f];
    [self addSubview:self.labelView];
    
    NSDictionary *viewDict = @{@"labelView":self.labelView};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[labelView]|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[labelView]|" options:0 metrics:nil views:viewDict]];
}

@end
