//
//  DaysquareTests.m
//  DaysquareTests
//
//  Created by 杨弘宇 on 16/6/7.
//  Copyright © 2016年 Cyandev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DAYUtils.h"

@interface DaysquareTests : XCTestCase

@end

@implementation DaysquareTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCTAssertEqual([DAYUtils daysInMonth:2 ofYear:2016], 29);
    XCTAssertEqual([DAYUtils daysInMonth:6 ofYear:2016], 30);
    XCTAssertEqual([DAYUtils daysInMonth:12 ofYear:2016], 31);
    XCTAssertEqual([DAYUtils daysInMonth:1 ofYear:2017], 31);
    
    XCTAssertTrue([[DAYUtils stringOfWeekdayInEnglish:[DAYUtils firstWeekdayInMonth:6 ofYear:2016]] isEqualToString:@"Wed"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
