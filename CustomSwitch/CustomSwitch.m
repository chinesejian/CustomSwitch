//
//  CustomSwitch.m
//
//  Created by jason on 12/11/10.
//  Copyright (c) 2011 none. All rights reserved.
//
//  based on DCRoundSwitch.h Created by Patrick Richards on 28/06/11.
//  MIT License.
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//
#import "CustomSwitch.h"
#import "CustomSwitchToggleLayer.h"
#import "CustomSwitchOutlineLayer.h"
#import "CustomSwitchKnobLayer.h"

@implementation CustomSwitch

@synthesize on, onText, offText;
@synthesize onTintColor;

-(id) init
{
    if (self = [super init])
    {
        [self sizeToFit];
        [self setup];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

-(void) setup 
{
    // this way you can set the bg color to black or something so it can be seen in IB
    self.backgroundColor = [UIColor clearColor];
    
    // remove the flexible w/h autoresizing masks if they have been set
    UIViewAutoresizing mask = (int)self.autoresizingMask;
    
    if (mask & UIViewAutoresizingFlexibleHeight) 
    {
        self.autoresizingMask ^= UIViewAutoresizingFlexibleHeight;
    }
    
    if (mask & UIViewAutoresizingFlexibleWidth)
    {
        self.autoresizingMask ^= UIViewAutoresizingFlexibleWidth;
    }
    
    self.onText = NSLocalizedString(@"ON", @"Used inside switches");
    self.offText = NSLocalizedString(@"OFF", @"Used inside switches");
    
    toggleLayer = [[CustomSwitchToggleLayer alloc] initWithOnString:self.onText
                                                           offString:self.offText
                                                         onTintColor:[UIColor colorWithRed:0.000 green:0.478 blue:0.882 alpha:1.0]];
	toggleLayer.drawOnTint = NO;
	toggleLayer.clip = YES;
	[self.layer addSublayer:toggleLayer];
	[toggleLayer setNeedsDisplay];
    
	outlineLayer = [CustomSwitchOutlineLayer layer];
	[toggleLayer addSublayer:outlineLayer];
	[outlineLayer setNeedsDisplay];
    
	knobLayer = [CustomSwitchKnobLayer layer];
	[self.layer addSublayer:knobLayer];
	[knobLayer setNeedsDisplay];
    
	toggleLayer.contentsScale = outlineLayer.contentsScale = knobLayer.contentsScale = [[UIScreen mainScreen] scale];
    
	// tap gesture for toggling the switch
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                            action:@selector(tapped:)];
	[self addGestureRecognizer:tapGestureRecognizer];
    
	// pan gesture for moving the switch knob manually
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self 
                                                                                  action:@selector(toggleDragged:)];
	[self addGestureRecognizer:panGesture];
    
	// call setFrame: manually so the initial layout can be done
	[self setFrame:self.frame];
    
	// setup the layer positions
	[self positionLayersAndMask];    
}

#pragma mark -
#pragma mark Setup Frame/Layout

- (void)sizeToFit
{
	[super sizeToFit];
    
	CGRect newFrame = self.frame;
	newFrame.size.width = 77.0;
	newFrame.size.height = 27.0;
	self.frame = newFrame;
}

- (void)useLayerMasking
{
	// turn of the manual clipping (done in toggleLayer's drawInContext:)
	toggleLayer.clip = NO;
	toggleLayer.drawOnTint = YES;
	[toggleLayer setNeedsDisplay];
    
	// create the layer mask and add that to the toggleLayer
	clipLayer = [CAShapeLayer layer];
	UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
														cornerRadius:self.bounds.size.height / 2.0];
	clipLayer.path = clipPath.CGPath;
	toggleLayer.mask = clipLayer;
}

- (void)removeLayerMask
{
	// turn off the animations so the user doesn't see the changing of mask/clipping
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
	// remove the layer mask (put on in useLayerMasking)
	toggleLayer.mask = nil;
    
	// renable manual clipping (done in toggleLayer's drawInContext:)
	toggleLayer.clip = YES;
	toggleLayer.drawOnTint = self.on;
	[toggleLayer setNeedsDisplay];
}

- (void)positionLayersAndMask
{
	// repositions the underlying toggle and the layer mask, plus the knob
	toggleLayer.mask.position = CGPointMake(-toggleLayer.frame.origin.x, 0.0);
	outlineLayer.frame = CGRectMake(-toggleLayer.frame.origin.x, 0, self.bounds.size.width, self.bounds.size.height);
	knobLayer.frame = CGRectMake(toggleLayer.frame.origin.x + toggleLayer.frame.size.width / 2.0 - knobLayer.frame.size.width / 2.0,
								 -1,
								 knobLayer.frame.size.width,
								 knobLayer.frame.size.height);
}

#pragma mark -
#pragma mark Interaction

- (void)tapped:(UITapGestureRecognizer *)gesture
{
	if (ignoreTap) return;
	
	if (gesture.state == UIGestureRecognizerStateEnded)
		[self setOn:!self.on animated:YES];
}

