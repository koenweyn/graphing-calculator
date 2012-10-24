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

- (void)testPerformOperation
{
    CalculatorBrain *brain = [[CalculatorBrain alloc]init];
    [brain pushOperand:5.0];
    [brain pushOperand:6.0];
    double result = [brain performOperation:@"+"];
    
    STAssertEquals(result, 11.0, nil);
    
    [brain pushOperand:9.0];
    result = [brain performOperation:@"*"];
    
    STAssertEquals(result, 99.0, nil);
    
    [brain pushOperand:11.0];
    result = [brain performOperation:@"/"];
    
    STAssertEquals(result, 9.0, nil);
    
    [brain pushOperand:4];
    result = [brain performOperation:@"sqrt"];

    STAssertEquals(result, 2.0, nil);
    
    result = [brain performOperation:@"-"];
    
    STAssertEquals(result, 7.0, nil);
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
    
    [brain pushOperand:20.5];
    [brain performOperation:@"/"];
    
    desc = [CalculatorBrain descriptionOfProgram:brain.program];
    STAssertEqualObjects(desc, @"((5 + 6) * 9) / 20.5", nil);
    
    [brain pushOperand:2];
    [brain performOperation:@"sqrt"];
    [brain performOperation:@"-"];
    
    desc = [CalculatorBrain descriptionOfProgram:brain.program];
    STAssertEqualObjects(desc, @"(((5 + 6) * 9) / 20.5) - sqrt(2)", nil);
    
}

@end
