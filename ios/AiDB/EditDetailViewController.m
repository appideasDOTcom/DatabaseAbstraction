//
//  EditDetailViewController.m
//  AiDB
//
//  Created by Christopher Ostmo on 12/29/13.
//  Copyright (c) 2013 APPideas. All rights reserved.
//

#import "EditDetailViewController.h"

@interface EditDetailViewController ()

@end

@implementation EditDetailViewController

@synthesize field, caller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.detailInput setHidden:NO];
    [self.detailSwitch setHidden:YES];
    
    // iPad doesn't limit the keyboard type enough and we don't do any input checking, but the conversion mechanisms make reasonable defaults when non-exepcted values are supplied
    if( [self.field isEqualToString:@"strField"] )
    {
        self.detailLabel.text = @"String";
        self.detailInput.text = self.caller.testEntry.strField;
        [self.detailInput setKeyboardType:UIKeyboardTypeDefault];
    }
    else if( [self.field isEqualToString:@"intField"] )
    {
        self.detailLabel.text = @"Whole Number";
        self.detailInput.text = [NSString stringWithFormat:@"%li", (long)self.caller.testEntry.intField];
        [self.detailInput setKeyboardType:UIKeyboardTypeNumberPad];
    }
    else if( [self.field isEqualToString:@"floatField"] )
    {
        self.detailLabel.text = @"Decimal";
        self.detailInput.text = [NSString stringWithFormat:@"%0.2f", self.caller.testEntry.floatField];
        [self.detailInput setKeyboardType:UIKeyboardTypeDecimalPad];
    }
    else if( [self.field isEqualToString:@"boolField"] )
    {
        [self.detailInput setHidden:YES];
        [self.detailSwitch setHidden:NO];
        [self.detailSwitch setOn:caller.testEntry.boolField animated:YES];
        self.detailLabel.text = @"On/Off";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - App-specific methods

- (IBAction)saveAction:(id)sender
{
    if( [self.field isEqualToString:@"strField"] )
    {
        self.caller.testEntry.strField = self.detailInput.text;
    }
    else if( [self.field isEqualToString:@"intField"] )
    {
        self.caller.testEntry.intField = [self.detailInput.text integerValue];
    }
    else if( [self.field isEqualToString:@"floatField"] )
    {
        self.caller.testEntry.floatField = [self.detailInput.text floatValue];
    }
    else if( [self.field isEqualToString:@"boolField"] )
    {
        // The changing of the caller's switch state is handled in switchAction
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchAction:(id)sender
{
    self.caller.testEntry.boolField = self.detailSwitch.on;
}
@end
