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

@implementation AiDatabase

@synthesize rowCount, columnCount;

/**
 * Get an AiDatabase instance
 *
 * <pre>AiDatabase *db = [[AiDatabase alloc] init];</pre>
 */
- (id)init
{
    self = [super init];
    self.rowCount = 0;
    self.columnCount = 0;
	return self;
} // [init]


#pragma mark Querying

/**
 * Perform a query
 *
 * <pre>NSMutableArray *result = [db query:\@"SELECT * FROM test_table"];</pre>
 */
-(NSMutableArray *)query:(NSString *)sql
{
    NSMutableArray *returnValue = [[NSMutableArray alloc] initWithCapacity:0];
    NSInteger resultCounter = 0;
    self.rowCount = 0;
    self.columnCount = 0;
    
    NSString *dbPath = [AiDatabase getDbPath];
	sqlite3_stmt *statement;
	
	if( sqlite3_open( [dbPath UTF8String], &database ) == SQLITE_OK )
	{
		if( sqlite3_prepare_v2( database, [sql UTF8String], -1, &statement, NULL ) != SQLITE_OK )
		{
			NSAssert1( 0, @"Error: failed to prepare AiDatabase::query with message '%s'.", sqlite3_errmsg( database ) );
		}
        
        self.columnCount = sqlite3_column_count( statement );
        
		while( sqlite3_step( statement ) == SQLITE_ROW )
		{
            NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:self.columnCount];
            
            for( int i = 0; i < self.columnCount; i++ )
            {
                int columnType = sqlite3_column_type( statement, i );
                
                if( columnType == SQLITE_NULL )
                {
                    [result
                     setObject:@""
                     forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_name( statement, i )]];
                }
                else if( columnType == SQLITE_INTEGER )
                {
                    [result
                     setObject:[NSNumber numberWithInt:sqlite3_column_int( statement, i )]
                     forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_name( statement, i )]];
                }
                else if( columnType == SQLITE_FLOAT )
                {
                    [result
                     setObject:[NSNumber numberWithDouble:sqlite3_column_double( statement, i )]
                     forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_name( statement, i )]];
                }
                else
                {

                    [result
                     setObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text( statement, i )]
                     forKey:[NSString stringWithUTF8String:(char *)sqlite3_column_name( statement, i )]];
                }
            } // for( int i = 0; i < numColumns; i++ )
            
            [returnValue
             insertObject:result
             atIndex:resultCounter];
            resultCounter++;
            
            result = nil;
		} // while( sqlite3_step( statement ) == SQLITE_ROW )
		if( statement )
		{
			sqlite3_finalize( statement );
		}
		
	}
	else // if( sqlite3_open( [dbPath UTF8String], &database ) == SQLITE_OK )
	{
		NSAssert1( 0, @"Error: failed to open AiDatabase::query connection with message '%s'.", sqlite3_errmsg( database ) );
	}
	sqlite3_close( database );
    
    self.rowCount = resultCounter;
    
    return returnValue;
} // [query]

/**
 * Perform a query that requires no return
 *
 * <pre>[db noReturnQuery:\@"DELETE FROM test_table WHERE id=5"];</pre>
 */
-(void)noReturnQuery:(NSString *)sql
{
    NSString *dbPath = [AiDatabase getDbPath];
	sqlite3_stmt *statement;
	
	if( sqlite3_open( [dbPath UTF8String], &database ) == SQLITE_OK )
	{
		if( sqlite3_prepare_v2( database, [sql UTF8String], -1, &statement, NULL ) != SQLITE_OK )
		{
			NSAssert1( 0, @"Error: failed to prepare AiDatabase::noReturnQuery with message '%s'.", sqlite3_errmsg( database ) );
		}
		sqlite3_step( statement );
        
		if( statement )
		{
			sqlite3_finalize( statement );
		}
		
	}
	else // if( sqlite3_open( [dbPath UTF8String], &database ) == SQLITE_OK )
	{
		NSAssert1( 0, @"Error: failed to open AiDatabase::noReturnQuery connection with message '%s'.", sqlite3_errmsg( database ) );
	}
	sqlite3_close( database );
    
} // [noReturnQuery]

/**
 * Get the last inserted surrogate key in a table
 *
 * <pre>NSInteger id = [db getLastIdFromTable:\@"test_table" withIdField:_idField];</pre>
 */
-(NSInteger)getLastIdFromTable:(NSString *)table withIdField:(NSString *)idField
{
    NSInteger returnValue = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT ROWID FROM %@ ORDER BY ROWID DESC LIMIT 1", table];
    NSMutableArray *result = [self query:sql];
    if( [self numRows] > 0 )
    {
        NSMutableDictionary *record = [result objectAtIndex:0];
        // make sure the result isn't empty
        if( [[record objectForKey:idField] integerValue] > 0 )
        {
            returnValue = [[record objectForKey:idField] integerValue];
        }
    }
    
    return returnValue;
} // [getLastIdFromTable]

/**
 * Insert a blank record into the table, only concerning the surrogate key
 *
 * <pre>NSInteger id = [db insertBlankIntoTable:\@"test_table" withIdField:_idField];</pre>
 
 */
