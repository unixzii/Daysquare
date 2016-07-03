//
//  DAYComponentView.m
//  Daysquare
//
//  Created by 杨弘宇 on 16/6/7.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "DAYComponentView.h"
#import <EventKitUI/EventKitUI.h>

@interface DAYComponentView () <EKEventViewDelegate>

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) CAShapeLayer *dotLayer;

@end

@implementation DAYComponentView

- (void)setContainingEvent:(EKEvent *)containingEvent {
    self->_containingEvent = containingEvent;
    
    if (containingEvent) {
        self.dotLayer.fillColor = containingEvent.calendar.CGColor;
        self.dotLayer.hidden = NO;
    }
    else {
        self.dotLayer.hidden = YES;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.textLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
    self.dotLayer = [CAShapeLayer layer];
    self.dotLayer.hidden = YES;
    
    [self.layer addSublayer:self.dotLayer];
    
    UITapGestureRecognizer *aRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [self addGestureRecognizer:aRecognizer];
    
    UILongPressGestureRecognizer *anotherRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidLongPress:)];
    [self addGestureRecognizer:anotherRecognizer];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.dotLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 5, 5), nil);
    self.dotLayer.frame = CGRectMake((CGRectGetWidth(self.frame) - 5) / 2.0, CGRectGetMaxY(self.textLabel.frame), 5, 5);
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.textLabel.textColor = self.highlightTextColor;
        self.dotLayer.fillColor = self.highlightTextColor.CGColor;
    }
    else {
        self.textLabel.textColor = self.textColor;
        self.dotLayer.fillColor = self.containingEvent.calendar.CGColor;
    }
}

- (void)viewDidTap:(id)sender {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLongPress:(id)sender {
    if (self.containingEvent) {
        [self becomeFirstResponder];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = @[[[UIMenuItem alloc] initWithTitle:self.containingEvent.title action:@selector(showEvent)]];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES];
    }
}

- (void)showEvent {
    // If we can find a view controller to be presenter, then create and present `EKEventViewController`.
    UIResponder *next = self;
    while (next) {
        if ([next respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            EKEventViewController *eventVC = [[EKEventViewController alloc] init];
            eventVC.event = self.containingEvent;
            eventVC.allowsEditing = YES;
            eventVC.allowsCalendarPreview = YES;
            eventVC.delegate = self;
            
            [((UIViewController *) next) presentViewController:[[UINavigationController alloc] initWithRootViewController:eventVC] animated:YES completion:nil];
            return;
        }
        else {
            next = [next nextResponder];
        }
    }
}

#pragma mark - Event view delegate

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
