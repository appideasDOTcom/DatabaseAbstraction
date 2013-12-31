/**
 * Test case for TestTable class for the sample app
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
#import "TestTable+Controller.h"

@interface TestTableTests : XCTestCase
{
    AiDatabase *db;
    NSString *failureMsg;
}

@property (nonatomic, retain) AiDatabase *db;
@property (nonatomic, retain) NSString *failureMsg;

/**
 * Create an empty instance and populate it with default values for saving and comparison
 */
- (TestTable *)getPopulatedInstance;

@end

@implementation TestTableTests

@synthesize db, failureMsg;

- (void)setUp
{
    self.db = [[AiDatabase alloc] init];
    self.failureMsg = @"TestTableTests failed with message:";
    [super setUp];
}

- (void)tearDown
{
    // empty test_table after each test method
    [db noReturnQuery:@"DELETE FROM test_table"];
    [super tearDown];
}

// Test initializing an TestTable object with 0 as the primary key
- (void)test_initZero
{
    NSMutableDictionary *defaults = [TestTable getDefaultValues];
    TestTable *tt = [[TestTable alloc] initWithId:0];
    
    NSString *condition = [NSString stringWithFormat:@"TestTable was kindOfClass %@, but %@ was expected", [tt class], [TestTable class]];
    XCTAssertTrue( [tt isKindOfClass:[TestTable class]], @"%@ %@", self.failureMsg, condition );
    
    // make sure all values are the same as what is in the defaults
    condition = [NSString stringWithFormat:@"id was %li, expected %li", (long)tt._id, (long)[[defaults objectForKey:@"id"] integerValue]];
    XCTAssertTrue( (tt._id == [[defaults objectForKey:@"id"] integerValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"int_field was %li, expected %li", (long)tt.intField, (long)[[defaults objectForKey:@"int_field"] integerValue]];
    XCTAssertTrue( (tt.intField == [[defaults objectForKey:@"int_field"] integerValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was '%@', expected '%@'", tt.strField, [defaults objectForKey:@"str_field"]];
    XCTAssertTrue( ([tt.strField isEqualToString:[defaults objectForKey:@"str_field"]]), @"%@ %@", self.failureMsg, condition );
    
    // make this one easier to understand
    BOOL defaultAsBool = [AiDatabase fixBoolean:[[defaults objectForKey:@"bool_field"] integerValue]];
    condition = [NSString stringWithFormat:@"bool_field was %@, expected %@", (tt.boolField) ? @"YES" : @"NO", (defaultAsBool) ? @"YES" : @"NO" ];
    XCTAssertTrue( (tt.boolField == defaultAsBool), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"time_field was %li, expected %li", (long)tt.timeField, (long)[[defaults objectForKey:@"time_field"] integerValue]];
    XCTAssertTrue( (tt.timeField == [[defaults objectForKey:@"time_field"] integerValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"float_field was %0.2f, expected %0.2f", tt.floatField, [[defaults objectForKey:@"float_field"] floatValue]];
    XCTAssertTrue( (tt.floatField == [[defaults objectForKey:@"float_field"] floatValue]), @"%@ %@", self.failureMsg, condition );
}

// Test initializing an TestTable object with a known invalid primary key. This should produce the same results as test_initZero
- (void)test_initInvalidKey
{
    NSMutableDictionary *defaults = [TestTable getDefaultValues];
    TestTable *tt = [[TestTable alloc] initWithId:-1];
    
    NSString *condition = [NSString stringWithFormat:@"TestTable was kindOfClass %@, but %@ was expected", [tt class], [TestTable class]];
    XCTAssertTrue( [tt isKindOfClass:[TestTable class]], @"%@ %@", self.failureMsg, condition );
    
    // make sure all values are the same as what is in the defaults
    condition = [NSString stringWithFormat:@"id was %li, expected %li", (long)tt._id, (long)[[defaults objectForKey:@"id"] integerValue]];
    XCTAssertTrue( (tt._id == [[defaults objectForKey:@"id"] integerValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"int_field was %li, expected %li", (long)tt.intField, (long)[[defaults objectForKey:@"int_field"] integerValue]];
    XCTAssertTrue( (tt.intField == [[defaults objectForKey:@"int_field"] integerValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was '%@', expected '%@'", tt.strField, [defaults objectForKey:@"str_field"]];
    XCTAssertTrue( ([tt.strField isEqualToString:[defaults objectForKey:@"str_field"]]), @"%@ %@", self.failureMsg, condition );
    
    // make this one easier to understand
    BOOL defaultAsBool = [AiDatabase fixBoolean:[[defaults objectForKey:@"bool_field"] integerValue]];
    condition = [NSString stringWithFormat:@"bool_field was %@, expected %@", (tt.boolField) ? @"YES" : @"NO", (defaultAsBool) ? @"YES" : @"NO" ];
    XCTAssertTrue( (tt.boolField == defaultAsBool), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"time_field was %li, expected %li", (long)tt.timeField, (long)[[defaults objectForKey:@"time_field"] integerValue]];
    XCTAssertTrue( (tt.timeField == [[defaults objectForKey:@"time_field"] integerValue]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"float_field was %0.2f, expected %0.2f", tt.floatField, [[defaults objectForKey:@"float_field"] floatValue]];
    XCTAssertTrue( (tt.floatField == [[defaults objectForKey:@"float_field"] floatValue]), @"%@ %@", self.failureMsg, condition );
}

// Test the save method with a new instance (has a zero ID). We need to run this prior to testing init because we have to trust that we can save some values.
- (void)test_saveZero
{
    // get this out just for comparison
    TestTable *defaultData = [self getPopulatedInstance];
    
    // save a new instance with that data
    TestTable *newInstance = [self getPopulatedInstance];
    [newInstance save];
    
    // grab a new instance with data populated from the database
    TestTable *tt = [[TestTable alloc] initWithId:newInstance._id];
    
    // compare the newly populated instance to the default dataset
    NSString *condition = [NSString stringWithFormat:@"New object has ID %li, expected > 0", (long)tt._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"New object has ID %li, expected %li", (long)tt._id, (long)newInstance._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"int_field was %li, expected %li", (long)tt.intField, (long)defaultData.intField];
    XCTAssertTrue( (tt.intField == defaultData.intField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was '%@', expected '%@'", tt.strField, defaultData.strField];
    XCTAssertTrue( ([tt.strField isEqualToString:defaultData.strField]), @"%@ %@", self.failureMsg, condition );

    condition = [NSString stringWithFormat:@"bool_field was %@, expected %@", (tt.boolField) ? @"YES" : @"NO", (defaultData.boolField) ? @"YES" : @"NO" ];
    XCTAssertTrue( (tt.boolField == defaultData.boolField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"time_field was %li, expected >= %li", (long)tt.timeField, (long)defaultData.timeField];
    XCTAssertTrue( (tt.timeField >= defaultData.timeField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"float_field was %0.2f, expected %0.2f", tt.floatField, defaultData.floatField];
    XCTAssertTrue( (tt.floatField == defaultData.floatField), @"%@ %@", self.failureMsg, condition );
}

// Test the save method by following the same logic as test_saveZero, then pulling out that instance and modifying it
- (void)test_save
{
    // get this out just for comparison
    TestTable *defaultData = [self getPopulatedInstance];
    
    // save a new instance with that data
    TestTable *newInstance = [self getPopulatedInstance];
    [newInstance save];
    
    // grab a new instance with data populated from the database
    TestTable *tt = [[TestTable alloc] initWithId:newInstance._id];
    
    // compare the newly populated instance to the default dataset
    NSString *condition = [NSString stringWithFormat:@"New object has ID %li, expected > 0", (long)tt._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"New object has ID %li, expected %li", (long)tt._id, (long)newInstance._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"int_field was %li, expected %li", (long)tt.intField, (long)defaultData.intField];
    XCTAssertTrue( (tt.intField == defaultData.intField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was '%@', expected '%@'", tt.strField, defaultData.strField];
    XCTAssertTrue( ([tt.strField isEqualToString:defaultData.strField]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"bool_field was %@, expected %@", (tt.boolField) ? @"YES" : @"NO", (defaultData.boolField) ? @"YES" : @"NO" ];
    XCTAssertTrue( (tt.boolField == defaultData.boolField), @"%@ %@", self.failureMsg, condition );
    
    // the time changes on modification
    condition = [NSString stringWithFormat:@"time_field was %li, expected >= %li", (long)tt.timeField, (long)defaultData.timeField];
    XCTAssertTrue( (tt.timeField >= defaultData.timeField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"float_field was %0.2f, expected %0.2f", tt.floatField, defaultData.floatField];
    XCTAssertTrue( (tt.floatField == defaultData.floatField), @"%@ %@", self.failureMsg, condition );
    
    // change a value and save it
    NSString *newString = @"Something has changed";
    tt.strField = newString;
    [tt save];
    
    // get the newly inserted record as another new instance
    TestTable *modTt = [[TestTable alloc] initWithId:tt._id];
    
    // sanity check the ID
    condition = [NSString stringWithFormat:@"Existing object has ID %li, expected %li", (long)modTt._id, (long)tt._id];
    XCTAssertTrue( (modTt._id == tt._id), @"%@ %@", self.failureMsg, condition );
    
    // make sure the newest instance has the saved string
    condition = [NSString stringWithFormat:@"Modified string was '%@', expected '%@'", modTt.strField, newString];
    XCTAssertTrue( [modTt.strField isEqualToString:newString], @"%@ %@", self.failureMsg, condition );
}

// Test initializing an TestTable object and its members with a known entity. This is a subset of test_save, so this should have already been tested prior to here
- (void)test_init
{
    // get this out just for comparison
    TestTable *defaultData = [self getPopulatedInstance];
    
    // save a new instance with that data
    TestTable *newInstance = [self getPopulatedInstance];
    [newInstance save];
    
    // grab a new instance with data populated from the database
    TestTable *tt = [[TestTable alloc] initWithId:newInstance._id];
    
    // compare the newly populated instance to the default dataset
    NSString *condition = [NSString stringWithFormat:@"New object has ID %li, expected > 0", (long)tt._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"New object has ID %li, expected %li", (long)tt._id, (long)newInstance._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"int_field was %li, expected %li", (long)tt.intField, (long)defaultData.intField];
    XCTAssertTrue( (tt.intField == defaultData.intField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"str_field was '%@', expected '%@'", tt.strField, defaultData.strField];
    XCTAssertTrue( ([tt.strField isEqualToString:defaultData.strField]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"bool_field was %@, expected %@", (tt.boolField) ? @"YES" : @"NO", (defaultData.boolField) ? @"YES" : @"NO" ];
    XCTAssertTrue( (tt.boolField == defaultData.boolField), @"%@ %@", self.failureMsg, condition );
    
    // the time changes on modification
    condition = [NSString stringWithFormat:@"time_field was %li, expected >= %li", (long)tt.timeField, (long)defaultData.timeField];
    XCTAssertTrue( (tt.timeField >= defaultData.timeField), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"float_field was %0.2f, expected %0.2f", tt.floatField, defaultData.floatField];
    XCTAssertTrue( (tt.floatField == defaultData.floatField), @"%@ %@", self.failureMsg, condition );
}

// tests getAllEntries by adding two records into the database
- (void)test_getAllEntries
{
    // save two new instances with default data
    TestTable *instanceOne = [self getPopulatedInstance];
    TestTable *instanceTwo = [self getPopulatedInstance];
    [instanceOne save];
    [instanceTwo save];
    
    // Check ID sanity to make sure the new instances got IDs
    NSString *condition = [NSString stringWithFormat:@"First object has ID %li, expected > 0", (long)instanceOne._id];
    XCTAssertTrue( (instanceOne._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Second object has ID %li, expected > 0", (long)instanceTwo._id];
    XCTAssertTrue( (instanceTwo._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Both objects have the same ID: %li expected != IDs", (long)instanceOne._id];
    XCTAssertTrue( (instanceOne._id != instanceTwo._id), @"%@ %@", self.failureMsg, condition );
    
    // get the instances from the method being tested and test the results
    NSMutableArray *entries = [TestTable getAllEntries];
    
    condition = [NSString stringWithFormat:@"Gut %lu entries, expected 2", (unsigned long)[entries count]];
    XCTAssertTrue( ([entries count] == 2), @"%@ %@", self.failureMsg, condition );
    
    TestTable *first = [entries objectAtIndex:0];
    TestTable *second = [entries objectAtIndex:1];
    
    condition = [NSString stringWithFormat:@"First grabbed object has ID %li, expected > 0", (long)first._id];
    XCTAssertTrue( (first._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Second grabbed object has ID %li, expected > 0", (long)second._id];
    XCTAssertTrue( (second._id > 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"First grabbed object has ID %li, expected %li or %li", (long)first._id, (long)instanceOne._id, (long)instanceTwo._id];
    XCTAssertTrue( (first._id == instanceOne._id || first._id == instanceTwo._id), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Second grabbed object has ID %li, expected %li or %li", (long)second._id, (long)instanceOne._id, (long)instanceTwo._id];
    XCTAssertTrue( (second._id == instanceOne._id || second._id == instanceTwo._id), @"%@ %@", self.failureMsg, condition );
}

// tests isValidId using a negative value and one beyond the largest current value. Both tests should return NO
- (void)test_isValidIdFalse
{
    // get the maximum ID value so we can check for one beyond it. Since each test deletes all records from the database, we should be able to count on this equalling 0, but we'll go through the query just to make sure.
    NSInteger max = 0;
    // Query for the last known schema version number
    NSString *sql = [NSString stringWithFormat:@"SELECT MAX( %@ ) AS maxId FROM test_table", _idField];
    NSMutableArray *result = [db query:sql];
    // Make sure we have at least one result
    if( [db numRows] > 0 )
    {
        NSMutableDictionary *record = [result objectAtIndex:0];
        // make sure the result isn't empty
        if( [[record objectForKey:@"maxId"] integerValue] > 0 )
        {
            max = [[record objectForKey:@"maxId"] integerValue];
        }
    }
    
    NSInteger nextMax = max + 1;
    
    // check an out-of-bounds ID
    BOOL checkValue = [TestTable isValidId:nextMax];
    NSString *condition = [NSString stringWithFormat:@"ID %li unexpectedly returned as valid", (long)nextMax];
    XCTAssertFalse( checkValue, @"%@ %@", self.failureMsg, condition );
    
    // chck a negative ID, which should never happen
    checkValue = [TestTable isValidId:-1];
    condition = @"ID -1 unexpectedly returned as valid";
    XCTAssertFalse( checkValue, @"%@ %@", self.failureMsg, condition );
}

// tests isValidId using a newly inserted ID so it should return YES
- (void)test_isValidId
{
    TestTable *tt = [self getPopulatedInstance];
    [tt save];
    
    // Check ID sanity to make sure the new instance got an ID
    NSString *condition = [NSString stringWithFormat:@"New object has ID %li, expected > 0", (long)tt._id];
    XCTAssertTrue( (tt._id > 0), @"%@ %@", self.failureMsg, condition );
    
    BOOL checkValue = [TestTable isValidId:tt._id];
    condition = [NSString stringWithFormat:@"ID %li unexpectedly returned as valid", (long)tt._id];
    XCTAssertTrue( checkValue, @"%@ %@", self.failureMsg, condition );
}

// tests getDefaultValues. This test will fail if the default parameters are changed, but a failure of this test does not necessarily mean that the app will break
- (void)test_getDefaultValues
{
    NSMutableDictionary *defaults = [TestTable getDefaultValues];
    
    NSString *condition = [NSString stringWithFormat:@"Default value has ID %li, expected 0", (long)[[defaults objectForKey:@"id"] integerValue]];
    XCTAssertTrue( ([[defaults objectForKey:@"id"] integerValue] == 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Default value has int %li, expected 0", (long)[[defaults objectForKey:@"int_field"] integerValue]];
    XCTAssertTrue( ([[defaults objectForKey:@"int_field"] integerValue] == 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Default value has str '%@', expected empty string", [defaults objectForKey:@"str_field"]];
    XCTAssertTrue( ([[defaults objectForKey:@"str_field"] isEqualToString:@""]), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Default value has bool %li, expected 0", (long)[[defaults objectForKey:@"bool_field"] integerValue]];
    XCTAssertTrue( ([[defaults objectForKey:@"bool_field"] integerValue] == 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Default value has time %li, expected 0", (long)[[defaults objectForKey:@"time_field"] integerValue]];
    XCTAssertTrue( ([[defaults objectForKey:@"time_field"] integerValue] == 0), @"%@ %@", self.failureMsg, condition );
    
    condition = [NSString stringWithFormat:@"Default value has float %0.2f, expected 0.00", [[defaults objectForKey:@"float_field"] floatValue]];
    XCTAssertTrue( ([[defaults objectForKey:@"float_field"] floatValue] == 0.00), @"%@ %@", self.failureMsg, condition );
}

// tests checkInput with values that should return "ok"
- (void)test_checkInput
{
    TestTable *tt = [self getPopulatedInstance];
    NSString *result = [tt checkInput];
    
    NSString *condition = [NSString stringWithFormat:@"Input check returned '%@', expected 'ok'", result];
    XCTAssertTrue( [result isEqualToString:@"ok"], @"%@ %@", self.failureMsg, condition );
}

// tests checkInput with an empty string, so it should return an error message
- (void)test_checkInputEmptyString
{
    TestTable *tt = [self getPopulatedInstance];
    tt.strField = @"";
    NSString *result = [tt checkInput];
    
    NSString *condition = @"Input check returned 'ok', expected an error message.";
    XCTAssertFalse( [result isEqualToString:@"ok"], @"%@ %@", self.failureMsg, condition );
}

// tests checkInput with an invalid ID, so it should return an error message
- (void)test_checkInputInvalidId
{
    TestTable *tt = [self getPopulatedInstance];
    tt._id = -1;
    NSString *result = [tt checkInput];
    
    NSString *condition = @"Input check returned 'ok', expected an error message.";
    XCTAssertFalse( [result isEqualToString:@"ok"], @"%@ %@", self.failureMsg, condition );
}

// Create an empty instance and populate it with default values for saving and comparison
- (TestTable *)getPopulatedInstance
{
    TestTable *returnValue = [[TestTable alloc] initWithId:0];
    
    returnValue.intField = 42;
    returnValue.strField = @"A n'ew \"string";
    returnValue.boolField = YES;
    returnValue.timeField = 1380313365;
    returnValue.floatField = 4.20;
    
    return returnValue;
}


@end
