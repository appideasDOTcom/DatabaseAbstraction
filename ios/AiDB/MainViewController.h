/**
 * The view controller that activates on app launch
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

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    /**
     * A holding place for a list of all entries in the test_table
     */
    NSMutableArray *allEntries;
    
    /**
     * Store boundaries of cells for drawing
     */
    CGRect cellBounds;
    
    /**
     * The ID of the selected entity
     */
    NSInteger selectedId;
}

@property (nonatomic, retain) NSMutableArray *allEntries;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (nonatomic, assign) NSInteger selectedId;

/**
 * A wrapper to TestTable->getAllEntries
 *
 * @returns		An array of results TestTable instances
 * @since		20131221
 * @author		costmo
 * @param		forceRefresh					If set to YES, will refresh contents no matter what. If NO, will only get the list if it is nil
 */
-(NSMutableArray *)getAllEntries:(BOOL)forceRefresh;

/**
 * UIViewController subclass override
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

/**
 * UIViewController subclass override
 */
- (void)viewDidLoad;

/**
 * UIViewController subclass override
 */
- (void)viewWillAppear:(BOOL)animated;

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
 * UITableViewDelegate method
 */
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * UITableViewDelegate method
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

/**
 * UITableViewDelegate method
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Prepare data for view segue
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;



@end
