//
//  PAAnimatableLabel.m
//  PAScrollableMenu
//
//  Created by Guillermo Saenz on 11/13/14.
//  Copyright (c)2014 Property Atomic Strong SAC. All rights reserved.
//

#import "PAAnimatableLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+CoreTextExtensions.h"

@implementation PAAnimatableLabel

- (instancetype)init{
    self = [super init];
    if (self){
        [self initializeTextLayer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeTextLayer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self initializeTextLayer];
    }
    return self;
}

- (void)initializeTextLayer{
    _textLayer = [CATextLayer layer];
    [_textLayer setFrame:self.bounds];
    [_textLayer setContentsScale:[[UIScreen mainScreen] scale]];
    [_textLayer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [_textLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    
    // Initialize the default.
    self.textColor = [super textColor];
    self.font = [super font];
    self.backgroundColor = [super backgroundColor];
    self.text = [super text];
    self.textAlignment = [super textAlignment];
    self.lineBreakMode = [super lineBreakMode];
    // TODO: Get the value from the contentMode property so that the vertical alignment could be set via interface builder
    self.verticalTextAlignment = PATextVerticalAlignmentCenter;
    [super setText:nil];
    [self.layer addSublayer:_textLayer];
}

- (UIColor *)textColor{
    return [UIColor colorWithCGColor:_textLayer.foregroundColor];
}

- (void)setTextColor:(UIColor *)textColor{
    _textLayer.foregroundColor = textColor.CGColor;
    [self setNeedsDisplay];
}

- (NSString *)text{
    return _textLayer.string;
}

- (void)setText:(NSString *)text{
    _textLayer.string = text;
    [self setNeedsDisplay];
}

- (UIFont *)font{
    return [UIFont fontWithCTFont:_textLayer.font];
}

- (void)setFont:(UIFont *)font{
    if (font) {
        CTFontRef fontRef = font.CTFont;
        _textLayer.font = fontRef;
        if (_fontSize!=font.pointSize)_fontSize = font.pointSize;
        _textLayer.fontSize = _fontSize;
        CFRelease(fontRef);
        [self setNeedsDisplay];
    }
}

- (void)setFontWithName:(NSString*)fontName{
    _fontName = fontName;
    [self setFont:[UIFont fontWithName:_fontName size:_fontSize]];
}

- (void)setFontSize:(CGFloat)size{
    _fontSize = size;
    [self setFont:[UIFont fontWithName:_fontName size:_fontSize]];
}

- (void)setFrame:(CGRect)frame{
    _textLayer.frame = frame;
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (UIColor *)shadowColor{
    return [UIColor colorWithCGColor:_textLayer.shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor{
    _textLayer.shadowColor = shadowColor.CGColor;
    [self setNeedsDisplay];
}

- (CGSize)shadowOffset{
    return _textLayer.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset{
    _textLayer.shadowOffset = shadowOffset;
    [self setNeedsDisplay];
}

- (NSTextAlignment)textAlignment{
    NSTextAlignment labelAlignment = NSTextAlignmentLeft;
    NSString *layerAlignmentMode = _textLayer.alignmentMode;
    if ([layerAlignmentMode isEqualToString:kCAAlignmentLeft])
        labelAlignment = NSTextAlignmentLeft;
    else if ([layerAlignmentMode isEqualToString:kCAAlignmentRight])
        labelAlignment = NSTextAlignmentRight;
    else if ([layerAlignmentMode isEqualToString:kCAAlignmentCenter])
        labelAlignment = NSTextAlignmentCenter;
    
    return labelAlignment;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment{
    switch (textAlignment){
        case NSTextAlignmentLeft:
            _textLayer.alignmentMode = kCAAlignmentLeft;
            break;
        case NSTextAlignmentRight:
            _textLayer.alignmentMode = kCAAlignmentRight;
            break;
        case NSTextAlignmentCenter:
            _textLayer.alignmentMode = kCAAlignmentCenter;
            break;
        default:
            _textLayer.alignmentMode = kCAAlignmentNatural;
            break;
    }
    [self setNeedsDisplay];
}

- (NSLineBreakMode)lineBreakMode{
    return [super lineBreakMode];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode{
    switch (lineBreakMode){
        case NSLineBreakByWordWrapping:
            _textLayer.wrapped = YES;
            break;
        case NSLineBreakByClipping:
            _textLayer.wrapped = NO;
            break;
        case NSLineBreakByTruncatingHead:
            _textLayer.truncationMode = kCATruncationStart;
            break;
        case NSLineBreakByTruncatingTail:
            _textLayer.truncationMode = kCATruncationEnd;
            break;
        case NSLineBreakByTruncatingMiddle:
            _textLayer.truncationMode = kCATruncationMiddle;
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)setVerticalTextAlignment:(PATextVerticalAlignment)newVerticalTextAlignment{
    _verticalTextAlignment = newVerticalTextAlignment;
    [self setNeedsLayout];
}

- (CGSize)textSize{
    NSDictionary *userAttributes = @{NSFontAttributeName:self.font};

    return [self.text sizeWithAttributes:userAttributes];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.adjustsFontSizeToFitWidth){
        // Calculate the new font size:
        CGFloat newFontSize;
        float minimumFontSize = self.minimumScaleFactor;
        [_textLayer.string sizeWithFont:self.font minFontSize:minimumFontSize actualFontSize:&newFontSize forWidth:self.bounds.size.width lineBreakMode:self.lineBreakMode];
        self.font = [UIFont fontWithName:self.font.fontName size:newFontSize];
    }
    
    // Resize the text so that the text will be vertically aligned according to the set alignment
    CGSize stringSize = [self.text sizeWithFont:self.font
                              constrainedToSize:self.bounds.size
                                  lineBreakMode:self.lineBreakMode];
    
    CGRect newLayerFrame = self.layer.bounds;
    newLayerFrame.size.height = stringSize.height;
    switch (self.verticalTextAlignment){
        case PATextVerticalAlignmentCenter:
            newLayerFrame.origin.y = (self.bounds.size.height - stringSize.height)/ 2;
            break;
        case PATextVerticalAlignmentTop:
            newLayerFrame.origin.y = 0;
            break;
        case PATextVerticalAlignmentBottom:
            newLayerFrame.origin.y = (self.bounds.size.height - stringSize.height);
            break;
        default:
            break;
    }
    _textLayer.frame = newLayerFrame;
    
    // TODO: Handle numberOfLines
    
    [self setNeedsDisplay];
}

- (void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations{
    if (duration==0) {
        [self changes:^{
            animations();
        }];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setDisableActions:NO];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animations();
    [CATransaction commit];
}

- (void)changes:(void (^)(void))changes{
    [CATransaction begin];
    //[CATransaction setAnimationDuration:0.f];
    [CATransaction setDisableActions:YES];
    //[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    changes();
    [CATransaction commit];
}

@end
