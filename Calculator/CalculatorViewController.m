//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Koen Weyn on 02/10/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;


@end

@implementation CalculatorViewController

@synthesize display;
@synthesize history;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}


- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)dotPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        //only add a dot if the operand doesn't contain one yet
        NSRange rangeOfDot = [self.display.text rangeOfString:@"."];
        if (rangeOfDot.location == NSNotFound) {
            self.display.text = [self.display.text stringByAppendingString:@"."];
        }
    } else {
        self.display.text = @"0.";
        userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (void)updateHistoryDisplay {
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (void)updateVariablesDisplay {
    NSSet *variablesInProgram = [[CalculatorBrain class] variablesUsedInProgram:self.brain.program];
    
    NSString *variablesDisplay = @"";
    for (NSString *variableInProgram in variablesInProgram) {
        id variableTestValue = [self.testVariableValues objectForKey:variableInProgram];
        if (variableTestValue) {
            variablesDisplay = [variablesDisplay stringByAppendingFormat:@"%@ = %@  ", variableInProgram, variableTestValue];
        } else {
            variablesDisplay = [variablesDisplay stringByAppendingFormat:@"%@ = 0  ", variableInProgram];
        }
    }
    
    self.variablesDisplay.text = variablesDisplay;
}

- (IBAction)enterPressed {
    userIsInTheMiddleOfEnteringANumber = NO;
    
    //save the operand
    [self.brain pushOperand:[self.display.text doubleValue]];

    //change the history display
    [self updateHistoryDisplay];
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = sender.currentTitle;

    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([operation isEqualToString:@"+/-"]) {
            //change the sign of the number that is on the display
            double currentNumber = [self.display.text doubleValue];
            self.display.text = [NSString stringWithFormat:@"%g", -currentNumber];
            
            return;
        }

        //will save the current operand
        [self enterPressed];
    }
    
    
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    
    //change the history display
    [self updateHistoryDisplay];
    
    //change the variables display
    self.testVariableValues = nil;
    [self updateVariablesDisplay];
}

- (IBAction)clearPressed {
    //clear the history field
    self.history.text = @"";
    //clear the display
    self.display.text = @"0";
    userIsInTheMiddleOfEnteringANumber = NO;
    self.testVariableValues = nil;
    self.variablesDisplay.text = @"";
    
    //clear the model
    [self.brain clear];
}

- (IBAction)backspacePressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        int textLength = [self.display.text length];
        if (textLength == 1) {
            self.display.text = @"0";
        } else {
            self.display.text = [self.display.text substringToIndex:(textLength -1)];
        }
    }
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        //end the current number input
        [self enterPressed];
    }
    
    [self.brain pushVariable:sender.currentTitle];
}

- (IBAction)testPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        //end the current number input
        [self enterPressed];
    }

    if ([sender.currentTitle hasSuffix:@"1"]) {
        //program 1: a=1, b=2, c=3
        testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:1], @"a", [NSNumber numberWithDouble:2], @"b", [NSNumber numberWithDouble:3], @"c", nil];
    } else if ([sender.currentTitle hasSuffix:@"2"]) {
        //program 2: a=-5, b=-5
        testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:-5], @"a", [NSNumber numberWithDouble:5], @"b", nil];
    } else {
        testVariableValues = nil;
    }
    
    double result = [[CalculatorBrain class] runProgram:self.brain.program withParameters:testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    
    //change the history display
    [self updateHistoryDisplay];
    
    //change the variables display
    [self updateVariablesDisplay];
}

- (void)viewDidUnload {
    [self setVariablesDisplay:nil];
    [super viewDidUnload];
}
@end
