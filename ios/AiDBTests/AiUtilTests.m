/**
 * Test case for AiUtil class
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
#import "AiUtil.h"
#import "AiDatabase.h"
#import "constants.h"

@interface AuUtilTests : XCTestCase
{
    NSInteger testTime;
    NSString *failureMsg;
    AiDatabase *db;
}

@property (nonatomic, assign) NSInteger testTime;
@property (nonatomic, retain) NSString *failureMsg;
@property (nonatomic, retain) AiDatabase *db;

@end

@implementation AuUtilTests

@synthesize testTime, failureMsg, db;

- (void)setUp
{
    [super setUp];
    testTime = 1380313365;
    self.failureMsg = @"AiUtilTests failed with message:";
    self.db = [[AiDatabase alloc] init];
}

- (void)tearDown
{
    // empty test_table after each test method
    [db noReturnQuery:@"DELETE FROM test_table"];
    [super tearDown];
}

// test the output of each of the output date formats from a known epoch time
- (void)test_readableDateFromEpoch
{
    NSString *testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_terseLongDateTimeFormat];
    NSString *expectDate = @"20130927132245";
    NSString *condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_longDateTimeNiceFormat];
    expectDate = @"Fri Sep 27, 2013 13:22";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_usLongDateTimeNiceFormat];
    expectDate = @"Fri Sep 27, 2013 1:22 PM";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_shortDateTimeFormat];
    expectDate = @"Sep 27, 13:22";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_usShortDateTimeFormat];
    expectDate = @"Sep 27, 1:22 PM";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_shortDateFormat];
    expectDate = @"Sep 27";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_shortTimeFormat];
    expectDate = @"13:22";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
    
    testDate = [AiUtil readableDateFromEpoch:self.testTime withFormat:_usShortTimeFormat];
    expectDate = @"1:22 PM";
    condition = [NSString stringWithFormat:@"Expected: %@, Got: %@", expectDate, testDate];
    XCTAssertTrue( ([testDate compare:expectDate] == NSOrderedSame), @"%@ %@", self.failureMsg, condition );
}

// test the stripChars method.
- (void)test_stripChars
{
    NSString *input = @"A string; :with, some things";
    NSString *expected = @"A string with some things";
    NSMutableArray *stripCharArray = [NSMutableArray arrayWithObjects:@";", @":", @",", nil];
    
    // test writing to and reading from the database
    NSString *sql = [NSString stringWithFormat:@"\
                     INSERT \
                     INTO    test_table \
                     ( id, str_field ) \
                     VALUES  ( NULL, '%@' ) \
                     ", [AiUtil stripChars:stripCharArray fromString:input]];
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

@end
