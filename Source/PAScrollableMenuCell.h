//
//  PAScrollableMenuCell.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/12/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAAnimatableLabel.h"

@interface PAScrollableMenuCell : UIView

@property (nonatomic, strong) IBOutlet PAAnimatableLabel *textLabel;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIFont *selectedFont;

+ (PAScrollableMenuCell*)cell;

- (void)setSelected:(BOOL)sel animated:(BOOL)animated;
- (void)finishSetup;

@end
