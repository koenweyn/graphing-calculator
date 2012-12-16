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
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController () <GraphViewDataSource, CalculatorProgramsTableViewControllerDelegate>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet id programDisplay;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dotModeTitle;
@property (nonatomic, weak) IBOutlet UISwitch *dotModeSwitch;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation GraphViewController

#define KEY_FAVORITES @"GraphViewController.Favorites"

@synthesize program = _program;
@synthesize graphView = _graphView;
@synthesize programDisplay = _programDisplay;
@synthesize toolbar = _toolbar;
@synthesize dotModeTitle = _dotModeTitle;
@synthesize dotModeSwitch = _dotModeSwitch;
@synthesize popoverController;

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
    NSString *description = [CalculatorBrain descriptionOfProgram:self.program];
    if ([self.programDisplay respondsToSelector:@selector(setTitle:)]) {
        [self.programDisplay setTitle:description];
    } else if ([self.programDisplay respondsToSelector:@selector(setText:)]) {
        [self.programDisplay setText:description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //we cannot do this in the setter for program, because when running on iPhone, programDisplay is nil when setProgram is called
    [self updateProgramDisplay];

    //customize font of dotModeTitle
    [self.dotModeTitle setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16], UITextAttributeFont,nil] forState:UIControlStateNormal];
    
    //synchronize state of dotModeSwitch with the actual value in graphView
    self.dotModeSwitch.on = self.graphView.drawDots;
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

- (IBAction)changeMode:(UISwitch *)sender {
    self.graphView.drawDots = sender.on;
}

- (IBAction)resetAxes:(id)sender {
    [self.graphView resetScaleAndOrigin];
}

- (IBAction)addToFavorites:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:KEY_FAVORITES] mutableCopy];
    if (!favorites) favorites = [NSMutableArray array];
    [favorites addObject:self.program];
    [defaults setObject:favorites forKey:KEY_FAVORITES];
    [defaults synchronize];
}

- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program
{
    self.program = program;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender deletedProgram:(id)program
{
    NSString *deletedProgramDescription = [CalculatorBrain descriptionOfProgram:program];
    NSMutableArray *favorites = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //create a new array that excludes the program that was deleted
    for (id favoriteProgram in [defaults objectForKey:KEY_FAVORITES]) {
        if (![[CalculatorBrain descriptionOfProgram:favoriteProgram] isEqualToString:deletedProgramDescription]) {
            [favorites addObject:favoriteProgram];
        }
    }
    [defaults setObject:favorites forKey:KEY_FAVORITES];
    [defaults synchronize];
    sender.programs = favorites;
}


//TODO KW programmatically execute segue, so that we can have toggle behaviour (http://stackoverflow.com/questions/8598557/uibarbuttonitem-popover-segue-creates-multiple-popovers)
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]){
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]){
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = popoverSegue.popoverController;
        }
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_FAVORITES];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
         
}


- (void)viewDidUnload {
    [self setProgramDisplay:nil];
    [self setDotModeTitle:nil];
    [super viewDidUnload];
}
@end
