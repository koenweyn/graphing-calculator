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
@property (nonatomic, weak) IBOutlet UILabel *programDisplay;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize program = _program;
@synthesize programDisplay = _programDisplay;

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%@", self.splitViewController);
    if ([self.splitViewController respondsToSelector:@selector(setPresentsWithGesture:)]) {
        self.splitViewController.presentsWithGesture = NO;
    }
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //remove the button
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:barButtonItem];
    self.toolbar.items = toolbarItems;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    //add the button
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    
    NSLog(@"popOver size: %gx%g", pc.popoverContentSize.width, pc.popoverContentSize.height);
}

- (void)updateProgramDisplay
{
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:self.program];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //we cannot do this in the setter for program, because when running on iPhone, programDisplay is nil when setProgram is called
    [self updateProgramDisplay];
}

- (void)setProgram:(id)program
{
    if (_program != program) {
        _program = program;
        [self updateProgramDisplay];
        // force a redraw (needed for iPad where graphView is always on screen)
        [self.graphView setNeedsDisplay];
    }
        
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
