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
- (PAScrollableMenuCell*)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu cellAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)cellWidthInPAScrollableMenu:(PAScrollableMenu*)aScrollableMenu;

@optional
- (CGFloat)marginWidthInPAScrollableMenu:(PAScrollableMenu*)aScrollableMenu;

@end

@protocol PAScrollableMenuDelegate <NSObject>

@optional
- (void)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu willDisplayCell:(PAScrollableMenuCell*)aCell forIndexPath:(NSIndexPath*)indexPath;
- (void)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu willSelectCellAtIndexPath:(NSIndexPath*)indexPath;
- (void)PAScrollableMenu:(PAScrollableMenu*)aScrollableMenu didSelectCellAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface PAScrollableMenu : UIScrollView

- (PAScrollableMenuCell*)dequeueReusableCell;
- (void)reloadData;
- (void)setIndexPathForSelectedCell:(NSIndexPath *)indexPath animated:(BOOL)animated;

@property (nonatomic, assign) IBOutlet id<PAScrollableMenuDelegate> scrollableMenuDelegate;
@property (nonatomic, assign) IBOutlet id<PAScrollableMenuDataSource> scrollableMenuDataSource;

@property (nonatomic, strong) NSIndexPath* indexPathForSelectedCell;
- (void)deselectSelectedCellsAnimated:(BOOL)animated;

@end