//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Koen Weyn on 02/10/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *history;
@property (weak, nonatomic) IBOutlet UILabel *variablesDisplay;

@end
