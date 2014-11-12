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

@interface ViewController () <PAScrollableMenuDataSource, PAScrollableMenuDelegate>

@property (weak, nonatomic) IBOutlet PAScrollableMenu *scrollableMenuView;
@property (nonatomic, strong) NSMutableArray *items;

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
    
    for (int i = 0; i<1000; i++) {
        [self.items addObject:[NSString stringWithFormat:@"Pestanha %i", i]];
    }
    
    [self.scrollableMenuView reloadData];
}

#pragma mark - OHGridView Delegate & DataSource

- (NSUInteger)numberOfItemsInPAScrollableMenu:(PAScrollableMenu *)aScrollableMenu{
    ReallyDebug
    return self.items.count;
}

- (PAScrollableMenuCell *)PAScrollableMenu:(PAScrollableMenu *)aScrollableMenu cellAtIndexPath:(NSIndexPath *)indexPath{
    ReallyDebug
    PAScrollableMenuCell* cell = [aScrollableMenu dequeueReusableCell];
    if (!cell){
        cell = [PAScrollableMenuCell cell];
        
        // First simple way to set a background
        //cell.backgroundColor = [UIColor grayColor]; // One way
        
        // Customize textLabel font size
    }
    
    NSString* itemName = [self.items objectAtIndex:indexPath.section];
    [cell.textLabel setText:itemName];
    [cell.textLabel sizeToFit];
    
    CGRect rect = cell.frame;
    rect.size.width = cell.textLabel.bounds.size.width;
    [cell setFrame:rect];
    
    return cell;
}

- (void)PAScrollableMenu:(PAScrollableMenu *)aScrollableMenu didSelectCellAtIndexPath:(NSIndexPath *)indexPath{
    ReallyDebug
    NSLog(@"Seleccionar");
    /*
     NSUInteger idx = [aGridView indexForIndexPath:indexPath];
     NSString* msg = [self.items objectAtIndex:idx];
     UIAlertView* alert = noarc_autorelease([[UIAlertView alloc] initWithTitle:@"Tap"
     message:msg
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil]);
     [alert show];
     */
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    ReallyDebug
    [self.scrollableMenuView reloadData];
}

@end

/*
 
 ////////////////////////////////////////////////////////////////////////////////////////////////////

 
 ////////////////////////////////////////////////////////////////////////////////////////////////////
 #pragma mark - UIAlertView Delegate
 
 -(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
 {
	[(OHGridView*)self.view deselectSelectedCellsAnimated:YES];
 }
 
 ////////////////////////////////////////////////////////////////////////////////////////////////////
 #pragma mark - Interface Orientation
 
 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
 {
	return YES;
 }
 

 */