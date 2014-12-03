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
@property (nonatomic, strong) NSMutableArray *dataPool;
@property (nonatomic, assign) CGFloat marginWidth;

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
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.contentView];
    
    self.dataPool = [NSMutableArray array];
    self.marginWidth = 0.f;
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if (newWindow) [self reloadData];
}

#pragma mark - Loading & Tiling cells

- (void)reloadData{
    ReallyDebug
    
    [self setItemsCount:[self.scrollableMenuDataSource numberOfItemsInPAScrollableMenu:self]];
    
    if ([self.scrollableMenuDataSource respondsToSelector:@selector(marginWidthInPAScrollableMenu:)]) {
        [self setMarginWidth:[self.scrollableMenuDataSource marginWidthInPAScrollableMenu:self]];
    }
    
    [self.contentView removeConstraints:self.contentView.constraints];

    for (PAScrollableMenuCell *cell in self.dataPool) {
        [cell removeFromSuperview];
    }
    
    [self.dataPool removeAllObjects];
    
    CGFloat lastCellMaxX = 0;
    
    for (NSUInteger cellIndex = 0; cellIndex<self.itemsCount; ++cellIndex) {
        PAScrollableMenuCell* cell = [self.scrollableMenuDataSource PAScrollableMenu:self cellAtIndex:cellIndex];
        cell.index = cellIndex;
        
        if (self.indexForSelectedCell){
            BOOL seleccionala = self.indexForSelectedCell==cellIndex;
            if (seleccionala!=cell.selected)cell.selected = seleccionala;
        }else{
            if (cell.selected)cell.selected = NO;
        }
        
        [self.contentView insertSubview:cell atIndex:self.dataPool.count];
        
        CGFloat cellHeight = self.bounds.size.height;
        NSLog(@"Size: %f", cell.textLabel.textSize.width);
        
        NSDictionary *viewDict2 = @{@"cell":cell, @"contentView": self.contentView};
        NSDictionary *metrics = @{@"leftMargin":@(lastCellMaxX+(lastCellMaxX!=0?self.marginWidth:0)), @"height":@(cellHeight), @"width": @(cell.textLabel.textSize.width+4+(5*labs(cell.selectedFont.pointSize-cell.textLabel.fontSize)))};
        
        NSMutableArray *cellContraintsSave = [NSMutableArray array];
        
        [cellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[cell(width)]" options:0 metrics:metrics views:viewDict2]];
        [cellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cell(height)]|" options:0 metrics:metrics views:viewDict2]];
        [self.contentView addConstraints:cellContraintsSave];
        
        [cell setFrame:CGRectMake(lastCellMaxX+(lastCellMaxX!=0?self.marginWidth:0), 0, cell.textLabel.textSize.width+4+(5*labs(cell.selectedFont.pointSize-cell.textLabel.fontSize)), cellHeight)];
        
        [self.dataPool addObject:cell];
        
        lastCellMaxX = CGRectGetMaxX(cell.frame);
        
        if ([self.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:willDisplayCell:forIndex:)]){
            [self.scrollableMenuDelegate PAScrollableMenu:self willDisplayCell:cell forIndex:cellIndex];
        }
        
        if (cellIndex==self.itemsCount-1) {
            self.contentSize = CGSizeMake(CGRectGetMaxX(cell.frame), self.bounds.size.height);
            [self.contentView setFrame:(CGRect){
                .size = self.contentSize,
                .origin = CGPointZero
            }];
        }
    }

    [self setNeedsLayout];
    
}

- (void)deselectSelectedCellAnimated:(BOOL)animated{
    ReallyDebug
    [self setIndexForSelectedCell:-1 animated:animated];
}

- (void)setIndexForSelectedCell:(NSInteger)index{
    ReallyDebug
    [self setIndexForSelectedCell:index animated:YES];
}

- (void)setIndexForSelectedCell:(NSInteger)index animated:(BOOL)animated{
    ReallyDebug
    if (index != _indexForSelectedCell){
        if (index>=0)[[self.dataPool objectAtIndex:_indexForSelectedCell] setSelected:NO animated:animated];
        
        _indexForSelectedCell = index;

        if (index>=0)[[self.dataPool objectAtIndex:_indexForSelectedCell] setSelected:YES animated:animated];
        
        [self scrollRectToVisibleCenteredOnSelectedIndexCell];
        
        if ([self.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:didSelectCellAtIndex:)]){
            [self.scrollableMenuDelegate PAScrollableMenu:self didSelectCellAtIndex:index];
        }
    }
}

- (void)changeToCellWithOffset:(CGFloat)offset pageWidth:(CGFloat)pageWidth{
    if (self.noScrolling||offset<0) return;
    NSUInteger pasedPages = floor((offset - pageWidth / 2) / pageWidth);
    NSUInteger currentPage = pasedPages + 1;
    if (currentPage > self.itemsCount - 1) currentPage = self.itemsCount - 1;
    
    CGFloat oldX = currentPage * pageWidth;
    if (oldX != offset) {
        BOOL scrollingTowards = (offset > oldX);
        NSInteger targetIndex = (scrollingTowards) ? currentPage + 1 : currentPage - 1;
        if (targetIndex >= 0 && targetIndex < self.itemsCount) {
            PAScrollableMenuCell* cellActual = [self.dataPool objectAtIndex:currentPage];
            PAScrollableMenuCell* cellSiguiente = [self.dataPool objectAtIndex:targetIndex];
            
            CGFloat reducidoPrimeraPag = offset-(pageWidth*pasedPages);
            
            if (scrollingTowards) {
                [cellActual setSelectedWithOffset:reducidoPrimeraPag sizeWidth:pageWidth];
                [cellSiguiente deselectWithOffset:reducidoPrimeraPag sizeWidth:pageWidth];
            } else {
                [cellActual setSelectedWithOffset:reducidoPrimeraPag sizeWidth:pageWidth];
                [cellSiguiente deselectWithOffset:reducidoPrimeraPag sizeWidth:pageWidth];
            }
        }
    }
}

