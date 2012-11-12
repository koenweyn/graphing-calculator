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

#define DEFAULT_SCALE 1.0;
#define DEFAULT_ORIGIN CGPointMake(0,0);

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
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay];
    }
}

- (void) setOrigin:(CGPoint)origin
{
    if (!self.originIsSet || !CGPointEqualToPoint(origin, _origin)) {
        _origin = origin;
        self.originIsSet = YES;
        [self setNeedsDisplay];
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

- (void)drawRect:(CGRect)rect
{
    CGPoint currentOrigin = self.origin;
    if (!self.originIsSet) {
        self.origin = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
        currentOrigin = self.origin;
    }
        
    [[AxesDrawer class] drawAxesInRect:rect originAtPoint:currentOrigin scale:self.scale];
    // Drawing code
}

@end
