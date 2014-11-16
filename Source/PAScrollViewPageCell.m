//
//  PAScrollViewPageCell.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/15/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollViewPageCell.h"
#import "PAScrollView.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@implementation PAScrollViewPageCell

+ (PAScrollViewPageCell*)pageCell{
    ReallyDebug
    PAScrollViewPageCell* newCell = [[self alloc] initWithFrame:CGRectZero];
    
    return newCell;
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
    
    self.containerView = [UIView new];
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.containerView];
    
    NSDictionary *viewDict = @{@"containerView":self.containerView};
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:0 metrics:nil views:viewDict]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|" options:0 metrics:nil views:viewDict]];
}

@end
