//
//  PAScrollView.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/15/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollView.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@interface PAScrollView () <UIScrollViewDelegate> {
    __weak id<UIScrollViewDelegate> _myDelegate;  // the delegate that other calling classes will set.
}

@property (nonatomic, strong) UIView *contentViewPageCells;
@property (nonatomic, strong) UIView *contentViewNamePageCells;

@property (nonatomic, assign) NSUInteger itemsCount;
@property (nonatomic, strong) NSMutableSet* visiblePageCells;
@property (nonatomic, strong) NSMutableDictionary* visiblePageCellsMapping;
@property (nonatomic, strong) NSMutableDictionary* visiblePageCellsConstraints;
@property (nonatomic, strong) NSMutableSet* recyclePoolPageCells;

@property (nonatomic, strong) NSMutableSet* visibleNamePageCells;
@property (nonatomic, strong) NSMutableDictionary* visibleNamePageCellsMapping;
@property (nonatomic, strong) NSMutableDictionary* visibleNamePageCellsConstraints;
@property (nonatomic, strong) NSMutableSet* recyclePoolNamePageCells;

@end

@implementation PAScrollView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder*)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        [self setup];
    }
    
    return self;
}

- (void)setup{
    ReallyDebug
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self setBounces:YES];
    [self setClipsToBounds:YES];
    [self setPagingEnabled:YES];
    [self setDelegate:self];
    
    self.contentViewNamePageCells = [UIView new];
    [self.contentViewNamePageCells setClipsToBounds:YES];
    //[self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentViewNamePageCells setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.contentViewNamePageCells];
    
    self.contentViewPageCells = [UIView new];
    [self.contentViewPageCells setClipsToBounds:YES];
    //[self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentViewPageCells setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.contentViewPageCells];
    
    self.visibleNamePageCells = [NSMutableSet set];
    self.visibleNamePageCellsMapping = [NSMutableDictionary dictionary];
    self.visibleNamePageCellsConstraints = [NSMutableDictionary dictionary];
    self.recyclePoolNamePageCells = [NSMutableSet set];
    
    self.visiblePageCells = [NSMutableSet set];
    self.visiblePageCellsMapping = [NSMutableDictionary dictionary];
    self.visiblePageCellsConstraints = [NSMutableDictionary dictionary];
    self.recyclePoolPageCells = [NSMutableSet set];
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if (newWindow) [self reloadData];
}

