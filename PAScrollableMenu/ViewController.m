//
//  ViewController.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 10/31/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "ViewController.h"
#import "PAScrollableMenu.h"
#import "PAAnimatableLabel.h"

#define IfDebug Debug==1
#define ReallyDebug if(IfDebug)NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

#define Debug 0

@interface ViewController () <PAScrollableMenuDataSource, PAScrollableMenuDelegate>

@property (weak, nonatomic) IBOutlet PAScrollableMenu *scrollableMenuView;
@property (nonatomic, strong) NSMutableArray *items;
@property (weak, nonatomic) IBOutlet PAAnimatableLabel *animatableLabel;

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
        
        // First simple way to set a background
        //cell.backgroundColor = [UIColor grayColor]; // One way
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

- (IBAction)cambiarActn:(id)sender {
    static CGFloat size;
    size++;
    [PAAnimatableLabel animateWithDuration:.3f animations:^{
        [self.animatableLabel setFontSize:self.animatableLabel.fontSize+size];
    }];
}

@end
