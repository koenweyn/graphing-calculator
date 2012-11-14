//
//  GraphView.m
//  Calculator
//
//  Created by Koen Weyn on 08/11/12.
//  Copyright (c) 2012 BLIBO. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView()

@property (nonatomic) BOOL originIsSet;

@end


@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize dataSource = _dataSource;

#define DEFAULT_SCALE 1.0;
#define DEFAULT_ORIGIN CGPointMake(0,0);

#define KEY_SCALE @"graphViewScale"
#define KEY_ORIGIN_X @"graphViewOriginX"
#define KEY_ORIGIN_Y @"graphViewOriginY"

- (CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE;
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (!scale) return; //don't accept 0
    
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
        
        [[NSUserDefaults standardUserDefaults] setFloat:_scale forKey:KEY_SCALE];
        NSLog(@"Scale update: save user defaults");
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) setOrigin:(CGPoint)origin
{
    if (!self.originIsSet || !CGPointEqualToPoint(origin, _origin)) {
        _origin = origin;
        self.originIsSet = YES;
        [self setNeedsDisplay];

        [[NSUserDefaults standardUserDefaults] setFloat:_origin.x forKey:KEY_ORIGIN_X];
        [[NSUserDefaults standardUserDefaults] setFloat:_origin.y forKey:KEY_ORIGIN_Y];
        NSLog(@"Origin update: save user defaults");
        [[NSUserDefaults standardUserDefaults] synchronize];
}
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationInView:self];
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint panTranslation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + panTranslation.x, self.origin.y + panTranslation.y);
        [gesture setTranslation:CGPointZero inView:self]; // reset translation to 0 (so future changes are incremental, not cumulative)
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}


- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
    
    NSLog(@"Load user defaults");
    self.scale = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_SCALE];
    float x = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_ORIGIN_X];
    float y = [[NSUserDefaults standardUserDefaults] floatForKey:KEY_ORIGIN_Y];
    if (x || y) { //0,0 means it wasn't stored yet
        self.origin = CGPointMake(x, y);
    }
        
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)drawGraph:(CGRect)rect
{
    if (!self.scale)
        return; //prevent divide by zero
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	UIGraphicsPushContext(context);
    
    [[UIColor blueColor] setStroke];

	CGContextBeginPath(context);
    
    BOOL drew = NO;
    
    //without scale
    for (CGFloat x = rect.origin.x; x < rect.origin.x + rect.size.width; x++) {
        CGFloat realX = (x - self.origin.x) / self.scale;
        CGFloat realY = [self.dataSource yValueForGraphView:self forX:realX];
        
        CGPoint pointOnScreen = CGPointMake(x, self.origin.y - realY * self.scale);
        
        if (CGRectContainsPoint(rect, pointOnScreen)) {
            if (drew) {
                CGContextAddLineToPoint(context, pointOnScreen.x, pointOnScreen.y);
            }
			CGContextMoveToPoint(context, pointOnScreen.x, pointOnScreen.y);
            drew = YES;
		}
    }
    
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}

- (void)drawRect:(CGRect)rect
{
    CGPoint currentOrigin = self.origin;
    if (!self.originIsSet) {
        self.origin = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
        currentOrigin = self.origin;
    }
    
    //draw axes
    [[AxesDrawer class] drawAxesInRect:rect originAtPoint:currentOrigin scale:self.scale];

    //draw graph
    NSLog(@"Value for 0: %g", [self.dataSource yValueForGraphView:self forX:0]);
    [self drawGraph:rect];
}

@end
