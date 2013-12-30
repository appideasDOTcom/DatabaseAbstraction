/**
 * The view controller that activates when a person views (to modify) a test_table or adds a new entry
 */
/**
 *
 * This file is part of the APP(ideas) database abstraction project (AiDb).
 * Copyright 2013, APPideas
 *
 * AiDb is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * AiDb is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with AiDb (in the 'resources' directory). If not, see
 * <http://www.gnu.org/licenses/>.
 * http://appideas.com/abstract-your-database-introduction
 *
 */

#import <UIKit/UIKit.h>
#import "TestTable.h"

@interface AddDataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    /**
     * The incoming TestTable instance. This will have an ID of 0 for an addition
     */
    TestTable *testEntry;
}

@property (nonatomic, retain) TestTable *testEntry;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

/**
 * Save user input
 *
 * @returns     IBAction
 * @since		20131221
 * @author		costmo
 * @param		sender					The calling entity
 */
- (IBAction)saveAction:(id)sender;

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

/**
 * UITableViewDataSource delegate
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

/**
 * UITableViewDataSource delegate
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

/**
 * UITableViewDataSource delegate
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

/**
 * UITableViewDataSource delegate
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * UITableViewDataDelegate method
 */
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * UITableViewDataDelegate method
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

/**
 * Prepare data for view segue
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;


/**
 * Wrapper method so that we don't have tp repeat code for willSelectRowAtIndexPath and accessoryButtonTappedForRowWithIndexPath
 *
 * @since		20131221
 * @author		costmo
 * @param		indexPath					The tapped indexPath
 */
-(void)triggerSegueForIndexPath:(NSIndexPath *)indexPath;


@end
