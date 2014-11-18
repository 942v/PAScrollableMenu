//
//  PAScrollableMenu.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAScrollableMenu.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@interface PAScrollableMenu ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSUInteger itemsCount;
@property (nonatomic, strong) NSMutableSet* visibleCells;
@property (nonatomic, strong) NSMutableDictionary* visibleCellsMapping;
@property (nonatomic, strong) NSMutableDictionary* visibleCellsConstraints;
@property (nonatomic, strong) NSMutableSet* recyclePool;
@property (nonatomic, assign) CGFloat marginWidth;
@property (nonatomic, assign) CGFloat cellWidth;

@end

@implementation PAScrollableMenu

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
    //[self setBackgroundColor:[UIColor clearColor]];
    [self setBounces:YES];
    [self setClipsToBounds:YES];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView setClipsToBounds:YES];
    //[self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView setBackgroundColor:[UIColor blueColor]];
    [self addSubview:self.contentView];
    
    self.visibleCells = [NSMutableSet set];
    self.visibleCellsMapping = [NSMutableDictionary dictionary];
    self.visibleCellsConstraints = [NSMutableDictionary dictionary];
    self.recyclePool = [NSMutableSet set];
    self.marginWidth = 0.f;
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if (newWindow) [self reloadData];
}

#pragma mark - Loading & Tiling cells

- (void)reloadData{
    ReallyDebug
    
    [self setItemsCount:[self.scrollableMenuDataSource numberOfItemsInPAScrollableMenu:self]];
    [self setCellWidth:[self.scrollableMenuDataSource cellWidthInPAScrollableMenu:self]];
    
    if ([self.scrollableMenuDataSource respondsToSelector:@selector(marginWidthInPAScrollableMenu:)]) {
        [self setMarginWidth:[self.scrollableMenuDataSource marginWidthInPAScrollableMenu:self]];
    }
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    self.contentSize = CGSizeMake((self.cellWidth*self.itemsCount)+((self.itemsCount-1)*self.marginWidth), self.bounds.size.height);
    [self.contentView setFrame:(CGRect){
        .size = self.contentSize,
        .origin = CGPointZero
    }];

    for(PAScrollableMenuCell* cell in self.visibleCells){
        [self.recyclePool addObject:cell];
        [cell removeFromSuperview];
    }
    [self.visibleCells removeAllObjects];
    [self.visibleCellsMapping removeAllObjects];

    [self setNeedsLayout];
    
}

- (void)deselectSelectedCellAnimated:(BOOL)animated{
    ReallyDebug
    [self setIndexPathForSelectedCell:nil animated:animated];
}

- (void)setIndexPathForSelectedCell:(NSIndexPath *)indexPath{
    ReallyDebug
    [self setIndexPathForSelectedCell:indexPath animated:YES];
}

- (void)setIndexPathForSelectedCell:(NSIndexPath *)indexPath animated:(BOOL)animated{
    ReallyDebug
    if (indexPath != _indexPathForSelectedCell){
        [[self.visibleCellsMapping objectForKey:_indexPathForSelectedCell] setSelected:NO animated:animated];
        
        _indexPathForSelectedCell = indexPath;
        
        [[self.visibleCellsMapping objectForKey:_indexPathForSelectedCell] setSelected:YES animated:animated];
    }
}

- (void)changeToCellWithOffset:(CGFloat)offset pageWidth:(CGFloat)pageWidth{
    if (offset<0) {
        [self changeToPreviousCellWithOffset:offset pageWidth:pageWidth];
    }else{
        [self changeToNextCellWithOffset:offset pageWidth:pageWidth];
    }
}

- (void)changeToNextCellWithOffset:(CGFloat)offset pageWidth:(CGFloat)pageWidth{
    PAScrollableMenuCell* cellActual = [self.visibleCellsMapping objectForKey:_indexPathForSelectedCell];
    [cellActual deselectWithOffset:offset sizeWidth:pageWidth];
    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:_indexPathForSelectedCell.row inSection:_indexPathForSelectedCell.section+1];
    PAScrollableMenuCell* cellSiguiente = [self.visibleCellsMapping objectForKey:nextIndex];
    [cellSiguiente setSelectedWithOffset:offset sizeWidth:pageWidth];
    
    //_indexPathForSelectedCell = nextIndex;
}

- (void)changeToPreviousCellWithOffset:(CGFloat)offset pageWidth:(CGFloat)pageWidth{
    PAScrollableMenuCell* cellActual = [self.visibleCellsMapping objectForKey:_indexPathForSelectedCell];
    [cellActual deselectWithOffset:offset sizeWidth:pageWidth];
    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:_indexPathForSelectedCell.row inSection:_indexPathForSelectedCell.section-1];
    PAScrollableMenuCell* cellSiguiente = [self.visibleCellsMapping objectForKey:nextIndex];
    [cellSiguiente setSelectedWithOffset:offset sizeWidth:pageWidth];
    
    //_indexPathForSelectedCell = nextIndex;
}

