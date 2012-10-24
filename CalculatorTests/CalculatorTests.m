//
//  CalculatorTests.m
//  CalculatorTests
//
//  Created by Koen Weyn on 24/10/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import "CalculatorTests.h"
#import "CalculatorBrain.h"

@implementation CalculatorTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testDescriptionOfProgram
{
    CalculatorBrain *brain = [[CalculatorBrain alloc]init];
    [brain pushOperand:5.0];
    [brain pushOperand:6.0];
    [brain performOperation:@"+"];
    
    NSString *desc = [CalculatorBrain descriptionOfProgram:brain.program];
    STAssertEqualObjects(desc, @"5 + 6", nil);

    [brain pushOperand:9.0];
    [brain performOperation:@"*"];

    desc = [CalculatorBrain descriptionOfProgram:brain.program];
    STAssertEqualObjects(desc, @"(5 + 6) * 9", nil);
}

@end
