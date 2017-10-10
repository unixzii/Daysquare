//
//  DAYCalendarView.m
//  Daysquare
//
//  Created by 杨弘宇 on 16/6/7.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "DAYCalendarView.h"
#import "Internal/DAYNavigationBar.h"
#import "Internal/DAYComponentView.h"
#import "Internal/DAYIndicatorView.h"
#import "Internal/DAYUtils.h"

@interface DAYCalendarView () {
    NSUInteger _visibleYear;
    NSUInteger _visibleMonth;
    NSUInteger _currentVisibleRow;
    NSArray *_eventsInVisibleMonth;
}

@property (strong, nonatomic) DAYNavigationBar *navigationBar;
@property (strong, nonatomic) UIStackView *weekHeaderView;
@property (strong, nonatomic) UIView *contentWrapperView;
@property (strong, nonatomic) UIStackView *contentView;
@property (strong, nonatomic) DAYIndicatorView *selectedIndicatorView;
@property (strong, nonatomic) DAYIndicatorView *todayIndicatorView;
@property (strong, nonatomic) NSMutableArray<DAYComponentView *> *componentViews;

@property (readonly, copy) NSString *navigationBarTitle;

@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation DAYCalendarView

- (void)setSingleRowMode:(BOOL)singleRowMode {
    if (self->_singleRowMode != singleRowMode) {
        self->_singleRowMode = singleRowMode;
        [self updateCurrentVisibleRow];
    }
}

- (void)setShowUserEvents:(BOOL)showUserEvents {
    if (showUserEvents && self.eventStore == nil && !self.showUserEvents) {
        self.eventStore = [[EKEventStore alloc] init];
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                self->_showUserEvents = showUserEvents;
                [self performSelectorOnMainThread:@selector(reloadViewAnimated:) withObject:@YES waitUntilDone:nil];
            }
        }];
    }
    else {
        self->_showUserEvents = showUserEvents;
        [self reloadViewAnimated:YES];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.clipsToBounds = YES;
    
    // Set visible viewport to one contains today by default.
    NSDate *todayDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateComponents *comps = [DAYUtils dateComponentsFromDate:todayDate];
    self->_visibleYear = comps.year;
    self->_visibleMonth = comps.month;
    
    // Initialize default appearance settings.
    self.weekdayHeaderTextColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1];
    self.weekdayHeaderWeekendTextColor = [UIColor colorWithRed:0.75 green:0.25 blue:0.25 alpha:1];
    self.componentTextColor = [UIColor darkGrayColor];
    self.highlightedComponentTextColor = [UIColor whiteColor];
    self.selectedIndicatorColor = [UIColor colorWithRed:0.74 green:0.18 blue:0.06 alpha:1];
    self.todayIndicatorColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    self.indicatorRadius = 20;
    self.boldPrimaryComponentText = YES;
    
    self.navigationBar = [[DAYNavigationBar alloc] init];
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navigationBar.textLabel.text = self.navigationBarTitle;
    [self.navigationBar addTarget:self action:@selector(navigationBarButtonDidTap:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:self.navigationBar];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:self.navigationBar
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:40]];
    
    self.weekHeaderView = [[UIStackView alloc] init];
    self.weekHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.weekHeaderView.axis = UILayoutConstraintAxisHorizontal;
    self.weekHeaderView.distribution = UIStackViewDistributionFillEqually;
    self.weekHeaderView.alignment = UIStackViewAlignmentCenter;
    
    [self addSubview:self.weekHeaderView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.weekHeaderView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.navigationBar
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.weekHeaderView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:-self.indicatorRadius / 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.weekHeaderView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self.weekHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:self.weekHeaderView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:20]];
    
    self.contentWrapperView = [[UIView alloc] init];
    self.contentWrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.contentWrapperView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentWrapperView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.weekHeaderView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentWrapperView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-self.indicatorRadius / 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentWrapperView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:-self.indicatorRadius / 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentWrapperView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    self.contentView = [[UIStackView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.axis = UILayoutConstraintAxisVertical;
    self.contentView.distribution = UIStackViewDistributionFillEqually;
    self.contentView.alignment = UIStackViewAlignmentFill;
    
    [self.contentWrapperView addSubview:self.contentView];
    [self.contentWrapperView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentWrapperView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0]];
    [self.contentWrapperView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentWrapperView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0]];
    [self.contentWrapperView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentWrapperView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0]];
    [self.contentWrapperView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentWrapperView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0
                                                                         constant:0]];
    
    self.componentViews = [NSMutableArray array];
    [self makeUIElements];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    NSDateComponents *comps = [DAYUtils dateComponentsFromDate:selectedDate];
    int64_t delayTime = 0;
    if (self->_visibleMonth != comps.month || self->_visibleYear != comps.year) {
        [self jumpToMonth:comps.month year:comps.year];
        delayTime = 400;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self componentDidTap:[self componentViewForDateComponents:comps]];
        [self updateCurrentVisibleRow];
    });
}

