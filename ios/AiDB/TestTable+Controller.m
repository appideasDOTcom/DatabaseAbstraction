/**
 *  The Controller for test_table logic. Extends ("is a category of", in Objective-C lingo) TestTable
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

#import "TestTable+Controller.h"

@implementation TestTable (Controller)

/**
 * Check user input.
 *
 * NSString *result = [currentInstance checkInput];
 * if( [result isEqualToString:@"ok"] )...
 */
-(NSString *)checkInput;
{
    NSString *returnValue = @"ok";
   
    // Make sure the input string is not empty
    if( [self.strField length] < 1 )
    {
        returnValue = @"Input string must not be blank.";
    }
    
    // If the primary key is not 0, make sure it exists in the database
    if( self._id != 0 )
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) as count FROM test_table WHERE %@ = %li", _idField, (long)self._id];
        NSMutableArray *result = [db query:sql];
        NSMutableDictionary *record = [result objectAtIndex:0];
        NSInteger count = [[record objectForKey:@"count"] integerValue];
        
        if( count < 1 )
        {
            returnValue = @"The ID (primary key) is not valid and this record cannot be saved.";
        }
    }
    
    return returnValue;
}

@end
