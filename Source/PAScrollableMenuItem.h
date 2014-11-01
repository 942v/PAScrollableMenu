//
//  PAScrollableMenuItem.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAScrollableMenuItem : UIView

+ (instancetype)newWithTitle:(NSString *)title;

@property (nonatomic, strong) UILabel   *   titleLabel;
@property (nonatomic, assign) NSInteger     indexArray;

@end
