//
//  PAScrollView.h
//  PAScrollView
//
//  Created by Guillermo Saenz on 11/15/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAScrollViewPageCell.h"

#pragma mark - Delegate & DataSource Protocols

@class PAScrollView;

@protocol PAScrollViewDataSource <NSObject>

@required
- (NSUInteger)numberOfPagesInPAScrollView:(PAScrollView*)aScrollView;
- (PAScrollViewPageCell*)PAScrollView:(PAScrollView*)aScrollView pageCellAtIndexPath:(NSIndexPath*)indexPath;

@end

@protocol PAScrollViewDelegate <NSObject>

@optional
- (void)PAScrollView:(PAScrollView*)aScrollView willDisplayPageCell:(PAScrollViewPageCell*)aPageCell forIndexPath:(NSIndexPath*)indexPath;

@end

#pragma mark - Interface

@interface PAScrollView : UIScrollView

- (PAScrollViewPageCell*)dequeueReusablePageCell;
- (void)reloadData;
- (void)setIndexPathForSelectedPageCell:(NSIndexPath *)indexPath animated:(BOOL)animated;

@property (nonatomic, assign) IBOutlet id<PAScrollViewDelegate> scrollViewDelegate;
@property (nonatomic, assign) IBOutlet id<PAScrollViewDataSource> scrollViewDataSource;

@property (nonatomic, strong) NSIndexPath* indexPathForSelectedPageCell;
- (NSInteger)indexForIndexPath:(NSIndexPath*)indexPath;
- (void)deselectSelectedPageCellAnimated:(BOOL)animated;

@end
