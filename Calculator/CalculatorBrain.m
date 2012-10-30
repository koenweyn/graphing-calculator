//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Koen Weyn on 04/10/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (BOOL)isTwoOperandOperation:(id)stackItem
{
    NSSet *twoOperandOperations = [NSSet setWithObjects:@"+", @"x", @"-", @"/", nil];
    return [twoOperandOperations containsObject:stackItem];
}

+ (BOOL)isOneOperandOperation:(id)stackItem
{
    NSSet *oneOperandOperations = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", @"+/-", nil];
    return [oneOperandOperations containsObject:stackItem];
}

+ (BOOL)isZeroOperandOperation:(id)stackItem
{
    return [@"π" isEqual:stackItem];
}

+ (BOOL)isOperand:(id)stackItem
{
    return [stackItem isKindOfClass:[NSNumber class]];
}

+ (BOOL)isVariable:(id)stackItem
{
    return [stackItem isKindOfClass:[NSString class]]
    && !([self isTwoOperandOperation:stackItem] || [self isOneOperandOperation:stackItem] || [self isZeroOperandOperation:stackItem]);
}

+ (NSString *)removeOuterBracesIfNeeded:(NSString *)string
{
    if ([string hasPrefix:@"("] && [string hasSuffix:@")"]) {
        return [string substringWithRange:NSMakeRange (1, [string length] - 2)];
    }
    return string;
}

+ (NSString *)popDescriptionOfStack:(NSMutableArray *)stack
{
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if (!topOfStack){
        return @"0";
    } else if ([self isOperand:topOfStack] || [self isZeroOperandOperation:topOfStack] || [self isVariable:topOfStack]) {
        return [NSString stringWithFormat:@"%@", topOfStack];
    } else if ([self isOneOperandOperation:topOfStack]) {
        NSString *operand = [self popDescriptionOfStack:stack];
        return [NSString stringWithFormat:@"%@(%@)", topOfStack, [self removeOuterBracesIfNeeded:operand]];
    } else { //two operand operation
        NSString *operand1 = [self popDescriptionOfStack:stack];
        NSString *operand2 = [self popDescriptionOfStack:stack];
        return [NSString stringWithFormat:@"(%@ %@ %@)", operand2, topOfStack, operand1];
    }
}


+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    NSString *topOfStackDescription = [self removeOuterBracesIfNeeded:[self popDescriptionOfStack:stack]];
    while (!([topOfStackDescription isEqualToString:@"0"])) {
        [descriptions addObject:topOfStackDescription];
        topOfStackDescription =  [self removeOuterBracesIfNeeded:[self popDescriptionOfStack:stack]];
    }
        
    return [descriptions componentsJoinedByString:@", "];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
    
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

//clears the stack
- (void)clear
{
    [self.programStack removeAllObjects];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) { //this is an operand
        return [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) { //this is an operation
        NSString *operation = topOfStack;

        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"x" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"+/-"]) {
            result = - [self popOperandOffProgramStack:stack];
        }
    }
    
    return result;
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program withParameters:nil];
}

+ (double)runProgram:(id)program withParameters:(NSDictionary *)variableValues;
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    //replace variables with real values
    for (int i = 0; i < [stack count]; i++) {
        id stackItem = [stack objectAtIndex:i];
        if ([self isVariable:stackItem]) {
            id variableValue = [variableValues objectForKey:stackItem]; //if variableValues is nil, this will return nil

            NSNumber *numberValue;
            if (variableValue) {
                numberValue = variableValue;
            } else {
                numberValue = [NSNumber numberWithInt:0];
            }
            [stack replaceObjectAtIndex:i withObject:numberValue];
        }
            
    }
    
    
    return [self popOperandOffProgramStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variables = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]]) {
        for (id stackItem in program) {
            if ([self isVariable:stackItem]) {
                [variables addObject:stackItem];
            }
        }
    }
    
    if ([variables count] > 0) {
        return [variables copy];
    }
    
    return nil;
}

@end
