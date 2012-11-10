//
//  CustomSwitch.h
//
//  Created by jason on 12/11/10.
//  Copyright (c) 2011 none. All rights reserved.
//
//  based on DCRoundSwitch.h Created by Patrick Richards on 28/06/11.
//  MIT License.
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CustomSwitchToggleLayer;
@class CustomSwitchOutlineLayer;
@class CustomSwitchKnobLayer;

@interface CustomSwitch : UIControl
{
    @private
        CustomSwitchOutlineLayer *outlineLayer;
        CustomSwitchToggleLayer *toggleLayer;
        CustomSwitchKnobLayer *knobLayer;
        CAShapeLayer *clipLayer;
        BOOL ignoreTap;
}

-(void) setup;
-(void) useLayerMasking;
-(void) removeLayerMask;
-(void) positionLayersAndMask;

@property (nonatomic, retain) UIColor *onTintColor;		// default: blue (matches normal UISwitch)
@property (nonatomic, getter=isOn) BOOL on;				// default: NO
@property (nonatomic, copy) NSString *onText;			// default: 'ON' - not automatically localized!
@property (nonatomic, copy) NSString *offText;			// default: 'OFF' - not automatically localized!
@property (nonatomic, strong) UIFont *font;

- (void)setOn:(BOOL)newOn animated:(BOOL)animated;

@end
