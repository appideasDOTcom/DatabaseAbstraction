/**
 * Test case for AiDatabase class
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

#import <XCTest/XCTest.h>
#import "AiDatabase.h"

@interface AiDatabaseTests : XCTestCase
{
    AiDatabase *db;
    NSString *failureMsg;
}

@property (nonatomic, retain) AiDatabase *db;
@property (nonatomic, retain) NSString *failureMsg;

@end

@implementation AiDatabaseTests

@synthesize db, failureMsg;

- (void)setUp
{
    [super setUp];
    
    self.db = [[AiDatabase alloc] init];
    self.failureMsg = @"AiDatabaseTests failed with message:";
}

- (void)tearDown
{
    // empty test_table after each test method
    [db noReturnQuery:@"DELETE FROM test_table"];
    [super tearDown];
}

// Test initializing an AiDatabae object and its members
- (void)test_init
{
    NSString *condition = [NSString stringWithFormat:@"db was kindOfClass %@, but %@ was expected", [self.db class], [AiDatabase class]];
    XCTAssertTrue( [self.db isKindOfClass:[AiDatabase class]], @"%@ %@", self.failureMsg, condition );
    condition = [NSString stringWithFormat:@"Got row count of %li, but expected 0", (long)self.db.rowCount];
    XCTAssertTrue( self.db.rowCount == 0, @"%@ %@", self.failureMsg, condition );
    condition = [NSString stringWithFormat:@"Got column count of %li, but expected 0", (long)self.db.columnCount];
    XCTAssertTrue( self.db.columnCount == 0, @"%@ %@", self.failureMsg, condition );
}

// Test inserting a blank record into a table
- (void)test_insertBlankIntoTable
{
    // Make sure we got a non-zero ID
    NSInteger idValue = [db insertBlankIntoTable:@"test_table" withIdField:_idField];
    NSString *condition = [NSString stringWithFormat:@"idValue was %li", (long)idValue];
    XCTAssertTrue( (idValue > 0), @"%@ %@", self.failureMsg, condition );
    
    // Make sure we can get the number of records in the table
    NSMutableArray *result = [db query:@"SELECT COUNT(*) as count FROM test_table"];
    condition = [NSString stringWithFormat:@"result count was %lu", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    // Make sure there is only one record in the table
    NSMutableDictionary *record = [result objectAtIndex:0];
    NSInteger count = [[record objectForKey:@"count"] integerValue];
    condition = [NSString stringWithFormat:@"SELECT result was %li", (long)count];
    XCTAssertTrue( (count == 1), @"%@ %@", self.failureMsg, condition );
    
    // make sure that record has the inserted ID
    // Make sure we can get the number of records in the table
    result = [db query:[NSString stringWithFormat:@"SELECT %@ FROM test_table", _idField]];
    condition = [NSString stringWithFormat:@"Second result count was %lu", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    record = [result objectAtIndex:0];
    NSInteger queriedId = [[record objectForKey:_idField] integerValue];
    condition = [NSString stringWithFormat:@"inserted ID was %li, queried ID was %li", (long)idValue, (long)queriedId];
    XCTAssertTrue( (idValue == queriedId), @"%@ %@", self.failureMsg, condition );
}

// test the noReturnQuery and getLastIdFromTable methods. This is a subset of the first method to test the query method.
- (void)test_getLastIdFromTable_noReturnQuery
{
    // setup query input as variables for conparison after insert
    NSInteger intValue = 9;
    NSString *strValue = @"A string";
    NSInteger boolValue = 1;
    NSInteger timeValue = [AiDatabase getCurrentTimestamp];
    float floatValue = 4.2;
    
    NSString *sql = [NSString stringWithFormat:@"\
                     INSERT \
                     INTO    test_table \
                     ( id, int_field, str_field, bool_field, time_field, float_field ) \
                     VALUES  ( NULL, %li, '%@', %li, %li, %0.1f ) \
                     ", (long)intValue, strValue, (long)boolValue, (long)timeValue, floatValue];
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    NSString *condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, int_field, str_field, bool_field, time_field, float_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
}

// test the getLastIdFromTable method when there are no records in the table
- (void)test_getLastIdFromTableZero
{
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    
    NSString *condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId == 0), @"%@ %@", self.failureMsg, condition );
}

// test the query method
- (void)test_query
{
    // setup query input as variables for conparison after insert
    NSInteger intValue = 9;
    NSString *strValue = @"A string";
    NSInteger boolValue = 1;
    NSInteger timeValue = [AiDatabase getCurrentTimestamp];
    float floatValue = 4.2;
    
    NSString *sql = [NSString stringWithFormat:@"\
        INSERT \
        INTO    test_table \
                ( id, int_field, str_field, bool_field, time_field, float_field ) \
        VALUES  ( NULL, %li, '%@', %li, %li, %0.1f ) \
    ", (long)intValue, strValue, (long)boolValue, (long)timeValue, floatValue];
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    NSString *condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, int_field, str_field, bool_field, time_field, float_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"int_field was %i, expected %li", [[row objectForKey:@"int_field"] intValue], (long)intValue ];
    XCTAssertTrue( ([[row objectForKey:@"int_field"] intValue] == intValue), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was %@, expected %@", [row objectForKey:@"str_field"], strValue ];
    XCTAssertTrue( ([[row objectForKey:@"str_field"] isEqualToString:strValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"bool_field was %i, expected %li", [[row objectForKey:@"bool_field"] intValue], (long)boolValue ];
    XCTAssertTrue( ([[row objectForKey:@"bool_field"] intValue] == boolValue), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"time_field was %i, expected %li", [[row objectForKey:@"time_field"] intValue], (long)timeValue ];
    XCTAssertTrue( ([[row objectForKey:@"time_field"] intValue] == timeValue), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"time_field was %i, expected %li", [[row objectForKey:@"time_field"] intValue], (long)timeValue ];
    XCTAssertTrue( ([[row objectForKey:@"time_field"] intValue] == timeValue), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"float_field was %0.2f, expected %0.2f", [[row objectForKey:@"float_field"] floatValue], floatValue ];
    XCTAssertTrue( ([[row objectForKey:@"float_field"] floatValue] == floatValue), @"%@ %@", self.failureMsg, condition );
}

// test the query method with a NULL value to make sure it returns the right kind of object
- (void)test_queryNull
{
    NSString *sql = @"SELECT MAX( int_field ) as queryInt FROM test_table";

    NSMutableArray *result = [db query:sql];
    NSString *condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"return value was %@, expected empty string", [row objectForKey:@"queryInt"] ];
    XCTAssertTrue( ([[row objectForKey:@"queryInt"] isEqualToString:@""]), @"%@ %@", self.failureMsg, condition );
}

// test the query method with no results
- (void)test_queryEmpty
{
    NSString *sql = @"SELECT * FROM test_table";
    
    NSMutableArray *result = [db query:sql];
    NSString *condition = [NSString stringWithFormat:@"result count was %lu, expected 0", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 0), @"%@ %@", self.failureMsg, condition );
}

// test the query method
- (void)test_escapeString
{
    // setup query input as variables for conparison after insert
    NSString *strValue = @"A 'new' \"escaped\" string";
    
    NSString *sql = [NSString stringWithFormat:@"\
                     INSERT \
                     INTO    test_table \
                     ( id, str_field ) \
                     VALUES  ( NULL, '%@' ) \
                     ", [AiDatabase escapeString:strValue] ];
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    NSString *condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, str_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was %@, expected %@", [row objectForKey:@"str_field"], strValue ];
    XCTAssertTrue( ([[row objectForKey:@"str_field"] isEqualToString:strValue]), @"%@ %@", self.failureMsg, condition );
}

// test the numRows method
- (void)test_numRows
{
    NSInteger idOne = [db insertBlankIntoTable:@"test_table" withIdField:_idField];
    NSInteger idTwo = [db insertBlankIntoTable:@"test_table" withIdField:_idField];
    
    
    NSString *condition = [NSString stringWithFormat:@"idOne was %li, expected > 0", (long)idOne];
    XCTAssertTrue( (idOne > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"idTwo was %li, expected > 0", (long)idTwo];
    XCTAssertTrue( (idTwo > 0), @"%@ %@", self.failureMsg, condition );
    
    NSString *sql = @"SELECT id FROM test_table";
    [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %li, expected 2", (long)[db numRows]];
    XCTAssertTrue( ([db numRows] == 2), @"%@ %@", self.failureMsg, condition );
}

// test the numRows method
- (void)test_numFields
{
    NSInteger newId = [db insertBlankIntoTable:@"test_table" withIdField:_idField];
    
    NSString *condition = [NSString stringWithFormat:@"idOne was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    NSString *sql = @"SELECT id, int_field, str_field, bool_field FROM test_table";
    [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %li, expected 4", (long)[db numFields]];
    XCTAssertTrue( ([db numFields] == 4), @"%@ %@", self.failureMsg, condition );
}

// test the fixBoolean method that should return NO
- (void)test_fixBooleanFalse
{
    BOOL value = [AiDatabase fixBoolean:0];
    
    NSString *condition = [NSString stringWithFormat:@"value was %@, expected NO", (value) ? @"YES" : @"NO"];
    XCTAssertFalse( value, @"%@ %@", self.failureMsg, condition );
    
    // test writing to and reading from the database
    NSString *sql = @"\
                     INSERT \
                     INTO    test_table \
                     ( id, bool_field ) \
                     VALUES  ( NULL, 0 ) \
                     ";
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, bool_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    BOOL returnValue = [AiDatabase fixBoolean:[[row objectForKey:@"bool_field"] intValue]];
    condition = [NSString stringWithFormat:@"bool_field was %@, expected NO", (returnValue) ? @"YES" : @"NO" ];
    XCTAssertFalse( returnValue, @"%@ %@", self.failureMsg, condition );
}

// test the fixBoolean method that should return YES for several different input values
- (void)test_fixBooleanTrue
{
    BOOL value = [AiDatabase fixBoolean:1];
    NSString *condition = [NSString stringWithFormat:@"value was %@, expected YES", (value) ? @"YES" : @"NO"];
    XCTAssertTrue( value, @"%@ %@", self.failureMsg, condition );
    
    value = [AiDatabase fixBoolean:2];
    condition = [NSString stringWithFormat:@"value was %@, expected YES", (value) ? @"YES" : @"NO"];
    XCTAssertTrue( value, @"%@ %@", self.failureMsg, condition );
    
    value = [AiDatabase fixBoolean:-1];
    condition = [NSString stringWithFormat:@"value was %@, expected YES", (value) ? @"YES" : @"NO"];
    XCTAssertTrue( value, @"%@ %@", self.failureMsg, condition );
    
    // test writing to and reading from the database
    NSString *sql = @"\
                    INSERT \
                    INTO    test_table \
                    ( id, bool_field ) \
                    VALUES  ( NULL, 1 ) \
                    ";
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, bool_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    BOOL returnValue = [AiDatabase fixBoolean:[[row objectForKey:@"bool_field"] intValue]];
    condition = [NSString stringWithFormat:@"bool_field was %@, expected YES", (returnValue) ? @"YES" : @"NO" ];
    XCTAssertTrue( returnValue, @"%@ %@", self.failureMsg, condition );

}

// test the fixDbBoolean method that should return 0
- (void)test_fixDbBooleanFalse
{
    NSInteger value = [AiDatabase fixDbBoolean:NO];
    
    NSString *condition = [NSString stringWithFormat:@"value was %li, expected 0", (long)value];
    XCTAssertTrue( (value == 0), @"%@ %@", self.failureMsg, condition );
    
    // test writing to and reading from the database
    NSString *sql = [NSString stringWithFormat:@"\
                     INSERT \
                     INTO    test_table \
                     ( id, bool_field ) \
                     VALUES  ( NULL, %li ) \
                     ", (long)[AiDatabase fixDbBoolean:NO]];
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, bool_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"bool_field was %i, expected 0", [[row objectForKey:@"bool_field"] intValue] ];
    XCTAssertTrue( ([[row objectForKey:@"bool_field"] intValue] == 0), @"%@ %@", self.failureMsg, condition );
}

// test the fixDbBoolean method that should return 1
- (void)test_fixDbBooleanTrue
{
    NSInteger value = [AiDatabase fixDbBoolean:YES];
    
    NSString *condition = [NSString stringWithFormat:@"value was %li, expected 1", (long)value];
    XCTAssertTrue( (value == 1), @"%@ %@", self.failureMsg, condition );
    
    // test writing to and reading from the database
    NSString *sql = [NSString stringWithFormat:@"\
                     INSERT \
                     INTO    test_table \
                     ( id, bool_field ) \
                     VALUES  ( NULL, %li ) \
                     ", (long)[AiDatabase fixDbBoolean:YES]];
    
    [db beginTransaction];
    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, bool_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"bool_field was %i, expected 1", [[row objectForKey:@"bool_field"] intValue] ];
    XCTAssertTrue( ([[row objectForKey:@"bool_field"] intValue] == 1), @"%@ %@", self.failureMsg, condition );
}

// test the getCurrentTimestamp method. This is a bit of circular reasoning since we get the timestamp to test against using the same mechanism used by the method itself.
- (void)test_getCurrentTimestamp
{
    NSDate *currentDate = [NSDate date];
	NSTimeInterval epochTime = [currentDate timeIntervalSince1970];
	NSInteger currentValue = (int)epochTime;
    
    // allow +/- 2 seconds from initial population of variable to time fo grabbing from the class
    NSInteger min = currentValue - 2;
    NSInteger max = currentValue + 2;
    
    NSInteger retrievedValue = [AiDatabase getCurrentTimestamp];
    
    NSString *condition = [NSString stringWithFormat:@"value was %li, expected %li", (long)retrievedValue, (long)currentValue];
    XCTAssertTrue( (retrievedValue >= min && retrievedValue <= max), @"%@ %@", self.failureMsg, condition );
}

// test the getCurrentTimestamp method. This is a bit of circular reasoning since we get the timestamp to test against using the same mechanism used by the method itself.
- (void)test_blockInjection
{
    NSString *input = @"A string; with some things";
    NSString *expected = @"A string with some things";
    
    // test writing to and reading from the database
    NSString *sql = [NSString stringWithFormat:@"\
                     INSERT \
                     INTO    test_table \
                     ( id, str_field ) \
                     VALUES  ( NULL, '%@' ) \
                     ", [AiDatabase blockInjection:input]];
    [db beginTransaction];

    // INSERT can/should be handled with noReturnQuery
    [db noReturnQuery:sql];
    NSInteger newId = [db getLastIdFromTable:@"test_table" withIdField:_idField];
    [db endTransaction];
    
    NSString *condition = [NSString stringWithFormat:@"newId was %li, expected > 0", (long)newId];
    XCTAssertTrue( (newId > 0), @"%@ %@", self.failureMsg, condition );
    
    sql = [NSString stringWithFormat:@"SELECT id, str_field FROM test_table WHERE %@ = %li", _idField, (long)newId];
    NSMutableArray *result = [db query:sql];
    condition = [NSString stringWithFormat:@"result count was %lu, expected 1", (unsigned long)[result count]];
    XCTAssertTrue( ([result count] == 1), @"%@ %@", self.failureMsg, condition );
    
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"id was %i, expected %li", [[row objectForKey:_idField] intValue], (long)newId ];
    XCTAssertTrue( ([[row objectForKey:_idField] intValue] == newId), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was %@, expected %@", [row objectForKey:@"str_field"], expected ];
    XCTAssertTrue( ([[row objectForKey:@"str_field"] isEqualToString:expected]), @"%@ %@", self.failureMsg, condition );
}

// test the getDbPath method.
- (void)test_getDbPath
{
    NSString *dbPath = [AiDatabase getDbPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    NSString *condition = [NSString stringWithFormat:@"File was not found at path %@", dbPath];
    XCTAssertTrue( success, @"%@ %@", self.failureMsg, condition );
}

// test the getCurrentVersion method when there are versions recorded
- (void)test_getCurrentVersion
{
    NSInteger version = [db getCurrentVersion];
    NSString *condition = [NSString stringWithFormat:@"Got version %li but expected >= 2", (long)version];
    XCTAssertTrue( (version >= 2), @"%@ %@", self.failureMsg, condition );
}

// getMaxUpdateVersion's behavior when there are no update files can't be tested because we can't remove files from the app bundle

// test the getMaxUpdateVersion method when there are versions recorded
- (void)test_getMaxUpdateVersion
{
    NSInteger version = [db getMaxUpdateVersion];
    NSString *condition = [NSString stringWithFormat:@"Got version %li but expected >= 2", (long)version];
    XCTAssertTrue( (version >= 2), @"%@ %@", self.failureMsg, condition );
}

// make sure recordSchemaVersion updates the timestamp when the version number already exists instead of duplicating.
// This assumes a current schema version number of at least 2
- (void)test_recordSchemaVersionDuplicate
{
    NSString *sql = @"SELECT COUNT(*) AS count FROM schema_versions WHERE version_number = 2";
    NSMutableArray *result = [db query:sql];
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    // make sure that we have one record with version number 2 before continuing
    NSString *condition = [NSString stringWithFormat:@"Got version count %li but expected 1", (long)[[row objectForKey:@"count"] integerValue]];
    XCTAssertTrue( ([[row objectForKey:@"count"] integerValue] == 1), @"%@ %@", self.failureMsg, condition );
    
    // get the updated timestamp for later comparison
    sql = @"SELECT update_time FROM schema_versions WHERE version_number = 2";
    result = [db query:sql];
    row = [result objectAtIndex:0];
    NSInteger originalTime = [[row objectForKey:@"update_time"] integerValue];
    condition = [NSString stringWithFormat:@"Got original time %li but expected > 0", (long)originalTime];
    XCTAssertTrue( (originalTime > 0), @"%@ %@", self.failureMsg, condition );
    
    // record a new schema version
    [db recordSchemaVersion:2];
    
    sql = @"SELECT COUNT(*) AS count FROM schema_versions WHERE version_number = 2";
    result = [db query:sql];
    row = [result objectAtIndex:0];
    
    condition = [NSString stringWithFormat:@"Got version count %li but expected 1", (long)[[row objectForKey:@"count"] integerValue]];
    XCTAssertTrue( ([[row objectForKey:@"count"] integerValue] == 1), @"%@ %@", self.failureMsg, condition );
    
    // during tests, these times may get updated more than once, so we will allow a new time that is >= the original
    sql = @"SELECT update_time FROM schema_versions WHERE version_number = 2";
    result = [db query:sql];
    row = [result objectAtIndex:0];
    NSInteger updatedTime = [[row objectForKey:@"update_time"] integerValue];
    condition = [NSString stringWithFormat:@"Got updated time %li but it was not >= %li", (long)updatedTime, (long)originalTime];
    XCTAssertTrue( (updatedTime >= originalTime), @"%@ %@", self.failureMsg, condition );
}

// test recordSchemaVersion
- (void)test_recordSchemaVersion
{
    NSInteger current = [db getCurrentVersion];
    NSString *condition = [NSString stringWithFormat:@"Got version %li but expected >= 2", (long)current];
    XCTAssertTrue( (current >= 2), @"%@ %@", self.failureMsg, condition );
    
    NSInteger newVersion = current + 1;
    [db recordSchemaVersion:newVersion];
    
    NSInteger newCurrent = [db getCurrentVersion];
    condition = [NSString stringWithFormat:@"Got version %li but expected %li", (long)newCurrent, (long)newVersion];
    XCTAssertTrue( (newCurrent == newVersion), @"%@ %@", self.failureMsg, condition );
    
    // remove the new fake version from the versions table
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM schema_versions WHERE version_number = %li", (long)newCurrent];
    [db noReturnQuery:sql];
    
    NSInteger finalCurrent = [db getCurrentVersion];
    condition = [NSString stringWithFormat:@"Got final version %li but expected %li", (long)finalCurrent, (long)current];
    XCTAssertTrue( (newCurrent == newVersion), @"%@ %@", self.failureMsg, condition );
}

// updateFromCurrentVersion's behavior when there is an update file can't be tested because we can't insert files into the app bundle

// test updateFromCurrentVersion with same version, lesser version and a version without an upgrade file to make sure it doesn't perform an update
- (void)test_updateFromCurrentVersionInvalidVersions
{
    NSInteger currentVersion = [db getCurrentVersion];
    NSString *condition = [NSString stringWithFormat:@"Got version %li but expected >= 2", (long)currentVersion];
    XCTAssertTrue( (currentVersion >= 2), @"%@ %@", self.failureMsg, condition );
    
    // check a "new" version in the past
    NSInteger previousVersion = currentVersion - 1;
    [db updateFromCurrentVersion:currentVersion toMaxVersion:previousVersion];
    NSInteger checkVersion = [db getCurrentVersion];
    condition = [NSString stringWithFormat:@"Got version %li but expected %li", (long)checkVersion, (long)currentVersion];
    XCTAssertTrue( (checkVersion == currentVersion), @"%@ %@", self.failureMsg, condition );
    
    // check a new version that is the same as the current
    [db updateFromCurrentVersion:currentVersion toMaxVersion:currentVersion];
    checkVersion = [db getCurrentVersion];
    condition = [NSString stringWithFormat:@"Got version %li but expected %li", (long)checkVersion, (long)currentVersion];
    XCTAssertTrue( (checkVersion == currentVersion), @"%@ %@", self.failureMsg, condition );
    
    // check a new version that is missing its sql file
    NSInteger nextVersion = currentVersion + 2;
    [db updateFromCurrentVersion:currentVersion toMaxVersion:nextVersion];
    checkVersion = [db getCurrentVersion];
    condition = [NSString stringWithFormat:@"Got version %li but expected %li", (long)checkVersion, (long)currentVersion];
    XCTAssertTrue( (checkVersion == currentVersion), @"%@ %@", self.failureMsg, condition );
}

// tests the doUpgrade method, which shouldn't have any net result. See comment below for tests of doUpgrade.
- (void)test_doUpgrade
{
    NSInteger currentVersion = [db getCurrentVersion];
    NSString *condition = [NSString stringWithFormat:@"Got version %li but expected >= 2", (long)currentVersion];
    XCTAssertTrue( (currentVersion >= 2), @"%@ %@", self.failureMsg, condition );
    
    [db doUpgrade];
    
    NSInteger checkVersion = [db getCurrentVersion];
    condition = [NSString stringWithFormat:@"Got version %li but expected %li", (long)checkVersion, (long)currentVersion];
    XCTAssertTrue( (checkVersion == currentVersion), @"%@ %@", self.failureMsg, condition );
}

/**
 * Tests below here are desctructive. They will delete and recreate your database for testing purposes.
 * For an in-production app, if you want to retain the default tests as well as your in-device database,
 *   you should comment out everything below here.
 *
 * Tests below here also verify that doUpgrade is functional or else other tests following these would fail.
 *  Plus the methods called by duUpgrade are tested separately throughout this test suite
 */

