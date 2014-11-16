//
//  ViewController.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "ViewController.h"
#import "PAScrollableMenu.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@interface ViewController () <PAScrollableMenuDataSource, PAScrollableMenuDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet PAScrollableMenu *scrollableMenuView;
@property (nonatomic, strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

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
    
    UIView *contentSize = [UIView new];
    [contentSize setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.scrollView addSubview:contentSize];
    
    UIView *pageView;
    
    NSDictionary *pageMetrics = @{@"width":@(self.scrollView.bounds.size.width), @"height":@(self.scrollView.bounds.size.height)};
    
    for (int i = 0; i<10; i++) {
        [self.items addObject:[NSString stringWithFormat:@"Pestanha %i", i]];
        
        UIView *previousPage = [contentSize.subviews lastObject];
        
        pageView = [UIView new];
        [pageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [pageView setBackgroundColor:[self randomColor]];
        [contentSize addSubview:pageView];
        
        NSDictionary *pageViewDict = @{@"pageView":pageView, @"previousPage":previousPage?previousPage:@1};
        
        [contentSize addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:%@[pageView(width)]", previousPage?@"[previousPage]":@"|"] options:0 metrics:pageMetrics views:pageViewDict]];
        [contentSize addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView(height)]|" options:0 metrics:pageMetrics views:pageViewDict]];
    }
    
    NSDictionary *metrics = @{@"width":@(self.scrollView.bounds.size.width*contentSize.subviews.count), @"height":@(self.scrollView.bounds.size.height)};
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentSize(width)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contentSize)]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentSize(height)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(contentSize)]];
    
    [self.scrollableMenuView reloadData];
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

- (PAScrollableMenuCell *)PAScrollableMenu:(PAScrollableMenu *)aScrollableMenu cellAtIndexPath:(NSIndexPath *)indexPath{
    ReallyDebug
    PAScrollableMenuCell* cell = [aScrollableMenu dequeueReusableCell];
    if (!cell){
        cell = [PAScrollableMenuCell cell];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [cell setSelectedColor:[UIColor yellowColor]];
        [cell setSelectedFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:50]];
        [cell finishSetup];
    }
    
    NSString* itemName = [self.items objectAtIndex:indexPath.section];
    [cell.textLabel setText:itemName];
    [cell.textLabel sizeToFit];
    
    CGRect rect = cell.frame;
    rect.size.width = cell.textLabel.bounds.size.width;
    [cell setFrame:rect];
    
    return cell;
}

- (CGFloat)marginWidthInPAScrollableMenu:(PAScrollableMenu *)aScrollableMenu{
    return 4.f;
}

- (CGFloat)cellWidthInPAScrollableMenu:(PAScrollableMenu *)aScrollableMenu{
    return 100.f;
}

#pragma mark - PAScrollableMenu Delegate

- (void)PAScrollableMenu:(PAScrollableMenu *)aScrollableMenu didSelectCellAtIndexPath:(NSIndexPath *)indexPath{
    ReallyDebug
    NSLog(@"Seleccionar: %i", [aScrollableMenu indexForIndexPath:indexPath]);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    ReallyDebug
    [self.scrollableMenuView reloadData];
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    static CGFloat com1, com2, com3;
    
    com1 = [self componenteColorInicial:red1 colorFinal:red2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
    com2 = [self componenteColorInicial:green1 colorFinal:green2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
    com3 = [self componenteColorInicial:blue1 colorFinal:blue2 contenOffset:scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width];
    
    [self.animatableLabel setTextColor:[UIColor colorWithRed:com1 green:com2 blue:com3 alpha:alpha1]];
    [self.animatableLabel setFontSize:[self mateConValorInicial:fontSizeInicial valorFinal:fontSizeInicial+10 contenOffset:self.scrollView.contentOffset.x anchoPagina:scrollView.bounds.size.width]];
}*/



@end