- (void)changeToNextCellWithIndex:(NSInteger)index offset:(CGFloat)offset pageWidth:(CGFloat)pageWidth{
    PAScrollableMenuCell* cellActual = [self.dataPool objectAtIndex:index];
    [cellActual deselectWithOffset:offset sizeWidth:pageWidth];
    NSInteger nextIndex = index+1;
    PAScrollableMenuCell* cellSiguiente = [self.dataPool objectAtIndex:nextIndex];
    [cellSiguiente setSelectedWithOffset:offset sizeWidth:pageWidth];
}

- (void)changeToPreviousCellWithOffset:(CGFloat)offset pageWidth:(CGFloat)pageWidth{
    PAScrollableMenuCell* cellActual = [self.dataPool objectAtIndex:_indexForSelectedCell];
    [cellActual setSelectedWithOffset:offset sizeWidth:pageWidth];
    NSInteger previousIndex = _indexForSelectedCell-1;
    PAScrollableMenuCell* cellAnterior = [self.dataPool objectAtIndex:previousIndex];
    [cellAnterior deselectWithOffset:offset sizeWidth:pageWidth];
}

- (PAScrollableMenuCell*)newCell{
    ReallyDebug
    PAScrollableMenuCell* cell = [PAScrollableMenuCell cell];
    cell.selected = NO;
    return cell;
}

/*
 static CGFloat com1, com2, com3;
 
 com1 = [self componenteColorInicial:red1 colorFinal:red2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
 com2 = [self componenteColorInicial:green1 colorFinal:green2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
 com3 = [self componenteColorInicial:blue1 colorFinal:blue2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
 
 [self.animatableLabel setTextColor:[UIColor colorWithRed:com1 green:com2 blue:com3 alpha:alpha1]];
 [self.animatableLabel setFontSize:[self mateConValorInicial:fontSizeInicial valorFinal:fontSizeInicial+10 contenOffset:offset anchoPagina:scrollView.bounds.size.width]];
 */


- (void)layoutSubviews{
    ReallyDebug
    // Remove cells that are no longer visible an cached them
    /*for(PAScrollableMenuCell* cell in self.visibleCells){
        if (!CGRectIntersectsRect(cell.frame, self.bounds)){
            [self.recyclePool addObject:cell];
            [self.visibleCellsMapping removeObjectForKey:cell.index];
            [self.visibleCellsConstraints removeObjectForKey:cell.index];
            [cell removeFromSuperview];
        }
    }
    [self.visibleCells minusSet:self.recyclePool];
    
    if (self.itemsCount == 0) return;*/
    
    // !!!: ESTA ES LA WAA Q JODE
    /*NSUInteger firstSeenCellIndex = floorf( CGRectGetMinX(self.bounds) / self.cellWidth );
    firstSeenCellIndex = MAX(firstSeenCellIndex, 0);
    
    NSUInteger lastSeenCellIndex = floorf( (CGRectGetMaxX(self.bounds)-1) / self.cellWidth ) + 1;
    lastSeenCellIndex = MIN(lastColumn, self.itemsCount);*/
    
    /*CGFloat minX = CGRectGetMinX(self.bounds);
    NSUInteger firstSeenCellIndex = floorf((minX - (floorf(minX/(self.cellWidth+self.marginWidth)) * self.marginWidth))/self.cellWidth);
    firstSeenCellIndex = MAX(firstSeenCellIndex, 0);
    
    CGFloat maxX = CGRectGetMaxX(self.bounds);
    NSUInteger  lastSeenCellIndex = floorf((maxX - (floorf(maxX/(self.cellWidth+self.marginWidth)) * self.marginWidth)+self.marginWidth)/self.cellWidth)+1;
    lastSeenCellIndex = MIN(lastSeenCellIndex, self.itemsCount);
    
    CGFloat cellHeight = self.bounds.size.height;
    
    for (NSUInteger cellIndex = firstSeenCellIndex; cellIndex<lastSeenCellIndex; ++cellIndex){
        
        if (cellIndex >= self.itemsCount) return;
        
        NSInteger path = [NSindex indexForRow:0 inSection:cellIndex];
        PAScrollableMenuCell* cell = [self.visibleCellsMapping objectForKey:path];
        if (!cell){
            cell = [self.scrollableMenuDataSource PAScrollableMenu:self cellAtindex:path];
            cell.index = path;

            if (self.indexForSelectedCell){
                BOOL seleccionala = [self.indexForSelectedCell compare:path]==NSOrderedSame;
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

        if ([self.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:willDisplayCell:forindex:)]){
            [self.scrollableMenuDelegate PAScrollableMenu:self willDisplayCell:cell forindex:path];
        }
    }*/
    
    [super layoutSubviews];
}

- (void)scrollRectToVisibleCenteredOnSelectedIndexCell{
    ReallyDebug
    
    PAScrollableMenuCell *cell = [self.dataPool objectAtIndex:_indexForSelectedCell];
    CGFloat originX = CGRectGetMinX(cell.frame);
    
    CGRect centeredRect = CGRectMake(originX + cell.frame.size.width/2.f - self.frame.size.width/2.f,
                                     0,
                                     self.frame.size.width,
                                     self.frame.size.height);
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self scrollRectToVisible:centeredRect animated:NO];
    } completion:nil];
}

@end
