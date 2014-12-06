//
//  ViewController.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "ViewController.h"
#import "PAScrollableMenu.h"
#import "PAScrollView.h"
#import "PAMath.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@interface ViewController () <PAScrollableMenuDataSource, PAScrollableMenuDelegate, PAScrollViewDataSource, PAScrollViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet PAScrollableMenu *scrollableMenuView;
@property (nonatomic, strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet PAScrollView *scrollView;

@end

@implementation ViewController{
    CGFloat red1, red2, green1, green2, blue1, blue2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated{
    ReallyDebug
    [super viewDidAppear:animated];
    
    self.items = [NSMutableArray array];
    
    for (int i = 0; i<10; i++) {
        [self.items addObject:[NSString stringWithFormat:@"Pestanha %i", i]];
    }
    
    /*NSDictionary *metrics = @{@"width":@(self.scrollView.bounds.size.width*contentSize.subviews.count), @"height":@(self.scrollView.bounds.size.height)};
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentSize(width)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contentSize)]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentSize(height)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contentSize)]];*/
    
    [self.scrollableMenuView reloadData];
    [self.scrollView reloadData];
    
    NSInteger index = 2;
    [self.scrollableMenuView setIndexForSelectedCell:index];
}

- (UIColor *)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - PAScrollableMenu DataSource

- (NSUInteger)numberOfItemsInPAScrollableMenu:(PAScrollableMenu *)aScrollableMenu{
    ReallyDebug
    
    return self.items.count;
}

- (PAScrollableMenuCell *)PAScrollableMenu:(PAScrollableMenu *)aScrollableMenu cellAtIndex:(NSInteger)index{
    ReallyDebug
    
    PAScrollableMenuCell* cell = [aScrollableMenu newCell];
    [cell setBackgroundColor:[UIColor grayColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [cell setSelectedColor:[UIColor yellowColor]];
    [cell setSelectedFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    [cell finishSetup];
    
    NSString* itemName = [self.items objectAtIndex:index];
    [cell.textLabel setText:itemName];
    [cell.textLabel sizeToFit];
    
    CGRect rect = cell.frame;
    rect.size.width = cell.textLabel.bounds.size.width;
    [cell setFrame:rect];
    
    return cell;
}

- (CGFloat)marginWidthInPAScrollableMenu:(PAScrollableMenu *)aScrollableMenu{
    return 1.f;
}

- (CGFloat)cellWidthInPAScrollableMenu:(PAScrollableMenu *)aScrollableMenu{
    return 100.f;
}

#pragma mark - PAScrollableMenu Delegate

- (void)PAScrollableMenu:(PAScrollableMenu *)aScrollableMenu didSelectCellAtIndex:(NSInteger)index{
    ReallyDebug
    
    NSLog(@"Seleccionar: %li", (long)index);
    [self.scrollableMenuView setNoScrolling:YES];
    [self.scrollView setIndexPathForCurrentPageCell:[NSIndexPath indexPathForRow:0 inSection:index]];
    [self.scrollableMenuView setNoScrolling:NO];
}

#pragma mark - PAScrollView DataSource

- (NSUInteger)numberOfPagesInPAScrollView:(PAScrollView *)aScrollView{
    ReallyDebug
    
    return self.items.count;
}

- (PAScrollViewPageCell *)PAScrollView:(PAScrollView *)aScrollView pageCellAtIndexPath:(NSIndexPath *)indexPath{
    ReallyDebug
    
    PAScrollViewPageCell* pageCell = [aScrollView dequeueReusablePageCell];
    if (!pageCell){
        pageCell = [PAScrollViewPageCell pageCell];
        
        [pageCell.containerView setBackgroundColor:[UIColor grayColor]];
        
        UILabel *numberPage = [UILabel new];
        [numberPage setTranslatesAutoresizingMaskIntoConstraints:NO];
        [numberPage setBackgroundColor:[UIColor clearColor]];
        [numberPage setTextAlignment:NSTextAlignmentCenter];
        [numberPage setTextColor:[UIColor blackColor]];
        [numberPage setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        [numberPage sizeToFit];
        [numberPage setMinimumScaleFactor:.5f];
        [pageCell.containerView addSubview:numberPage];
        
        NSDictionary *viewDict =@{@"label":numberPage};
        NSDictionary *metrics = @{@"margin":@0};
        
        [pageCell.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[label]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:viewDict]];
        [pageCell.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[label]-(>=margin)-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:viewDict]];
        [pageCell.containerView addConstraint:[NSLayoutConstraint constraintWithItem:numberPage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:pageCell.containerView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        [pageCell.containerView addConstraint:[NSLayoutConstraint constraintWithItem:numberPage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:pageCell.containerView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    }
    
    UILabel *label = [pageCell.containerView.subviews lastObject];
    
    [label setText:[NSString stringWithFormat:@"Pagina: %li", (long)[aScrollView indexForIndexPath:indexPath]]];
    
    return pageCell;
}

- (id)PAScrollView:(PAScrollView *)aScrollView namePageCellAtIndexPath:(NSIndexPath *)indexPath{
    ReallyDebug
    
    PAScrollViewNamePageCell* namePageCell = [aScrollView dequeueReusableNamePageCell];
    if (!namePageCell){
        namePageCell = [PAScrollViewNamePageCell namePageCell];
        
        [namePageCell setBackgroundColor:[UIColor grayColor]];
    }
    
    [namePageCell.labelView setText:[NSString stringWithFormat:@"PaginaAtras: %li", (long)[aScrollView indexForIndexPath:indexPath]]];
    
    return namePageCell;
}

#pragma mark - Rotation Notification

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    ReallyDebug
    
    [self.scrollableMenuView reloadData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    ReallyDebug
    
    if (scrollView==self.scrollView) {
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
        [self.scrollableMenuView setIndexForSelectedCell:currentPage animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    ReallyDebug
    
    if (scrollView==self.scrollView) {
        [self.scrollableMenuView changeToCellWithOffset:scrollView.contentOffset.x pageWidth:self.scrollView.bounds.size.width];
    }
}

@end
