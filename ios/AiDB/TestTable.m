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

#import "AiDatabase.h"
#import "AiUtil.h"
#import "TestTable.h"

@implementation TestTable

@synthesize _id, intField, strField, boolField, timeField, readableTime, floatField, db;

/**
 * Initialize using the primary key
 *
 * TestTable *myData = [[TestTable alloc] initWithId:3];
 */
-(id)initWithId:(NSInteger)primaryKey
{
    self.db = [[AiDatabase alloc] init];
    
    NSMutableDictionary *row = [[NSMutableDictionary alloc] initWithCapacity:6];
    
    if( [TestTable isValidId:primaryKey] )
    {
        NSString *sql = [NSString stringWithFormat:@"SELECT id, int_field, str_field, bool_field, time_field, float_field FROM test_table WHERE %@ = %li", _idField, (long)primaryKey];
        NSMutableArray *result = [self.db query:sql];
        row = [result objectAtIndex:0];
    }
    else // the primary key was not valid
    {
        row = [TestTable getDefaultValues];
    }
    
    self._id = [[row objectForKey:@"id"] integerValue];
    self.intField = [[row objectForKey:@"int_field"] integerValue];
    self.strField = [row objectForKey:@"str_field"];
    self.boolField = [AiDatabase fixBoolean:[[row objectForKey:@"bool_field"] integerValue]];
    self.timeField = [[row objectForKey:@"time_field"] integerValue];
    self.readableTime = [AiUtil readableDateFromEpoch:[[row objectForKey:@"time_field"] integerValue] withFormat:_usLongDateTimeNiceFormat];
    self.floatField = [[row objectForKey:@"float_field"] floatValue];
    
    return self;
}

/**
 * Get an array of all entries from the table
 *
 * NSMutableArray *entries = [TestTable getAllEntries];
 * TestTable *entry = [entries objectAtIndex:0];
 * NSString *showString = entry.strField;
 */
+(NSMutableArray *)getAllEntries
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:0];
    
    AiDatabase *db = [[AiDatabase alloc] init];
    
    NSString *sql = @"SELECT id FROM test_table ORDER BY time_field DESC";
    NSMutableArray *result = [db query:sql];
    for( NSInteger i = 0; i < [result count]; i++ )
    {
        NSMutableDictionary *row = [result objectAtIndex:i];
        TestTable *currentItem = [[TestTable alloc] initWithId:[[row objectForKey:@"id"] integerValue]];
        [returnValue insertObject:currentItem atIndex:i];
    }
   
    return returnValue;
}

/**
 * Get default values in case the record is not found
 *
 * NSMutableDictionary *defaultValues = [TestTable getDefaultValues];
 * NSString *defaultString = [defaultValues objectForKey:@"strField"];
 */
+(NSMutableDictionary *)getDefaultValues
{
    NSMutableDictionary *returnValue = [[NSMutableDictionary alloc] initWithCapacity:6];
    [returnValue setObject:[NSNumber numberWithInt:0] forKey:@"id"];
    [returnValue setObject:[NSNumber numberWithInt:0] forKey:@"int_field"];
    [returnValue setObject:@"" forKey:@"str_field"];
    [returnValue setObject:[NSNumber numberWithInt:0] forKey:@"bool_field"];
    [returnValue setObject:[NSNumber numberWithInt:0] forKey:@"time_field"];
    [returnValue setObject:[NSNumber numberWithFloat:0.0] forKey:@"float_field"];
    
    return returnValue;
}

/**
 * Verify that the ID is an object in the database
 *
 * BOOL isValid = [TestTable isValidId:3];
 */
+(BOOL)isValidId:(NSInteger)primaryKey
{
    BOOL returnValue = NO;
    
    AiDatabase *db = [[AiDatabase alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS count FROM test_table WHERE %@ = %li", _idField, (long)primaryKey];
    NSMutableArray *result = [db query:sql];
    NSMutableDictionary *row = [result objectAtIndex:0];
    if( [[row objectForKey:@"count"] integerValue] > 0 )
    {
        returnValue = YES;
    }
    
    return returnValue;
}

/**
 * Save member varoable values into the database
 *
 * [currentInstance save];
 */
-(void)save
{
    // This is a new entry, make a place for it
    if( self._id < 1 )
    {
        self._id = [self.db insertBlankIntoTable:@"test_table" withIdField:_idField];
    }
    
    NSString *sql = [NSString stringWithFormat:@"\
                     UPDATE test_table \
                     SET    int_field = %li, \
                            str_field = '%@', \
                            bool_field = %li, \
                            time_field = %li, \
                            float_field = %0.2f \
                     WHERE  %@ = %li",
                     (long)self.intField, [AiDatabase escapeString:self.strField],
                     (long)[AiDatabase fixDbBoolean:self.boolField], (long)[AiDatabase getCurrentTimestamp],
                     self.floatField, _idField, (long)self._id];
    
    [self.db noReturnQuery:sql];
}

/**
 * Remove an entry from the table
 */
+(void)deleteWithPrimaryKey:(NSInteger)primaryKey
{
    AiDatabase *db = [[AiDatabase alloc] init];
    
    NSString *sql = [NSString stringWithFormat:@"\
                     DELETE \
                     FROM   test_table \
                     WHERE  %@ = %li",
                     _idField, (long)primaryKey];
    
    [db noReturnQuery:sql];
}

@end
