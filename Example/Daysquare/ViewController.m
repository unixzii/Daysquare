//
//  ViewController.m
//  Daysquare
//
//  Created by 杨弘宇 on 16/6/7.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import "ViewController.h"
#import "Classes/Daysquare.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet DAYCalendarView *calendarView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.datePicker addTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.calendarView addTarget:self action:@selector(calendarViewDidChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)datePickerDidChange:(id)sender {
    self.calendarView.selectedDate = self.datePicker.date;
}

- (void)calendarViewDidChange:(id)sender {
    self.datePicker.date = self.calendarView.selectedDate;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    NSLog(@"%@", [formatter stringFromDate:self.calendarView.selectedDate]);
}

- (IBAction)switchDidChange:(id)sender {
    self.calendarView.boldPrimaryComponentText = ((UISwitch *) sender).on;
    [self.calendarView reloadViewAnimated:YES];
}

- (IBAction)singleRowModeSwitchDidChange:(id)sender {
    BOOL flag = ((UISwitch *) sender).on;
    
    self.calendarHeightConstraint.constant = flag ? 100 : 260;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.72 initialSpringVelocity:0 options:kNilOptions animations:^{
        [self.view layoutIfNeeded];
        self.calendarView.singleRowMode = flag;
    } completion:nil];
}

- (IBAction)showUserEventsSwitchDidChange:(id)sender {
    self.calendarView.showUserEvents = ((UISwitch *) sender).on;
}

@end
