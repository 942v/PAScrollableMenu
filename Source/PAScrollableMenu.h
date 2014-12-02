//
//  PAScrollableMenu.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAScrollableMenuCell.h"

#pragma mark - Delegate & DataSource Protocols

@class PAScrollableMenu;

@protocol PAScrollableMenuDataSource <NSObject>

@required
- (NSUInteger)numberOfItemsInPAScrollableMenu:(PAScrollableMenu*)aScrollableMenu;
- (PAScrollableMenuCell*)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu cellAtIndex:(NSInteger)index;
- (CGFloat)cellWidthInPAScrollableMenu:(PAScrollableMenu*)aScrollableMenu;

@optional
- (CGFloat)marginWidthInPAScrollableMenu:(PAScrollableMenu*)aScrollableMenu;

@end

@protocol PAScrollableMenuDelegate <NSObject>

@optional
- (void)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu willDisplayCell:(PAScrollableMenuCell*)aCell forIndex:(NSInteger)index;
- (void)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu willSelectCellAtIndex:(NSInteger)index;
- (void)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu didSelectCellAtIndex:(NSInteger)index;

@end

#pragma mark - Interface

@interface PAScrollableMenu : UIScrollView

- (void)reloadData;
- (void)setIndexForSelectedCell:(NSInteger)index animated:(BOOL)animated;

@property (nonatomic, assign) IBOutlet id<PAScrollableMenuDelegate> scrollableMenuDelegate;
@property (nonatomic, assign) IBOutlet id<PAScrollableMenuDataSource> scrollableMenuDataSource;

@property (nonatomic, assign) NSInteger indexForSelectedCell;
@property (nonatomic, assign) BOOL noScrolling;
- (void)deselectSelectedCellAnimated:(BOOL)animated;
- (void)changeToCellWithOffset:(CGFloat)offset pageWidth:(CGFloat)pageWidth;

- (PAScrollableMenuCell*)newCell;

@end