- (id<UIScrollViewDelegate>)delegate{
    return _myDelegate;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)aDelegate{
    
    [super setDelegate:self];
    
    if (aDelegate != _myDelegate){
        _myDelegate = aDelegate;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    ReallyDebug
    
    // check to see if I am my own delegate and then prevent infinite loop.
    if (_myDelegate != (id<UIScrollViewDelegate>)self && [_myDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
        [_myDelegate scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    ReallyDebug
    
    // Remove cells that are no longer visible an cached them
    for(PAScrollViewPageCell* pageCell in self.visiblePageCells){
        if (!CGRectIntersectsRect(pageCell.frame, CGRectOffset(self.bounds, -self.bounds.size.width, 0)) &&
            !CGRectIntersectsRect(pageCell.frame, self.bounds) &&
            !CGRectIntersectsRect(pageCell.frame, CGRectOffset(self.bounds, self.bounds.size.width, 0))){
            if ([self.scrollViewDelegate respondsToSelector:@selector(PAScrollView:willRecyclePageCell:forIndexPath:)]) {
                [self.scrollViewDelegate PAScrollView:self willRecyclePageCell:pageCell forIndexPath:pageCell.indexPath];
            }
            
            [self.recyclePoolPageCells addObject:pageCell];
            [self.visiblePageCellsMapping removeObjectForKey:pageCell.indexPath];
            [self.visiblePageCellsConstraints removeObjectForKey:pageCell.indexPath];
            [pageCell setIndexPath:nil];
            [pageCell removeFromSuperview];
        }
    }
    [self.visiblePageCells minusSet:self.recyclePoolPageCells];
    
    if (self.itemsCount == 0) return;
    
    CGFloat minX = CGRectGetMinX(self.bounds);
    NSUInteger firstSeenPageCellIndex = floorf((minX - floorf(minX/self.bounds.size.width))/self.bounds.size.width)-2;
    firstSeenPageCellIndex = MAX(firstSeenPageCellIndex, 0);
    
    CGFloat maxX = CGRectGetMaxX(self.bounds);
    NSUInteger  lastSeenPageCellIndex = floorf((maxX - floorf(maxX/self.bounds.size.width))/self.bounds.size.width)+2;
    lastSeenPageCellIndex = MIN(lastSeenPageCellIndex, self.itemsCount);
    
    CGFloat pageCellHeight = self.bounds.size.height;
    
    for (NSUInteger pageCellIndex = firstSeenPageCellIndex; pageCellIndex<lastSeenPageCellIndex; ++pageCellIndex){
        
        if (pageCellIndex >= self.itemsCount) return;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:pageCellIndex];
        PAScrollViewPageCell* pageCell = [self.visiblePageCellsMapping objectForKey:path];
        if (!pageCell){
            pageCell = [self.scrollViewDataSource PAScrollView:self pageCellAtIndexPath:path];
            pageCell.indexPath = path;
            
            if ([self.scrollViewDelegate respondsToSelector:@selector(PAScrollView:willDisplayPageCell:forIndexPath:)]){
                [self.scrollViewDelegate PAScrollView:self willDisplayPageCell:pageCell forIndexPath:path];
            }
            
            [self.contentViewPageCells insertSubview:pageCell atIndex:self.visiblePageCells.count];
            [self.visiblePageCells addObject:pageCell];
            [self.visiblePageCellsMapping setObject:pageCell forKey:path];
            
            NSArray *pageCellConstraints = [self.visiblePageCellsConstraints objectForKey:path];
            [self.contentViewPageCells removeConstraints:pageCellConstraints];
            
            NSDictionary *viewDict2 = @{@"pageCell":pageCell, @"contentView": self.contentViewPageCells};
            NSDictionary *metrics = @{@"leftMargin":@(pageCellIndex*self.bounds.size.width), @"height":@(pageCellHeight), @"width": @(self.bounds.size.width)};
            
            NSMutableArray *pageCellContraintsSave = [NSMutableArray array];
            
            [pageCellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[pageCell(width)]" options:0 metrics:metrics views:viewDict2]];
            [pageCellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageCell(height)]|" options:0 metrics:metrics views:viewDict2]];
            [self.contentViewPageCells addConstraints:pageCellContraintsSave];
            
            [self.visiblePageCellsConstraints setObject:pageCellContraintsSave forKey:path];
        }
    }
    
    // check to see if I am my own delegate and then prevent infinite loop.
    if (_myDelegate != (id<UIScrollViewDelegate>)self && [_myDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
        [_myDelegate performSelector:@selector(scrollViewDidEndDecelerating:) withObject:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    // check to see if I am my own delegate and then prevent infinite loop.
    if (_myDelegate != (id<UIScrollViewDelegate>)self && [_myDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
        [_myDelegate performSelector:@selector(scrollViewDidEndScrollingAnimation:) withObject:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    ReallyDebug
    
    // check to see if I am my own delegate and then prevent infinite loop.
    if (_myDelegate != (id<UIScrollViewDelegate>)self && [_myDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [_myDelegate performSelector:@selector(scrollViewWillBeginDragging:) withObject:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{  // called on finger up as we are moving
    ReallyDebug
    
    // check to see if I am my own delegate and then prevent infinite loop.
    if (_myDelegate != (id<UIScrollViewDelegate>)self && [_myDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]){
        [_myDelegate performSelector:@selector(scrollViewWillBeginDecelerating:) withObject:self];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    ReallyDebug
    
    // check to see if I am my own delegate and then prevent infinite loop.
    if (_myDelegate != (id<UIScrollViewDelegate>)self && [_myDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
        [_myDelegate performSelector:@selector(scrollViewDidScrollToTop:) withObject:self];
    }
}

#pragma mark - Loading & Tiling cells

- (void)reloadData{
    ReallyDebug
    
    [self setItemsCount:[self.scrollViewDataSource numberOfPagesInPAScrollView:self]];
    
    [self.contentViewNamePageCells removeConstraints:self.contentViewNamePageCells.constraints];
    [self.contentViewPageCells removeConstraints:self.contentViewPageCells.constraints];

    self.contentSize = CGSizeMake((self.bounds.size.width*self.itemsCount), self.bounds.size.height);
    [self.contentViewNamePageCells setFrame:(CGRect){
        .size = self.contentSize,
        .origin = CGPointZero
    }];
    
    [self.contentViewPageCells setFrame:(CGRect){
        .size = self.contentSize,
        .origin = CGPointZero
    }];
    
    for(PAScrollViewPageCell* pageCell in self.visiblePageCells){
        [self.recyclePoolPageCells addObject:pageCell];
        [pageCell removeFromSuperview];
    }
    [self.visiblePageCells removeAllObjects];
    [self.visiblePageCellsMapping removeAllObjects];
    [self.visiblePageCellsConstraints removeAllObjects];
    
    for(PAScrollViewNamePageCell* namePageCell in self.visibleNamePageCells){
        [self.recyclePoolNamePageCells addObject:namePageCell];
        [namePageCell removeFromSuperview];
    }
    [self.visibleNamePageCells removeAllObjects];
    [self.visibleNamePageCellsMapping removeAllObjects];
    [self.visibleNamePageCellsConstraints removeAllObjects];
    
    [self setNeedsLayout];
}

- (void)setIndexPathForCurrentPageCell:(NSIndexPath *)indexPath{
    ReallyDebug
    if (indexPath != _indexPathForCurrentPageCell){
        [self goToPageWithIndexPath:indexPath animated:NO];
        
        //[[self.visiblePageCellsMapping objectForKey:_indexPathForCurrentPageCell] setSelected:NO animated:animated];
        
        _indexPathForCurrentPageCell = indexPath;
        
        //[[self.visiblePageCellsMapping objectForKey:_indexPathForCurrentPageCell] setSelected:YES animated:animated];
    }
}

- (NSInteger)indexForIndexPath:(NSIndexPath*)indexPath{
    ReallyDebug
    return indexPath ? (indexPath.section + indexPath.row * self.itemsCount) : -1;
}

- (void)goToPageWithIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
    ReallyDebug
    
    NSInteger contentOffsetX = indexPath.section*self.bounds.size.width;
    [self setContentOffset:CGPointMake(contentOffsetX, 0) animated:animated];
}

- (PAScrollViewPageCell*)dequeueReusablePageCell{
    ReallyDebug
    PAScrollViewPageCell* pageCell = [self.recyclePoolPageCells anyObject];
    if (pageCell){
        [self.recyclePoolPageCells removeObject:pageCell];
        
        pageCell.currentPage = NO;
    }
    return pageCell;
}

- (PAScrollViewNamePageCell *)dequeueReusableNamePageCell{
    ReallyDebug
    PAScrollViewNamePageCell* namePageCell = [self.recyclePoolNamePageCells anyObject];
    if (namePageCell){
        [self.recyclePoolNamePageCells removeObject:namePageCell];
    }
    return namePageCell;
}

- (void)layoutSubviews{
    ReallyDebug
    
    // Remove cells that are no longer visible an cached them
    for(PAScrollViewNamePageCell* namePageCell in self.visibleNamePageCells){
        if (!CGRectIntersectsRect(namePageCell.frame, self.bounds)){
            [self.recyclePoolNamePageCells addObject:namePageCell];
            [self.visibleNamePageCellsMapping removeObjectForKey:namePageCell.indexPath];
            [self.visibleNamePageCellsConstraints removeObjectForKey:namePageCell.indexPath];
            [namePageCell removeFromSuperview];
        }
    }
    [self.visibleNamePageCells minusSet:self.recyclePoolNamePageCells];
    
    if (self.itemsCount == 0) return;
    
    CGFloat minX = CGRectGetMinX(self.bounds);
    NSUInteger firstSeenNamePageCellIndex = floorf((minX - floorf(minX/self.bounds.size.width))/self.bounds.size.width)-2;
    firstSeenNamePageCellIndex = MAX(firstSeenNamePageCellIndex, 0);
    
    CGFloat maxX = CGRectGetMaxX(self.bounds);
    NSUInteger  lastSeenNamePageCellIndex = floorf((maxX - floorf(maxX/self.bounds.size.width))/self.bounds.size.width)+2;
    lastSeenNamePageCellIndex = MIN(lastSeenNamePageCellIndex, self.itemsCount);
    
    CGFloat namePageCellHeight = self.bounds.size.height;
    
    for (NSUInteger namePageCellIndex = firstSeenNamePageCellIndex; namePageCellIndex<lastSeenNamePageCellIndex; ++namePageCellIndex){
        
        if (namePageCellIndex >= self.itemsCount) return;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:namePageCellIndex];
        PAScrollViewNamePageCell* namePageCell = [self.visibleNamePageCellsMapping objectForKey:path];
        if (!namePageCell){
            namePageCell = [self.scrollViewDataSource PAScrollView:self namePageCellAtIndexPath:path];
            namePageCell.indexPath = path;
            
            [self.contentViewNamePageCells insertSubview:namePageCell atIndex:self.visibleNamePageCells.count];
            [self.visibleNamePageCells addObject:namePageCell];
            [self.visibleNamePageCellsMapping setObject:namePageCell forKey:path];
        }
        
        NSArray *namePageCellConstraints = [self.visibleNamePageCellsConstraints objectForKey:path];
        [self.contentViewNamePageCells removeConstraints:namePageCellConstraints];
        
        NSDictionary *viewDict2 = @{@"namePageCell":namePageCell, @"contentView": self.contentViewNamePageCells};
        NSDictionary *metrics = @{@"leftMargin":@(namePageCellIndex*self.bounds.size.width), @"height":@(namePageCellHeight), @"width": @(self.bounds.size.width)};
        
        NSMutableArray *namePageCellContraintsSave = [NSMutableArray array];
        
        [namePageCellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[namePageCell(width)]" options:0 metrics:metrics views:viewDict2]];
        [namePageCellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[namePageCell(height)]|" options:0 metrics:metrics views:viewDict2]];
        [self.contentViewNamePageCells addConstraints:namePageCellContraintsSave];
        
        [self.visibleNamePageCellsConstraints setObject:namePageCellContraintsSave forKey:path];
        
        if ([self.scrollViewDelegate respondsToSelector:@selector(PAScrollView:willDisplayNamePageCell:forIndexPath:)]){
            [self.scrollViewDelegate PAScrollView:self willDisplayNamePageCell:namePageCell forIndexPath:path];
        }
    }
    
    [super layoutSubviews];
}

@end
