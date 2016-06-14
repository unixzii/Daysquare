//
//  DAYComponentView.h
//  Daysquare
//
//  Created by 杨弘宇 on 16/6/7.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface DAYComponentView : UIControl

@property (readonly) UILabel *textLabel;
@property (copy, nonatomic) UIColor *textColor;
@property (copy, nonatomic) UIColor *highlightTextColor;
@property (strong, nonatomic) EKEvent *containingEvent;
@property (strong, nonatomic) id representedObject;

@end
