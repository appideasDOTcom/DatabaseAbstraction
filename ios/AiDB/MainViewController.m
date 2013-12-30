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

#import "MainViewController.h"
#import "AddDataViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize allEntries, selectedId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self )
    {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.allEntries = [self getAllEntries:YES];
    [self.dataTableView deselectRowAtIndexPath:[self.dataTableView indexPathForSelectedRow] animated:YES];
    self.selectedId = 0;
    [self.dataTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource and UITableViewDelegate delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( [self.allEntries count] < 1 )
    {
        return 1;
    }
    else
    {
        return [self.allEntries count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
	}
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    // this should only happen when there are no entries, but we'll test the bounds just in case
    if( [self.allEntries count] == 0 || indexPath.row > [self.allEntries count] )
    {
        cell.textLabel.text = @"No entries were found";
        cell.detailTextLabel.text = @"Tap \"+\" to add a new entry";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        TestTable *currentEntry = [self.allEntries objectAtIndex:indexPath.row];
        cell.textLabel.text = currentEntry.strField;
        cell.detailTextLabel.text = currentEntry.readableTime;
    }
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [self.allEntries count] > 0 )
    {
        self.selectedId = [[self.allEntries objectAtIndex:indexPath.row] _id];
        [self triggerSegueForIndexPath:indexPath];
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if( [self.allEntries count] > 0 )
    {
        self.selectedId = [[self.allEntries objectAtIndex:indexPath.row] _id];
        [self triggerSegueForIndexPath:indexPath];
    }
}

-(void)triggerSegueForIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"gotoEdit" sender:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [self.allEntries count] == 0 )
    {
        return UITableViewCellEditingStyleNone;
    }
    else
    {
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        TestTable *entry = [self.allEntries objectAtIndex:indexPath.row];
        [TestTable deleteWithPrimaryKey:entry._id];
        self.allEntries = [self getAllEntries:YES];
        
        [self.dataTableView deselectRowAtIndexPath:[self.dataTableView indexPathForSelectedRow] animated:YES];
        
        // skip animation
        //[self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        [self.dataTableView reloadData];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // set the TestTable instance data prior to pushing the view
    if( [segue.identifier isEqualToString:@"gotoEdit"] )
    {
        AddDataViewController *advc = [segue destinationViewController];
        advc.testEntry = [[TestTable alloc] initWithId:self.selectedId];
    }
}

#pragma mark - App-specific methods for drawing the views

/**
 * Get all entries from test_table when needed
 */
-(NSMutableArray *)getAllEntries:(BOOL)forceRefresh
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:0];
    
    if( forceRefresh || self.allEntries == nil )
    {
        returnValue = [TestTable getAllEntries];
    }
    else
    {
        returnValue = self.allEntries;
    }
    
    return returnValue;
}

@end
