//
//  PAMath.h
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/14/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PAMath : NSObject

+ (CGFloat)componenteColorInicial:(CGFloat)colorInicial colorFinal:(CGFloat)colorFinal contenOffset:(CGFloat)contentOffset anchoPagina:(CGFloat)anchoPagina;
+ (CGFloat)pointSizeInicial:(CGFloat)pointSizeInicial pointSizeFinal:(CGFloat)pointSizeFinal contenOffset:(CGFloat)contentOffset anchoPagina:(CGFloat)anchoPagina;

@end
