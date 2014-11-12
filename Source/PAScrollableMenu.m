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

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, assign) NSUInteger itemsCount;
@property(nonatomic, strong) NSMutableSet* visibleCells;
@property(nonatomic, strong) NSMutableDictionary* visibleCellsMapping;
@property(nonatomic, strong) NSMutableDictionary* visibleCellsConstraints;
@property(nonatomic, strong) NSMutableSet* recyclePool;

@end

@implementation PAScrollableMenu

#pragma mark - Init/Dealloc

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self configure];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder*)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        [self configure];
    }
    
    return self;
}

- (void)configure{
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
    self.marginWidth = 1.0f;
    self.cellWidth = 100;
    
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if (newWindow) [self reloadData];
}

#pragma mark - Loading & Tiling cells

- (void)reloadData{
    ReallyDebug
    
    [self setItemsCount:[self.scrollableMenuDataSource numberOfItemsInPAScrollableMenu:self]];
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    self.contentSize = CGSizeMake(self.cellWidth*self.itemsCount, self.bounds.size.height);
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

- (void)setMarginWidth:(CGFloat)val{
    ReallyDebug
    
    _marginWidth = val;
    [self setNeedsLayout]; // no need to reload all data, only relayout.
}

- (void)setCellWidth:(CGFloat)cellWidth{
    ReallyDebug
    
    _cellWidth = cellWidth;
    [self setNeedsDisplay];
}

- (void)deselectSelectedCellsAnimated:(BOOL)animated{
    ReallyDebug
    [self setIndexPathForSelectedCell:nil animated:animated];
}

- (void)setIndexPathForSelectedCell:(NSIndexPath *)indexPath{
    ReallyDebug
    [self setIndexPathForSelectedCell:indexPath animated:NO];
}

- (void)setIndexPathForSelectedCell:(NSIndexPath *)indexPath animated:(BOOL)animated{
    ReallyDebug
    if (indexPath != _indexPathForSelectedCell){
        [[self.visibleCellsMapping objectForKey:_indexPathForSelectedCell] setSelected:NO animated:animated];
        
        _indexPathForSelectedCell = indexPath;
        
        [[self.visibleCellsMapping objectForKey:_indexPathForSelectedCell] setSelected:YES animated:animated];
    }
}



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
    NSUInteger firstColumn = floorf( CGRectGetMinX(self.bounds) / self.cellWidth );
    firstColumn = MAX(firstColumn, 0);
    
    NSUInteger lastColumn = floorf( (CGRectGetMaxX(self.bounds)-1) / self.cellWidth ) + 1;
    lastColumn = MIN(lastColumn, self.itemsCount);
    
    //voilà
    //fix para soportar separacion entre celdas
    
//    int separacion = 20; //debe ser entero
//    NSUInteger firstColumn = floorf((CGRectGetMinX(self.bounds)-floorf(CGRectGetMinX(self.bounds)/(self.cellWidth+separacion))*separacion)/self.cellWidth);
//    firstColumn = MAX(firstColumn, 0);
//    
//    NSUInteger lastColumn = floorf((CGRectGetMaxX(self.bounds)-(floorf(CGRectGetMaxX(self.bounds)/(self.cellWidth+separacion))+1)*separacion)/self.cellWidth)-1;
//    firstColumn = MIN(lastColumn, self.itemsCount);
    
    
    
    
    
    CGFloat cellHeight = self.bounds.size.height;
    
    for (NSUInteger col = firstColumn; col<lastColumn; ++col){
        
        //if (itemIndex >= self.itemsCount) return;
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:col];
        PAScrollableMenuCell* cell = [self.visibleCellsMapping objectForKey:path];
        if (!cell){
            cell = [self.scrollableMenuDataSource PAScrollableMenu:self cellAtIndexPath:path];
            cell.indexPath = path;
            cell.selected = (path == self.indexPathForSelectedCell);
            [self.contentView insertSubview:cell atIndex:self.visibleCells.count];
            [self.visibleCells addObject:cell];
            [self.visibleCellsMapping setObject:cell forKey:path];
        }
        
        NSArray *cellConstraints = [self.visibleCellsConstraints objectForKey:path];
        [self.contentView removeConstraints:cellConstraints];

        NSDictionary *viewDict2 = @{@"cell":cell, @"contentView": self.contentView};
        NSDictionary *metrics = @{@"leftMargin":@(col*self.cellWidth), @"height":@(cellHeight), @"width": @(self.cellWidth-self.marginWidth)};
        
        NSMutableArray *cellContraintsSave = [NSMutableArray array];
        
        [cellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leftMargin-[cell(width)]" options:0 metrics:metrics views:viewDict2]];
        [cellContraintsSave addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cell(height)]|" options:0 metrics:metrics views:viewDict2]];
        [self.contentView addConstraints:cellContraintsSave];
        
        [self.visibleCellsConstraints setObject:cellContraintsSave forKey:path];

        if ([self.scrollableMenuDelegate respondsToSelector:@selector(PAScrollableMenu:willDisplayCell:forIndexPath:)]){
            [self.scrollableMenuDelegate PAScrollableMenu:self willDisplayCell:cell forIndexPath:path];
        }
    }
    
    NSLog(@"ancho ; %lu", (unsigned long)self.contentView.subviews.count);
    
    [super layoutSubviews];
}

@end
