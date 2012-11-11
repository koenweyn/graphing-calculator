//
//  GraphView.h
//  Calculator
//
//  Created by Koen Weyn on 08/11/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;

- (void)tap:(UITapGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;

@end