- (NSInteger)indexForIndexPath:(NSIndexPath*)indexPath{
    ReallyDebug
    return indexPath ? (indexPath.section + indexPath.row * self.itemsCount) : -1;
}



/*
 static CGFloat com1, com2, com3;
 
 com1 = [self componenteColorInicial:red1 colorFinal:red2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
 com2 = [self componenteColorInicial:green1 colorFinal:green2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
 com3 = [self componenteColorInicial:blue1 colorFinal:blue2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
 
 [self.animatableLabel setTextColor:[UIColor colorWithRed:com1 green:com2 blue:com3 alpha:alpha1]];
 [self.animatableLabel setFontSize:[self mateConValorInicial:fontSizeInicial valorFinal:fontSizeInicial+10 contenOffset:self.scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width]];
 */



- (PAScrollableMenuCell*)dequeueReusableCell{
    ReallyDebug
    PAScrollableMenuCell* cell = [self.recyclePool anyObject];
    if (cell){
        [self.recyclePool removeObject:cell];
        
        cell.selected = NO;
    }
    return cell;
}

- (void)layoutSubviews{
    ReallyDebug
    // Remove cells that are no longer visible an cached them
    for(PAScrollableMenuCell* cell in self.visibleCells){
        if (!CGRectIntersectsRect(cell.frame, self.bounds)){
            [self.recyclePool addObject:cell];
            [self.visibleCellsMapping removeObjectForKey:cell.indexPath];
            [self.visibleCellsConstraints removeObjectForKey:cell.indexPath];
            [cell removeFromSuperview];
        }
    }
    [self.visibleCells minusSet:self.recyclePool];
    
    if (self.itemsCount == 0) return;
    
    // !!!: ESTA ES LA WAA Q JODE
    /*NSUInteger firstSeenCellIndex = floorf( CGRectGetMinX(self.bounds) / self.cellWidth );
    firstSeenCellIndex = MAX(firstSeenCellIndex, 0);
    
    NSUInteger lastSeenCellIndex = floorf( (CGRectGetMaxX(self.bounds)-1) / self.cellWidth ) + 1;
    lastSeenCellIndex = MIN(lastColumn, self.itemsCount);*/
    
    CGFloat minX = CGRectGetMinX(self.bounds);
    NSUInteger firstSeenCellIndex = floorf((minX - (floorf(minX/(self.cellWidth+self.marginWidth)) * self.marginWidth))/self.cellWidth);
    firstSeenCellIndex = MAX(firstSeenCellIndex, 0);
    
    CGFloat maxX = CGRectGetMaxX(self.bounds);
    NSUInteger  lastSeenCellIndex = floorf((maxX - (floorf(maxX/(self.cellWidth+self.marginWidth))*self.marginWidth)+self.marginWidth)/self.cellWidth)+1;
    lastSeenCellIndex = MIN(lastSeenCellIndex, self.itemsCount);
    
    CGFloat cellHeight = self.bounds.size.height;
    
    for (NSUInteger cellIndex = firstSeenCellIndex; cellIndex<lastSeenCellIndex; ++cellIndex){
        
        //if (itemIndex >= self.itemsCount) return;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:cellIndex];
        PAScrollableMenuCell* cell = [self.visibleCellsMapping objectForKey:path];
        if (!cell){
            cell = [self.scrollableMenuDataSource PAScrollableMenu:self cellAtIndexPath:path];
            cell.indexPath = path;

            if (self.indexPathForSelectedCell){
                BOOL seleccionala = [self.indexPathForSelectedCell compare:path]==NSOrderedSame;
                if (seleccionala!=cell.selected)cell.selected = seleccionala;
            }else{
                if (cell.selected)cell.selected = NO;
            }

            [self.contentView insertSubview:cell atIndex:self.visibleCells.count];
            [self.visibleCells addObject:cell];
            [self.visibleCellsMapping setObject:cell forKey:path];
        }
        
        NSArray *cellConstraints = [self.visibleCellsConstraints objectForKey:path];
        [self.contentView removeConstraints:cellConstraints];

        NSDictionary *viewDict2 = @{@"cell":cell, @"contentView": self.contentView};
        NSDictionary *metrics = @{@"leftMargin":@(cellIndex*(self.cellWidth+self.marginWidth)), @"height":@(cellHeight), @"width": @(self.cellWidth)};
        
        NSMutableArray *cellContraintsSave = [NSMutableArray array];
        
        [cellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[cell(width)]" options:0 metrics:metrics views:viewDict2]];
        [cellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cell(height)]|" options:0 metrics:metrics views:viewDict2]];
        [self.contentView addConstraints:cellContraintsSave];
        
        [self.visibleCellsConstraints setObject:cellContraintsSave forKey:path];

        if ([self.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:willDisplayCell:forIndexPath:)]){
            [self.scrollableMenuDelegate PAScrollableMenu:self willDisplayCell:cell forIndexPath:path];
        }
    }
    
    [super layoutSubviews];
}

@end