- (void)toggleDragged:(UIPanGestureRecognizer *)gesture
{
	CGFloat minToggleX = -toggleLayer.frame.size.width / 2.0 + toggleLayer.frame.size.height / 2.0;
	CGFloat maxToggleX = -1;
    
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[self useLayerMasking];
		[self positionLayersAndMask];
		knobLayer.gripped = YES;
	}
	else if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView:self];
        
		// disable the animations before moving the layers
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
		// darken the knob
		if (!knobLayer.gripped)
			knobLayer.gripped = YES;
        
		// move the toggleLayer using the translation of the gesture, keeping it inside the outline.
		CGFloat newX = toggleLayer.frame.origin.x + translation.x;
		if (newX < minToggleX) newX = minToggleX;
		if (newX > maxToggleX) newX = maxToggleX;
		toggleLayer.frame = CGRectMake(newX,
									   toggleLayer.frame.origin.y,
									   toggleLayer.frame.size.width,
									   toggleLayer.frame.size.height);
        
		// this will re-position the layer mask and knob
		[self positionLayersAndMask];
        
		[gesture setTranslation:CGPointZero inView:self];
	}
	else if (gesture.state == UIGestureRecognizerStateEnded)
	{
		// flip the switch to on or off depending on which half it ends at
		CGFloat toggleCenter = CGRectGetMidX(toggleLayer.frame);
		[self setOn:(toggleCenter > CGRectGetMidX(self.bounds)) animated:YES];
	}
    
	// send off the appropriate actions (not fully tested yet)
	CGPoint locationOfTouch = [gesture locationInView:self];
	if (CGRectContainsPoint(self.bounds, locationOfTouch))
		[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	else
		[self sendActionsForControlEvents:UIControlEventTouchDragOutside];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (ignoreTap) return;
    
	[super touchesBegan:touches withEvent:event];
    
	knobLayer.gripped = YES;
	[self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
    
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
    
	[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

#pragma mark Setters/Getters

- (void)setOn:(BOOL)newOn
{
	[self setOn:newOn animated:NO];
}

- (void)setOn:(BOOL)newOn animated:(BOOL)animated
{
	BOOL previousOn = self.on;
	on = newOn;
	ignoreTap = YES;
    
	[CATransaction setAnimationDuration:0.014];
	knobLayer.gripped = YES;
    
	// setup by turning off the manual clipping of the toggleLayer and setting up a layer mask.
	[self useLayerMasking];
	[self positionLayersAndMask];
    
	[CATransaction setCompletionBlock:^{
		[CATransaction begin];
		if (!animated)
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		else
			[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
        
		CGFloat minToggleX = -toggleLayer.frame.size.width / 2.0 + toggleLayer.frame.size.height / 2.0;
		CGFloat maxToggleX = -1;
        
        
		if (self.on)
		{
			toggleLayer.frame = CGRectMake(maxToggleX,
										   toggleLayer.frame.origin.y,
										   toggleLayer.frame.size.width,
										   toggleLayer.frame.size.height);
		}
		else
		{
			toggleLayer.frame = CGRectMake(minToggleX,
										   toggleLayer.frame.origin.y,
										   toggleLayer.frame.size.width,
										   toggleLayer.frame.size.height);
		}
        
		if (!toggleLayer.mask)
		{
			[self useLayerMasking];
			[toggleLayer setNeedsDisplay];
		}
        
		[self positionLayersAndMask];
        
		knobLayer.gripped = NO;
        
		[CATransaction setCompletionBlock:^{
			[self removeLayerMask];
			ignoreTap = NO;
            
			// send the action here so it get's sent at the end of the animations
			if (previousOn != on)
				[self sendActionsForControlEvents:UIControlEventValueChanged];
		}];
        
		[CATransaction commit];
	}];
}

- (void)setOnTintColor:(UIColor *)anOnTintColor
{
	if (anOnTintColor != onTintColor)
	{
		toggleLayer.onTintColor = anOnTintColor;
		[toggleLayer setNeedsDisplay];
	}
}

- (void)setFrame:(CGRect)aFrame
{
	[super setFrame:aFrame];
    
	CGFloat knobRadius = self.bounds.size.height + 2.0;
	knobLayer.frame = CGRectMake(0, 0, knobRadius, knobRadius);
	CGSize toggleSize = CGSizeMake(self.bounds.size.width * 2 - (knobRadius - 4), self.bounds.size.height);
	CGFloat minToggleX = -toggleSize.width / 2.0 + knobRadius / 2.0 - 1;
	CGFloat maxToggleX = -1;
    
	if (self.on)
	{
		toggleLayer.frame = CGRectMake(maxToggleX,
									   toggleLayer.frame.origin.y,
									   toggleSize.width,
									   toggleSize.height);
	}
	else
	{
		toggleLayer.frame = CGRectMake(minToggleX,
									   toggleLayer.frame.origin.y,
									   toggleSize.width,
									   toggleSize.height);
	}
    
	[self positionLayersAndMask];
}

- (void)setOnText:(NSString *)newOnText
{
	if (newOnText != onText)
	{
		onText = [newOnText copy];
		toggleLayer.onString = onText;
		[toggleLayer setNeedsDisplay];
	}
}

- (void)setOffText:(NSString *)newOffText
{
	if (newOffText != offText)
	{
		offText = [newOffText copy];
		toggleLayer.offString = offText;
		[toggleLayer setNeedsDisplay];
	}
}

@end