- (void)makeUIElements {
    // Make indicator views;
    self.selectedIndicatorView = [[DAYIndicatorView alloc] init];
    self.selectedIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectedIndicatorView.hidden = YES;
    self.todayIndicatorView = [[DAYIndicatorView alloc] init];
    self.todayIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.todayIndicatorView.hidden = YES;
    
    [self.contentWrapperView insertSubview:self.todayIndicatorView belowSubview:self.contentView];
    [self.contentWrapperView insertSubview:self.selectedIndicatorView belowSubview:self.contentView];
    
    // Make weekday header view.
    for (int i = 1; i <= 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] init];
        [self.weekHeaderView addArrangedSubview:weekdayLabel];
    }
    
    // Make content view.
    __block int currentColumn = 0;
    __block UIStackView *currentRowView;
    
    void (^makeRow)() = ^{
        currentRowView = [[UIStackView alloc] init];
        currentRowView.axis = UILayoutConstraintAxisHorizontal;
        currentRowView.distribution = UIStackViewDistributionFillEqually;
        currentRowView.alignment = UIStackViewAlignmentFill;
    };
    
    void (^submitRowIfNecessary)() = ^{
        if (currentColumn >= 7) {
            [self.contentView addArrangedSubview:currentRowView];
            currentColumn = 0;
            makeRow();
        }
    };
    
    void (^submitCell)(UIView *) = ^(UIView *cellView) {
        [currentRowView addArrangedSubview:cellView];
        [self.componentViews addObject:(id) cellView];
        currentColumn++;
        submitRowIfNecessary();
    };
    
    makeRow();
    
    for (int i = 0; i < 42; i++) {
        DAYComponentView *componentView = [[DAYComponentView alloc] init];
        componentView.textLabel.textAlignment = NSTextAlignmentCenter;
        [componentView addTarget:self action:@selector(componentDidTap:) forControlEvents:UIControlEventTouchUpInside];
        submitCell(componentView);
    }
}

- (void)configureIndicatorViews {
    self.selectedIndicatorView.color = self.selectedIndicatorColor;
    self.todayIndicatorView.color = self.todayIndicatorColor;
}

- (void)configureWeekdayHeaderView {
    BOOL canUseLocalizedStrings = self.localizedStringsOfWeekday && self.localizedStringsOfWeekday.count == 7;
    
    [self.weekHeaderView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *weekdayLabel = (id) obj;
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = [UIFont systemFontOfSize:12];
        weekdayLabel.textColor = (idx == 0 || idx == 6) ? self.weekdayHeaderWeekendTextColor : self.weekdayHeaderTextColor;
        if (canUseLocalizedStrings) {
            weekdayLabel.text = self.localizedStringsOfWeekday[idx];
        }
        else {
            weekdayLabel.text = [DAYUtils stringOfWeekdayInEnglish:idx + 1];
        }
    }];
}

