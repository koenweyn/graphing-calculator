//
//  GraphView.h
//  Calculator
//
//  Created by Koen Weyn on 08/11/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (double)yValueForGraphView:(GraphView *)sender forX:(double)x;
@end

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic) BOOL drawDots;

- (void)tap:(UITapGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)pinch:(UIPanGestureRecognizer *)gesture;
- (void)resetScaleAndOrigin;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
