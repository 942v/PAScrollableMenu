//
//  PAScrollableMenuCell.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/12/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAScrollableMenuCell : UIView

@property (nonatomic, strong) IBOutlet UILabel *textLabel;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL selected;

+ (PAScrollableMenuCell*)cell;

- (void)setSelected:(BOOL)select animated:(BOOL)animated;

@end