- (void)configureComponentView:(DAYComponentView *)view withDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = day;
    comps.month = month;
    comps.year = year;
    
    if ([DAYUtils isDateTodayWithDateComponents:comps]) {
        if (self.todayIndicatorView.hidden) {
            self.todayIndicatorView.hidden = NO;
            self.todayIndicatorView.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.3 animations:^{
                self.todayIndicatorView.transform = CGAffineTransformIdentity;
            }];
        }
        self.todayIndicatorView.attachingView = view;
        [self addConstraintToCenterIndicatorView:self.todayIndicatorView toView:view];
        
        // by Rakuyo. Solves the problem that default row is not the current date's row in single line mode
        if (self->_currentVisibleRow == 0) {
            NSUInteger paddingDays = [DAYUtils firstWeekdayInMonth:self->_visibleMonth ofYear:self->_visibleYear] - 1;
            
            float result = (day - paddingDays) / 7;
            self->_currentVisibleRow = floor(result) == result?(result - 1):floor(result);
        }
    }
    
    view.containingEvent = nil;
    if (self.showUserEvents) {
        [self->_eventsInVisibleMonth enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EKEvent *event = obj;
            if ([[DAYUtils dateFromDateComponents:comps] isEqualToDate:event.startDate]) {
                view.containingEvent = event;
                *stop = YES;
                return;
            }
        }];
    }
    
    view.representedObject = comps;
    
    if (self.selectedIndicatorView && self.selectedIndicatorView.attachingView == view) {
        [view setSelected:YES];
    }
    else {
        [view setSelected:NO];
    }
    view.textColor = self.componentTextColor;
    view.highlightTextColor = self.highlightedComponentTextColor;
    view.textLabel.alpha = self->_visibleMonth == month ? 1.0 : 0.5;
    if (self->_visibleMonth == month && self.boldPrimaryComponentText) {
        view.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    else {
        view.textLabel.font = [UIFont systemFontOfSize:16];
    }
    view.textLabel.text = [NSString stringWithFormat:@"%d", (int) day];
}

- (void)configureContentView {
    NSUInteger pointer = 0;
    
    NSUInteger totalDays = [DAYUtils daysInMonth:self->_visibleMonth ofYear:self->_visibleYear];
    NSUInteger paddingDays = [DAYUtils firstWeekdayInMonth:self->_visibleMonth ofYear:self->_visibleYear] - 1;
    
    // Handle user events displaying.
    if (self.showUserEvents) {
        NSDateComponents *startComps = [[NSDateComponents alloc] init];
        startComps.year = self->_visibleYear;
        startComps.month = self->_visibleMonth;
        startComps.day = 1;
        
        NSDateComponents *endComps = [[NSDateComponents alloc] init];
        endComps.year = self->_visibleYear;
        endComps.month = self->_visibleMonth;
        endComps.day = totalDays;
        
        NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:[DAYUtils dateFromDateComponents:startComps]
                                                                          endDate:[DAYUtils dateFromDateComponents:endComps]
                                                                        calendars:nil];
        self->_eventsInVisibleMonth = [self.eventStore eventsMatchingPredicate:predicate];
    }
    else {
        self->_eventsInVisibleMonth = nil;
    }
    
    // Make padding days.
    NSUInteger paddingYear = self->_visibleMonth == 1 ? self->_visibleYear - 1 : self->_visibleYear;
    NSUInteger paddingMonth = self->_visibleMonth == 1 ? 12 : self->_visibleMonth - 1;
    NSUInteger totalDaysInLastMonth = [DAYUtils daysInMonth:paddingMonth ofYear:paddingYear];
    
    for (int j = (int) paddingDays - 1; j >= 0; j--) {
        [self configureComponentView:self.componentViews[pointer++] withDay:totalDaysInLastMonth - j month:paddingMonth year:paddingYear];
    }
    
    // Make days in current month.
    for (int j = 0; j < totalDays; j++) {
        [self configureComponentView:self.componentViews[pointer++] withDay:j + 1 month:self->_visibleMonth year:self->_visibleYear];
    }
    
    // Make days in next month to fill the remain cells.
    NSUInteger reserveYear = self->_visibleMonth == 12 ? self->_visibleYear + 1 : self->_visibleYear;
    NSUInteger reserveMonth = self->_visibleMonth == 12 ? 1 : self->_visibleMonth + 1;
    
    for (int j = 0; self.componentViews.count - pointer > 0; j++) {
        [self configureComponentView:self.componentViews[pointer++] withDay:j + 1 month:reserveMonth year:reserveYear];
    }
}

