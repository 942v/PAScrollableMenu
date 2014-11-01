//
//  PAScrollableMenuItem.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollableMenuItem.h"

@implementation PAScrollableMenuItem

+ (instancetype)newWithTitle:(NSString *)title{
    PAScrollableMenuItem *newView = [PAScrollableMenuItem new];
    
    if (newView) {
        [newView.titleLabel setText:title];
        [newView.titleLabel sizeToFit];
    }
    
    return newView;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSDictionary *viewDict =@{@"label":self.titleLabel};
    NSDictionary *metrics = @{@"margin":@0};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[label]-margin-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[label]-margin-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:viewDict]];
}

- (void)setup{
    // Variables initialiatio
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setBackgroundColor:[UIColor greenColor]];
    
    [self initLabel];
}

- (void)initLabel{
    self.titleLabel = [UILabel new];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setBackgroundColor:[UIColor redColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica-New" size:14]];
    
    [self addSubview:self.titleLabel];
}

@end
