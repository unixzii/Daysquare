//
//  DAYIndicatorView.m
//  Daysquare
//
//  Created by 杨弘宇 on 16/6/7.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "DAYIndicatorView.h"

@interface DAYIndicatorView ()

@property (strong, nonatomic) CAShapeLayer *ellipseLayer;

@end

@implementation DAYIndicatorView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.ellipseLayer = [CAShapeLayer layer];
    self.ellipseLayer.fillColor = self.color.CGColor;
    [self.layer addSublayer:self.ellipseLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.ellipseLayer.path = CGPathCreateWithEllipseInRect(self.bounds, nil);
    self.ellipseLayer.frame = self.bounds;
}

- (void)setColor:(UIColor *)color {
    self->_color = color;
    self.ellipseLayer.fillColor = color.CGColor;
}

@end