- (void)addConstraintToCenterIndicatorView:(UIView *)view toView:(UIView *)toView {
    [[self.contentWrapperView.constraints copy] enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstItem == view) {
            [self.contentWrapperView removeConstraint:obj];
        }
    }];
    
    [self.contentWrapperView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:toView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0]];
    [self.contentWrapperView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:toView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0
                                                                         constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:self.indicatorRadius * 2]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:self.indicatorRadius * 2]];
}

- (NSString *)navigationBarTitle {
    NSString *stringOfMonth = [DAYUtils stringOfMonthInEnglish:self->_visibleMonth];
    return [NSString stringWithFormat:@"%@ %lu", stringOfMonth, (unsigned long) self->_visibleYear];
}

- (DAYComponentView *)componentViewForDateComponents:(NSDateComponents *)comps {
    __block DAYComponentView *view = nil;
    [self.componentViews enumerateObjectsUsingBlock:^(DAYComponentView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDateComponents *_comps = obj.representedObject;
        if (_comps.day == comps.day && _comps.month == comps.month && _comps.year == comps.year) {
            view = obj;
            *stop = YES;
        }
    }];
    
    return view;
}

- (void)navigationBarButtonDidTap:(id)sender {
    switch (self.navigationBar.lastCommand) {
        case DAYNaviagationBarCommandPrevious:
            [self jumpToPreviousMonth];
            break;
            
        case DAYNaviagationBarCommandNext:
            [self jumpToNextMonth];
            break;
            
        default:
            break;
    }
}

- (void)componentDidTap:(DAYComponentView *)sender {
    NSDateComponents *comps = sender.representedObject;
    
    if (comps.year != self->_visibleYear || comps.month != self->_visibleMonth) {
        [self jumpToMonth:comps.month year:comps.year];
        return;
    }
    
    // by Rakuyo. Solves the problem that switch error in single line mode
    if (self.selectedIndicatorView.hidden || self.selectedIndicatorView.alpha == 0) {
        
        if (self.selectedIndicatorView.hidden) {
            self.selectedIndicatorView.hidden = NO;
        }
        if (self.selectedIndicatorView.alpha == 0) {
            self.selectedIndicatorView.alpha = 1;
        }
        
        self.selectedIndicatorView.transform = CGAffineTransformMakeScale(0, 0);
        self.selectedIndicatorView.attachingView = sender;
        [self addConstraintToCenterIndicatorView:self.selectedIndicatorView toView:sender];
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:kNilOptions animations:^{
            self.selectedIndicatorView.transform = CGAffineTransformIdentity;
            [sender setSelected:YES];
        } completion:nil];
    }
    else {
        [self addConstraintToCenterIndicatorView:self.selectedIndicatorView toView:sender];
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:kNilOptions animations:^{
            [self.contentWrapperView layoutIfNeeded];
            
            [((DAYComponentView *) self.selectedIndicatorView.attachingView) setSelected:NO];
            [sender setSelected:YES];
        } completion:nil];
        
        self.selectedIndicatorView.attachingView = sender;
    }
    
    self->_selectedDate = [DAYUtils dateFromDateComponents:comps];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateCurrentVisibleRow {
    [self.contentView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.singleRowMode) {
            obj.hidden = self->_currentVisibleRow != idx;
            obj.alpha = obj.hidden ? 0 : 1;
        }
        else {
            obj.hidden = NO;
            obj.alpha = 1;
        }
    }];
    
    self.todayIndicatorView.alpha = self.todayIndicatorView.attachingView.superview.hidden ? 0 : 1;
    self.selectedIndicatorView.alpha = self.selectedIndicatorView.attachingView.superview.hidden ? 0 : 1;
}

- (void)reloadViewAnimated:(BOOL)animated {
    [self configureIndicatorViews];
    [self configureWeekdayHeaderView];
    [self configureContentView];
    
    if (animated) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:nil];
    }
}

#pragma mark - Actions