-(NSInteger)insertBlankIntoTable:(NSString *)table withIdField:(NSString *)idField
{
    NSString *sql = [[NSString alloc] initWithFormat:@"\
                     INSERT\
                     INTO		%@  ( %@ )\
                     VALUES         ( NULL )\
                     ",
                     table, idField
                     ];
    
    [self noReturnQuery:sql];
	return [self getLastIdFromTable:table withIdField:idField];
} // [insertBlankIntoTable]

/**
 * Escape a string to prepare it for a database query
 *
 * <pre>NSString *someString = @"This 'is' some string";
 * NSString *sql = [NSString stringWithFormat:\@"INSERT INTO test_table ( str_field ) VALUES ( '%@' )", [AiDatabase escapeString:someString]];
 * [db noReturnQuery:sql];</pre>
 */
+(NSString *)escapeString:(NSString*)input
{
	input = [input stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	
	return input;
} // [escapeString]

/**
 * Convert database boolean to Objective-C
 *
 * <pre>BOOL falseValue = [AiDatabase fixBoolean:0];</pre>
 */
+(BOOL)fixBoolean:(NSInteger)input
{
   return (input == 0) ? NO : YES;
}

/**
 * Convert Objective-C boolean to database
 *
 * <pre>NSInteger trueValue = [AiDatabase fixDbBoolean:YES];</pre>
 */
+(NSInteger)fixDbBoolean:(BOOL)input
{
    return (input == NO ) ? 0 : 1;
}

/**
 * Get the number of rows from the most recent query
 *
 * <pre>if( [db numRows] > 0 ) { }</pre>
 */
-(NSInteger)numRows
{
    return self.rowCount;
} // [numRows]

/**
 * Gets number of columns (fields) from the most recent query
 *
 * <pre>for( NSInteger i = 0; i < [db numFields]; i++ ) { }</pre>
 */
-(NSInteger)numFields
{
    return self.columnCount;
} // // [numFields]

/**
 * Begin a database transaction, Since we open and close the database file for each access and autocommits are the default for SQLite, this only guards against problems due to device crashes mid-query.
 *
 * <pre>[db beginTransaction];
 * [db query:\@"UPDATE test_table SET str_field='some string' WHERE id=5"];
 * [db endTransaction];</pre>
 */
-(void)beginTransaction
{
    [self noReturnQuery:@"BEGIN TRANSACTION"];
} // // [beginTransaction]

/**
 * End a database transaction
 *
 * <pre>[db beginTransaction];
 * [db query:\@"UPDATE test_table SET str_field='some string' WHERE id=5"];
 * [db endTransaction];</pre>
 */
-(void)endTransaction
{
    [self noReturnQuery:@"COMMIT"];
} // // [endTransaction]

/**
 * Get the current timestamp in Unix epoch format
 *
 * <pre>NSString *sql = [NSString stringWithFormat:\@"INSERT INTO schema_versions ( update_time ) VALUES ( %i )", [AiDatabase getCurrentTimestamp]];
 * [db noReturnQuery:sql];</pre>
 */
+(NSInteger)getCurrentTimestamp
{
	NSDate *currentDate = [NSDate date];
	NSTimeInterval epochTime = [currentDate timeIntervalSince1970];
	NSInteger returnValue = (int)epochTime;
	return returnValue;
} // [getCurrentTimestamp]

/**
 * Guard against a self-inflicted injection attack
 *
 * <pre>NSString *someString = [AiDatabase blockInjection:inputString"];
 * NSString *sql = [NSString stringWithFormat:\@"INSERT INTO test_table ( str_field ) VALUES ( '%@' )", [AiDatabase escapeString:someString]];
 * [db noReturnQuery:sql];</pre>
 */
+(NSString *)blockInjection:(NSString *)input
{
    NSMutableArray *remove = [NSMutableArray arrayWithCapacity:1];
    [remove insertObject:@";" atIndex:0];
    return [AiUtil stripChars:remove fromString:input];
} // [blockInjection]


#pragma mark Initialization and file access

/**
 * The in-device file path to the database. This should probably only be used by the AiDatabase class itself since all access to the database should go through that class.
 *
 * <pre>NSString *dbPath = [AiDatabase getDbPath];</pre>
 */
+(NSString *)getDbPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES );
	NSString *libraryDirectory = [paths objectAtIndex:0];
	libraryDirectory = [libraryDirectory stringByAppendingString:@"/database"];
	NSString *dbpath = [libraryDirectory stringByAppendingFormat:@"/%@", _databaseFileName];
	
	return dbpath;
} // [getDbPath]

/**
 * Copy the default database file from the app bundle into its final home. Called from AppDelegate.
 *
 * <pre>[AiDatabase createDatabase];</pre>
 */
