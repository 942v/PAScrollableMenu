//
//  PAScrollableMenuCell.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/12/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollableMenuCell.h"
#import "PAScrollableMenu.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@implementation PAScrollableMenuCell

#pragma mark - Initialization

+ (PAScrollableMenuCell*)cell{
    ReallyDebug
    PAScrollableMenuCell* newCell = [[self alloc] initWithFrame:CGRectZero];
    
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
    [self setBackgroundColor:[UIColor greenColor]];
    [self setClipsToBounds:YES];
    
    self.textLabel = [UILabel new];
    [self.textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textLabel setBackgroundColor:[UIColor redColor]];
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.textLabel setTextColor:[UIColor blackColor]];
    [self.textLabel setFont:[UIFont fontWithName:@"Helvetica-New" size:14]];
    [self.textLabel setText:@"Default"];
    [self.textLabel sizeToFit];
    [self.textLabel setMinimumScaleFactor:.5f];
    [self addSubview:self.textLabel];
    
    [self setFrame:CGRectMake(0, 0, self.textLabel.frame.size.width, 0)];
    
    NSDictionary *viewDict =@{@"label":self.textLabel};
    NSDictionary *metrics = @{@"margin":@0};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[label]-(>=margin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:viewDict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
}

#pragma mark - Tiling & Touch Mgmt

- (void)layoutSubviews{
    ReallyDebug
    
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)sel{
    ReallyDebug
    [self setSelected:sel animated:NO];
}

- (void)setSelected:(BOOL)sel animated:(BOOL)animated{
    ReallyDebug
    /*void(^changeSelection)() = ^{
        if (sel && self.selectedBackgroundView){
            self.backgroundView.alpha = 0.f;
            self.selectedBackgroundView.alpha = 1.f;
        }else{
            self.selectedBackgroundView.alpha = 0.f;
            self.backgroundView.alpha = 1.f;
        }
    };
    
    if (animated){
        static const NSTimeInterval duration = .3f;
        [UIView transitionWithView:self
                          duration:duration
                           options:UIViewAnimationOptionShowHideTransitionViews
                        animations:changeSelection
                        completion:nil];
    }else{
        changeSelection();
    }*/
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    ReallyDebug
    PAScrollableMenu *scrollableMenu = (PAScrollableMenu*)self.superview.superview;
    scrollableMenu.indexPathForSelectedCell = self.indexPath;
    
    if ([scrollableMenu.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:willSelectCellAtIndexPath:)]){
        [scrollableMenu.scrollableMenuDelegate PAScrollableMenu:scrollableMenu willSelectCellAtIndexPath:self.indexPath];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    ReallyDebug
    PAScrollableMenu *scrollableMenu = (PAScrollableMenu*)self.superview.superview;
    scrollableMenu.indexPathForSelectedCell = self.indexPath;
    
    if ([scrollableMenu.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:didSelectCellAtIndexPath:)]){
        [scrollableMenu.scrollableMenuDelegate PAScrollableMenu:scrollableMenu didSelectCellAtIndexPath:self.indexPath];
    }
}

/*
- (void)setBackgroundView:(UIView*)view{
    if (view != _backgroundView){
        if ([_backgroundView superview] == self){
            [_backgroundView removeFromSuperview];
        }
        
        _backgroundView = view;
        
        _backgroundView.frame = self.bounds;
        _backgroundView.userInteractionEnabled = NO;
        [self setSelected:self.selected animated:NO]; // update
        
        [self insertSubview:view atIndex:0];
    }
}

- (void)setSelectedBackgroundView:(UIView*)view{
    if (view != _selectedBackgroundView){
        if ([_selectedBackgroundView superview] == self){
            [_selectedBackgroundView removeFromSuperview];
        }

        _selectedBackgroundView = view;
        
        _selectedBackgroundView.frame = self.bounds;
        _selectedBackgroundView.userInteractionEnabled = NO;
        [self setSelected:self.selected animated:NO]; // update
        
        [self insertSubview:view atIndex:_backgroundView?1:0];
    }
}*/

@end
