//
//  EditDetailViewController.h
//  AiDB
//
//  Created by Christopher Ostmo on 12/29/13.
//  Copyright (c) 2013 APPideas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestTable.h"
#import "AddDataViewController.h"

@interface EditDetailViewController : UIViewController
{
    /**
     * The field (instance variable name) being modified
     */
    NSString *field;

    /**
     * The calling view controller
     */
    AddDataViewController *caller;
}

@property (nonatomic, retain) NSString *field;
@property (nonatomic, retain) AddDataViewController *caller;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UITextField *detailInput;
@property (weak, nonatomic) IBOutlet UISwitch *detailSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

/**
 * Perform a save action following input validation
 *
 * @returns     IBAction
 * @since		20131221
 * @author		costmo
 * @param		sender					The calling entity
 */
- (IBAction)saveAction:(id)sender;

/**
 * Perform a UISwitch value changed action
 *
 * @returns     IBAction
 * @since		20131221
 * @author		costmo
 * @param		sender					The calling entity
 */
- (IBAction)switchAction:(id)sender;

/**
 * UIViewController subclass override
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

/**
 * UIViewController subclass override
 */
- (void)viewWillAppear:(BOOL)animated;

/**
 * UIViewController subclass override
 */
- (void)viewDidLoad;

/**
 * UIViewController subclass override
 */
- (void)didReceiveMemoryWarning;


@end
