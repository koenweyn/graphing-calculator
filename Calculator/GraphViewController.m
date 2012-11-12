//
//  GraphViewController.m
//  Calculator
//
//  Created by Koen Weyn on 08/11/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize program = _program;
@synthesize programDisplay = _programDisplay;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //we cannot do this in the setter for program, because programDisplay is nil when setProgram is called
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:self.program];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    //add a tap recognizer calling tap:
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapRecognizer];
    
    //add a pan recognizer calling pan:
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];

    //add a pinch recognizer calling pinch:
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    
    //set ourself as the datasource
    self.graphView.dataSource = self;

}

- (double)yValueForGraphView:(GraphView *)sender forX:(double)x
{
    if (!self.program) return 0;
    
    return [CalculatorBrain runProgram:self.program withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:x], @"x", nil]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES; // support all orientations
}


- (void)viewDidUnload {
    [self setProgramDisplay:nil];
    [super viewDidUnload];
}
@end
