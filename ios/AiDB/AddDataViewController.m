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

#import "AddDataViewController.h"
#import "TestTable+Controller.h"
#import "EditDetailViewController.h"

@interface AddDataViewController ()

@end

@implementation AddDataViewController

@synthesize testEntry;

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
    [super viewWillAppear:animated];
    [self.dataTableView deselectRowAtIndexPath:[self.dataTableView indexPathForSelectedRow] animated:YES];
    
    // if we don't have a test entry, open with a "0" record
    if( self.testEntry == nil )
    {
        self.testEntry = [[TestTable alloc] initWithId:0];
    }
    [self.dataTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource and UITableViewDelegate delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch( section )
    {
        case 0:
            return @"id";
            break;
        case 1:
            return @"str";
            break;
        case 2:
            return @"int";
            break;
        case 3:
            return @"bool";
            break;
        case 4:
            return @"float";
            break;
        case 5:
            return @"time";
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EntryCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EntryCell"];
	}
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor whiteColor];
    
    // override behavior of cells that are not editable
    // also set text for each cell
    switch( indexPath.section )
    {
        case 0:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = [NSString stringWithFormat:@"%li", (long)testEntry._id];
            break;
        case 1:
            cell.textLabel.text = testEntry.strField;
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"%li", (long)testEntry.intField];
            break;
        case 3:
            cell.textLabel.text = (testEntry.boolField) ? @"YES" : @"NO";
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"%0.2f", testEntry.floatField];
            break;
        case 5:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = testEntry.readableTime;
            break;
        default:
            cell.textLabel.text = @"";
            break;
    }
    
    
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self triggerSegueForIndexPath:indexPath];

    return indexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self triggerSegueForIndexPath:indexPath];
}

-(void)triggerSegueForIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section != 0 && indexPath.section != 5 )
    {
        [self performSegueWithIdentifier:@"gotoEditDetail" sender:indexPath];
    }
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"gotoEditDetail"] )
    {
        EditDetailViewController *edvc = [segue destinationViewController];
        edvc.caller = self;
        
        NSIndexPath *indexPath = sender;
        
        switch( indexPath.section )
        {
            case 1:
                edvc.field = @"strField";
                break;
            case 2:
                edvc.field = @"intField";
                break;
            case 3:
                edvc.field = @"boolField";
                break;
            case 4:
                edvc.field = @"floatField";
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - App-specific code

- (IBAction)saveAction:(id)sender
{
    NSString *result = [self.testEntry checkInput];
    
    // input passed checks
    if( [result isEqualToString:@"ok"] )
    {
        [self.testEntry save];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else // input did not pass checks
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:result delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}
@end
