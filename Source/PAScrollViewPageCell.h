//
//  PAScrollViewPageCell.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/15/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAScrollViewPageCell : UIView

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign, getter=isCurrentPage) BOOL currentPage;

+ (PAScrollViewPageCell*)pageCell;

@end