- (void)jumpToNextMonth {
    if (self.singleRowMode) {
        if (self->_currentVisibleRow < 5) {
            ++self->_currentVisibleRow;
            
            // by Rakuyo. Optimize jump logic
            NSUInteger totalDays = [DAYUtils daysInMonth:self->_visibleMonth ofYear:self->_visibleYear];
            NSUInteger paddingDays = [DAYUtils firstWeekdayInMonth:self->_visibleMonth  ofYear:self->_visibleYear] - 1;
            BOOL flag = (self.componentViews.count - totalDays - paddingDays) >= 7;
            
            if (self->_currentVisibleRow == 5 && flag) {
                ++self->_currentVisibleRow;
                [self jumpToNextMonth];
                
                return;
            }
            
            [UIView transitionWithView:self.contentWrapperView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromTop animations:nil completion:nil];
            [self updateCurrentVisibleRow];
            
            return;
        }
        else {
            self->_currentVisibleRow = 0;
        }
    }
    
    NSUInteger nextMonth;
    NSUInteger nextYear;
    
    if (self->_visibleMonth >= 12) {
        nextMonth = 1;
        nextYear = self->_visibleYear + 1;
    }
    else {
        nextMonth = self->_visibleMonth + 1;
        nextYear = self->_visibleYear;
    }
    
    [self jumpToMonth:nextMonth year:nextYear];
    
    if (self.singleRowMode) {
        [self updateCurrentVisibleRow];
    }
}

- (void)jumpToPreviousMonth {
    if (self.singleRowMode) {
        if (self->_currentVisibleRow > 0) {
            --self->_currentVisibleRow;
            [UIView transitionWithView:self.contentWrapperView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromBottom animations:nil completion:nil];
            [self updateCurrentVisibleRow];
            
            return;
        } else {
            
            // by Rakuyo. Optimize jump logic
            NSUInteger totalDays = [DAYUtils daysInMonth:self->_visibleMonth - 1 ofYear:self->_visibleYear];
            NSUInteger paddingDays = [DAYUtils firstWeekdayInMonth:self->_visibleMonth - 1  ofYear:self->_visibleYear] - 1;
            
            self->_currentVisibleRow = ((self.componentViews.count - totalDays - paddingDays) >= 7)?4:5;
        }
    }
    
    NSUInteger prevMonth;
    NSUInteger prevYear;
    
    if (self->_visibleMonth <= 1) {
        prevMonth = 12;
        prevYear = self->_visibleYear - 1;
    }
    else {
        prevMonth = self->_visibleMonth - 1;
        prevYear = self->_visibleYear;
    }
    
    [self jumpToMonth:prevMonth year:prevYear];
    
    if (self.singleRowMode) {
        [self updateCurrentVisibleRow];
    }
}

- (void)jumpToMonth:(NSUInteger)month year:(NSUInteger)year {
    BOOL direction;
    if (self->_visibleYear == year) {
        direction = month > self->_visibleMonth;
    }
    else {
        direction = year > self->_visibleYear;
    }
    
    self->_visibleMonth = month;
    self->_visibleYear = year;
    self->_selectedDate = nil;
    
    // Deal with indicator views.
    self.todayIndicatorView.hidden = YES;
    self.todayIndicatorView.attachingView = nil;
    self.selectedIndicatorView.attachingView = nil;
    
    [UIView transitionWithView:self.navigationBar.textLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.navigationBar.textLabel.text = self.navigationBarTitle;
    } completion:nil];
    
    UIView *snapshotView = [self.contentWrapperView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = self.contentWrapperView.frame;
    [self addSubview:snapshotView];
    
    [self configureContentView];
    
    self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.contentView.frame) / 3 * (direction ? 1 : -1));
    self.contentView.alpha = 0;
    
    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.72 initialSpringVelocity:0 options:kNilOptions animations:^{
        snapshotView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.contentView.frame) / 2 * (direction ? 1 : -1));
        snapshotView.alpha = 0;
        
        self.selectedIndicatorView.transform = CGAffineTransformMakeScale(0, 0);
        
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];
        
        if (!self.selectedDate) {
            self.selectedIndicatorView.hidden = YES;
        }
    }];
}

#pragma mark -

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self reloadViewAnimated:NO];
}

@end