+(void)createDatabase
{
	// First, test for existence.
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
    
    NSString *dbFile = [AiDatabase getDbPath];
	NSString *dbDirectory = [dbFile stringByDeletingLastPathComponent];

    // Make sure the db directory exists
	success = [fileManager fileExistsAtPath:dbDirectory];
	if( !success )
	{
		[fileManager createDirectoryAtPath:dbDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	success = [fileManager fileExistsAtPath:dbFile];
	
	// database file does not exist
	if( !success )
	{
		// copy the defaultdatabase file to the appropriate location.
		NSString *bundleDBPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], _databaseFileName];
		success = [fileManager copyItemAtPath:bundleDBPath toPath:dbFile error:&error];
		if (!success)
		{
            if( ![fileManager fileExistsAtPath:bundleDBPath] )
            {
                NSLog( @"Can't find bundle DB path" );
            }
			NSAssert1( 0, @"AiDatabase::createDatabase Failed to create writable database file with message '%@'.", [error localizedDescription] );
		}
	}
	
	return;
} // [createDatabase]

#pragma mark Schema update methods

/**
 * Perform a schema update if any are available beyond the current schema version.
 *
 * <pre>BOOL updatePerformed = [db doUpgrade];</pre>
 */
-(BOOL)doUpgrade
{
    BOOL returnValue = NO;
    
    NSInteger current = [self getCurrentVersion];
    NSInteger max = [self getMaxUpdateVersion];
    if( max > current )
    {
        returnValue = YES;
        [self updateFromCurrentVersion:current toMaxVersion:max];
    }
    
    return returnValue;
} // [doUpgrade]

/**
 * Currently known database schema version.
 *
 * <pre>NSInteger currentVersion = [db getCurrentVersion];</pre>
 */
-(NSInteger)getCurrentVersion
{
    // if no versions are found, return 0
    NSInteger returnValue = 0;
    // Query for the last known schema version number
    NSString *sql = @"SELECT MAX( version_number ) AS version FROM schema_versions";
    NSMutableArray *result = [self query:sql];
    // Make sure we have at least one result
    if( [self numRows] > 0 )
    {
        NSMutableDictionary *record = [result objectAtIndex:0];
        // make sure the result isn't empty
        if( [[record objectForKey:@"version"] integerValue] > 0 )
        {
            returnValue = [[record objectForKey:@"version"] integerValue];
        }
    }
    
    return returnValue;
}  // [getCurrentVersion]

/**
 * The maximum version number to which we can update.
 *
 * <pre>NSInteger maxVersion = [db getMaxUpdateVersion];</pre>
 */
-(NSInteger)getMaxUpdateVersion
{
    // if no upgrades are found, return 0
    NSInteger returnValue = 0;
    
    // get all the files in the bundle path
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSError *error;
    
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
    // walk through the files
    for( NSString *fileName in directoryContents )
    {
        // if there is exactly one period
        NSArray *fileSplit = [fileName componentsSeparatedByString:@"."];
        if( [fileSplit count] == 2 )
        {
            // And the file extention is "sql"
            NSString *extension = [fileSplit objectAtIndex:1];
            if( [extension compare:@"sql"] == NSOrderedSame && [[fileSplit objectAtIndex:0] integerValue] > returnValue )
            {
                returnValue = [[fileSplit objectAtIndex:0] integerValue];
            }
        }
    }
    
    return returnValue;
}  // [getMaxUpdateVersion]

/**
 * Record a schema version update
 *
 * <pre>[db recordSchemaVersion:7];</pre>
 */
-(void)recordSchemaVersion:(NSInteger)version
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS count FROM schema_versions WHERE version_number = %li", (long)version];
    NSMutableArray *result = [self query:sql];
    NSMutableDictionary *row = [result objectAtIndex:0];
    
    // If this version number has already been recorded, update the time
    if( [[row objectForKey:@"count"] integerValue] > 0 )
    {
        sql =[NSString stringWithFormat:@"UPDATE schema_versions SET update_time = %li WHERE version_number = %li", (long)[AiDatabase getCurrentTimestamp], (long)version];
    }
    else // or else insert a new record
    {
        sql = [NSString stringWithFormat:@"INSERT INTO schema_versions ( version_number, update_time ) values( %li, %li )", (long)version, (long)[AiDatabase getCurrentTimestamp]];
    }
    [self noReturnQuery:sql];
} // [recordSchemaVersion]

/**
 * Update the database schema from current+1 to max.
 *
 * <pre>[db updateFromCurrentVersion:3 toMaxVersion:4];</pre>
 */
-(void)updateFromCurrentVersion:(NSInteger)current toMaxVersion:(NSInteger)max
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for( NSInteger i = (current + 1); i <= max; i++ )
    {
        NSString *updateFilePath = [NSString stringWithFormat:@"%@/%li.sql", [[NSBundle mainBundle] resourcePath], (long)i];
        BOOL success = [fileManager fileExistsAtPath:updateFilePath];
        if( success )
        {
            NSString *updateSql = [NSString
                           stringWithContentsOfFile:updateFilePath encoding:NSASCIIStringEncoding error:nil];
            NSArray *queries = [updateSql componentsSeparatedByString:@"^"];
            [self beginTransaction];
            for( NSString *sql in queries )
            {
                [self noReturnQuery:sql];
            }
            [self recordSchemaVersion:i];
            [self endTransaction];
        }
    }
} // [updateFromCurrentVersion]

@end
