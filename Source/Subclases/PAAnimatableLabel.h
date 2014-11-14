//
//  PAAnimatableLabel.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/13/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CATextLayer;

typedef enum : NSUInteger {
    PATextVerticalAlignmentCenter = 0,
    PATextVerticalAlignmentTop = 1,
    PATextVerticalAlignmentBottom = 2
} PATextVerticalAlignment;

@interface PAAnimatableLabel : UILabel

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) PATextVerticalAlignment verticalTextAlignment;
@property (nonatomic, readonly) CATextLayer *textLayer;

+ (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;
+ (void)changes:(void (^)(void))changes;

@end
