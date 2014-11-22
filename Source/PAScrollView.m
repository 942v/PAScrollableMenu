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

@interface PAScrollView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSUInteger itemsCount;
@property (nonatomic, strong) NSMutableSet* visiblePageCells;
@property (nonatomic, strong) NSMutableDictionary* visiblePageCellsMapping;
@property (nonatomic, strong) NSMutableDictionary* visiblePageCellsConstraints;
@property (nonatomic, strong) NSMutableSet* recyclePool;

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
    
    self.contentView = [UIView new];
    [self.contentView setClipsToBounds:YES];
    //[self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView setBackgroundColor:[UIColor blueColor]];
    [self addSubview:self.contentView];
    
    self.visiblePageCells = [NSMutableSet set];
    self.visiblePageCellsMapping = [NSMutableDictionary dictionary];
    self.visiblePageCellsConstraints = [NSMutableDictionary dictionary];
    self.recyclePool = [NSMutableSet set];
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if (newWindow) [self reloadData];
}

#pragma mark - Loading & Tiling cells

- (void)reloadData{
    ReallyDebug
    
    [self setItemsCount:[self.scrollViewDataSource numberOfPagesInPAScrollView:self]];
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    self.contentSize = CGSizeMake((self.bounds.size.width*self.itemsCount), self.bounds.size.height);
    [self.contentView setFrame:(CGRect){
        .size = self.contentSize,
        .origin = CGPointZero
    }];
    
    for(PAScrollViewPageCell* pageCell in self.visiblePageCells){
        [self.recyclePool addObject:pageCell];
        [pageCell removeFromSuperview];
    }
    [self.visiblePageCells removeAllObjects];
    [self.visiblePageCellsMapping removeAllObjects];
    
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
    PAScrollViewPageCell* pageCell = [self.recyclePool anyObject];
    if (pageCell){
        [self.recyclePool removeObject:pageCell];
        
        pageCell.currentPage = NO;
    }
    return pageCell;
}

- (void)layoutSubviews{
    ReallyDebug
    // Remove cells that are no longer visible an cached them
    for(PAScrollViewPageCell* pageCell in self.visiblePageCells){
        if (!CGRectIntersectsRect(pageCell.frame, self.bounds)){
            [self.recyclePool addObject:pageCell];
            [self.visiblePageCellsMapping removeObjectForKey:pageCell.indexPath];
            [self.visiblePageCellsConstraints removeObjectForKey:pageCell.indexPath];
            [pageCell removeFromSuperview];
        }
    }
    [self.visiblePageCells minusSet:self.recyclePool];
    
    if (self.itemsCount == 0) return;
    
    CGFloat minX = CGRectGetMinX(self.bounds);
    NSUInteger firstSeenPageCellIndex = floorf((minX - floorf(minX/self.bounds.size.width))/self.bounds.size.width);
    firstSeenPageCellIndex = MAX(firstSeenPageCellIndex, 0);
    
    CGFloat maxX = CGRectGetMaxX(self.bounds);
    NSUInteger  lastSeenPageCellIndex = floorf(maxX - floorf(maxX/self.bounds.size.width)/self.bounds.size.width)+1;
    lastSeenPageCellIndex = MIN(lastSeenPageCellIndex, self.itemsCount);
    
    CGFloat pageCellHeight = self.bounds.size.height;
    
    for (NSUInteger pageCellIndex = firstSeenPageCellIndex; pageCellIndex<lastSeenPageCellIndex; ++pageCellIndex){
        
        //if (itemIndex >= self.itemsCount) return;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:pageCellIndex];
        PAScrollViewPageCell* pageCell = [self.visiblePageCellsMapping objectForKey:path];
        if (!pageCell){
            pageCell = [self.scrollViewDataSource PAScrollView:self pageCellAtIndexPath:path];
            pageCell.indexPath = path;
            
            [self.contentView insertSubview:pageCell atIndex:self.visiblePageCells.count];
            [self.visiblePageCells addObject:pageCell];
            [self.visiblePageCellsMapping setObject:pageCell forKey:path];
        }
        
        NSArray *pageCellConstraints = [self.visiblePageCellsConstraints objectForKey:path];
        [self.contentView removeConstraints:pageCellConstraints];
        
        NSDictionary *viewDict2 = @{@"pageCell":pageCell, @"contentView": self.contentView};
        NSDictionary *metrics = @{@"leftMargin":@(pageCellIndex*self.bounds.size.width), @"height":@(pageCellHeight), @"width": @(self.bounds.size.width)};
        
        NSLog(@"");
        
        NSMutableArray *pageCellContraintsSave = [NSMutableArray array];
        
        [pageCellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[pageCell(width)]" options:0 metrics:metrics views:viewDict2]];
        [pageCellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageCell(height)]|" options:0 metrics:metrics views:viewDict2]];
        [self.contentView addConstraints:pageCellContraintsSave];
        
        [self.visiblePageCellsConstraints setObject:pageCellContraintsSave forKey:path];
        
        if ([self.scrollViewDelegate respondsToSelector:@selector(PAScrollView:willDisplayPageCell:forIndexPath:)]){
            [self.scrollViewDelegate PAScrollView:self willDisplayPageCell:pageCell forIndexPath:path];
        }
    }
    
    [super layoutSubviews];
}

@end
