//
//  PAScrollableMenu.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollableMenu.h"

@interface PAScrollableMenu ()

@property (nonatomic, strong) UIScrollView      *   scrollView;
@property (nonatomic, strong) NSMutableArray    *   items;

@end

@implementation PAScrollableMenu

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    // Variables initialiatio
    
    self.items = [NSMutableArray new];
    
    [self initScrollView];
}

- (void)initScrollView{
    self.scrollView = [[UIScrollView alloc] init];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.scrollView setBounces:NO];
    
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSDictionary *view = @{@"sView": self.scrollView};
    NSDictionary *metrics = @{@"margin": @0};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[sView]-margin-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:view]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[sView]-margin-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:view]];
}

- (void)addMenuItemWithTitle:(NSString *)title{
    PAScrollableMenuItem *item = [PAScrollableMenuItem newWithTitle:title];
    
    BOOL hasCount = self.items.count>0;
    [item setIndexArray:self.items.count];
    
    [self.items addObject:item];
    [self addSubview:item];
    
    NSMutableDictionary *itemViewDict = [NSMutableDictionary dictionaryWithObject:item forKey:@"item"];
    NSDictionary *metrics = @{@"width":@(item.titleLabel.bounds.size.width)};
    
    [item addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[item(width)]" options:0 metrics:metrics views:itemViewDict]];
    
    NSString *clipVisualObjectString = @"|";
    if (hasCount) {
        [itemViewDict setObject:[self.items objectAtIndex:item.indexArray-1] forKey:@"item0"];
        clipVisualObjectString = @"[item0]";
    }
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:%@-4-[item]", clipVisualObjectString] options:0 metrics:nil views:itemViewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[item]|" options:0 metrics:nil views:itemViewDict]];
}

@end
