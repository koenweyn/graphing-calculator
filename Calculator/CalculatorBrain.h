//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Koen Weyn on 04/10/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double) operand;
- (void)pushVariable:(NSString *)variable;
- (double) performOperation:(NSString *)operation;
- (void)clear;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program withParameters:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

//blablabla

@end