// test the getDbPath method.
- (void)test_createDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbFile = [AiDatabase getDbPath];
    
    // delete the file path to make sure it gets recreated
    NSString *dbDirectory = [dbFile stringByDeletingLastPathComponent];
    [fileManager removeItemAtPath:dbDirectory error:nil];
    
    BOOL success = [fileManager fileExistsAtPath:dbDirectory];
    
    NSString *condition = [NSString stringWithFormat:@"Directory was found at path %@ but should have been deleted", dbDirectory];
    XCTAssertFalse( success, @"%@ %@", self.failureMsg, condition );
    
    [AiDatabase createDatabase];
    
    [fileManager removeItemAtPath:dbFile error:nil];
    
    success = [fileManager fileExistsAtPath:dbDirectory];
    condition = [NSString stringWithFormat:@"Directory was not found at path %@ but should be present", dbDirectory];
    XCTAssertTrue( success, @"%@ %@", self.failureMsg, condition );
    
    success = [fileManager fileExistsAtPath:dbFile];
    condition = [NSString stringWithFormat:@"File was found at path %@ but should have been deleted", dbFile];
    XCTAssertFalse( success, @"%@ %@", self.failureMsg, condition );
    
    [AiDatabase createDatabase];
    
    // get the inode number database file to make sure it doesn't get replaced when it already exists
    NSDictionary* fileAttributesBefore = [fileManager attributesOfItemAtPath:dbFile error:nil];
    NSUInteger numberBefore = [fileAttributesBefore fileSystemFileNumber]; // file's inode number
    
    [AiDatabase createDatabase];
    
    NSDictionary* fileAttributesAfter = [fileManager attributesOfItemAtPath:dbFile error:nil];
    NSUInteger numberAfter = [fileAttributesAfter fileSystemFileNumber]; // file's inode number
    
    condition = [NSString stringWithFormat:@"File was recreated, but should not have been" ];
    XCTAssertTrue( (numberBefore == numberAfter), @"%@ %@", self.failureMsg, condition );
    
    // perform known updates so that other tests will pass
    [db doUpgrade];
}

// test the getCurrentVersion method when there are no versions recorded
- (void)test_getCurrentVersionZero
{
    NSString *sql = @"DELETE FROM schema_versions";
    [db noReturnQuery:sql];
    
    NSInteger version = [db getCurrentVersion];
    NSString *condition = [NSString stringWithFormat:@"Got version %li but expected 0", (long)version];
    XCTAssertTrue( (version == 0), @"%@ %@", self.failureMsg, condition );
    
    // perform known updates so that other tests will pass
    [db doUpgrade];
}

@end
