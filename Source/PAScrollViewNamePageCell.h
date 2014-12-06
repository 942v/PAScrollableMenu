//
//  PAScrollViewNamePageCell.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 12/5/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAScrollViewNamePageCell : UIView

@property (nonatomic, strong) UILabel *labelView;
@property (nonatomic, strong) NSIndexPath *indexPath;

+ (PAScrollViewNamePageCell*)namePageCell;

@end
