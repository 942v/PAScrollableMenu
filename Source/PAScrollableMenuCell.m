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

@interface PAScrollableMenuCell ()

@property (nonatomic, strong) UIFont *originalFont;
@property (nonatomic, strong) UIColor *originalColor;
@property (nonatomic, strong) NSArray *originalColorRGB;
@property (nonatomic, strong) NSArray *selectedColorRGB;

@end

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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapViewGesture:)];
    [self addGestureRecognizer:tapGesture];
    [tapGesture setCancelsTouchesInView:NO];
    
    self.textLabel = [PAAnimatableLabel new];
    [self.textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textLabel setBackgroundColor:[UIColor redColor]];
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.textLabel setTextColor:[UIColor blackColor]];
    [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
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
    
    [self setSelectedColor:[UIColor blackColor]];
}

#pragma mark - Tiling & Touch Mgmt

- (void)layoutSubviews{
    ReallyDebug
    
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)sel{
    ReallyDebug
    _selected = sel;
    [self setSelected:sel animated:NO];
}

- (void)setSelected:(BOOL)sel animated:(BOOL)animated{
    ReallyDebug
    void(^changeSelection)() = ^{
        if (sel){
            [self.textLabel setTextColor:self.selectedColor];
            [self.textLabel setFont:self.selectedFont];
        }else{
            [self.textLabel setTextColor:self.originalColor];
            [self.textLabel setFont:self.originalFont];
        }
    };
    
    if (animated){
        static const NSTimeInterval duration = .7f;
        [self.textLabel animateWithDuration:duration animations:changeSelection];
    }else{
        [self.textLabel changes:changeSelection];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    ReallyDebug
    _selectedColor = selectedColor;
    static CGFloat red, green, blue, alpha;
    [_selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.selectedColorRGB = @[@(red), @(green), @(blue), @(alpha)];
}

- (void)finishSetup{
    ReallyDebug
    self.originalColor = self.textLabel.textColor;
    static CGFloat red, green, blue, alpha;
    [self.textLabel.textColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.originalColorRGB = @[@(red), @(green), @(blue), @(alpha)];
    self.originalFont = self.textLabel.font;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    ReallyDebug
    PAScrollableMenu *scrollableMenu = (PAScrollableMenu*)self.superview.superview;
    if ([scrollableMenu.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:willSelectCellAtIndexPath:)]){
        [scrollableMenu.scrollableMenuDelegate PAScrollableMenu:scrollableMenu willSelectCellAtIndexPath:self.indexPath];
    }
}

- (void)didTapViewGesture:(UITapGestureRecognizer*)recognizer{
    ReallyDebug
    
    if (recognizer.state==UIGestureRecognizerStateEnded){
        PAScrollableMenu *scrollableMenu = (PAScrollableMenu*)self.superview.superview;
        scrollableMenu.indexPathForSelectedCell = self.indexPath;
        
        if ([scrollableMenu.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:didSelectCellAtIndexPath:)]){
            [scrollableMenu.scrollableMenuDelegate PAScrollableMenu:scrollableMenu didSelectCellAtIndexPath:self.indexPath];
        }
    }
}

@end
