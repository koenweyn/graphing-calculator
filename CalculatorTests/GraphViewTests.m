//
//  GraphViewTests.m
//  Calculator
//
//  Created by Koen Weyn on 08/11/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import "GraphViewTests.h"
#import "GraphView.h"

@implementation GraphViewTests

- (void) testDefaultOrigin
{
    GraphView *graphView = [[GraphView alloc] init];
    CGPoint defaultOrigin = graphView.origin;
    STAssertEquals(defaultOrigin.x, (CGFloat)0, nil);
}

@end
