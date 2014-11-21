//
//  PAMath.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/14/14.
//  Copyright (c) 2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAMath.h"

@implementation PAMath

+ (CGFloat)componenteColorInicial:(CGFloat)colorInicial colorFinal:(CGFloat)colorFinal contenOffset:(CGFloat)contentOffset anchoPagina:(CGFloat)anchoPagina{
    return [self mateConValorInicial:colorInicial valorFinal:colorFinal contenOffset:contentOffset anchoPagina:anchoPagina];
}

+ (CGFloat)pointSizeInicial:(CGFloat)pointSizeInicial pointSizeFinal:(CGFloat)pointSizeFinal contenOffset:(CGFloat)contentOffset anchoPagina:(CGFloat)anchoPagina{
    return [self mateConValorInicial:pointSizeInicial valorFinal:pointSizeFinal contenOffset:contentOffset anchoPagina:anchoPagina];
}

+ (CGFloat)mateConValorInicial:(CGFloat)valorInicial valorFinal:(CGFloat)valorFinal contenOffset:(CGFloat)contentOffset anchoPagina:(CGFloat)anchoPagina{
    return valorInicial+(valorFinal-valorInicial)*contentOffset/anchoPagina;
}

@end
