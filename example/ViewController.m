//
//  ViewController.m
//  example
//
//  Created by jason.huang on 11/10/12.
//  Copyright (c) 2012 huang zunjian. All rights reserved.
//

#import "ViewController.h"
#import "CustomSwitch.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	CustomSwitch *switch1 = [[CustomSwitch alloc] initWithFrame:CGRectMake(100, 100, 120, 30)];
	switch1.offText = @"Unlike";
	switch1.onText = @"Like";
	switch1.onTintColor = [UIColor redColor];
	switch1.font = [UIFont boldSystemFontOfSize:12];
	[self.view addSubview:switch1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
