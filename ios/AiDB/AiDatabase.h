/**
 * App(ideas) Database abstraction layer class
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "constants.h"

#import <Foundation/Foundation.h>

@interface AiDatabase : NSObject
{
    /**
     * Pointer to an sqlite3 object
     */
    sqlite3 *database;
    
    /**
     * The number of rows retrieved from the most recent query. This may not be accurate unless used immediately after the matching query
     */
    NSInteger rowCount;
    
    /**
     * The number of columns (fields) retrieved from the most recent query. This may not be accurate unless used immediately after the matching query
     */
    NSInteger columnCount;
}

@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) NSInteger columnCount;

/**
 * Initialize the database class
 *
 * @returns		An instance of AiDatabase for access to the data source
 * @since		20131221
 * @author		costmo
 */
- (id)init;

/**
 * Performs a query on the database and returns an array of results
 *
 * The returned array contains one index per returned row, and each record is a dictionary of key=field_name/value=stored_value pairs
 *
 * The returned dictionary values returned are either NSString or NSNumber. NSNumber values will need to be converted to non-object types to be useful for most purposes. This is currently not handling SQLITE_BLOB values
 *
 * @returns		An array of results dictionaries
 * @since		20131221
 * @author		costmo
 * @param		sql					The query to perform
 */
-(NSMutableArray *)query:(NSString *)sql;

/**
 * Performs a database query that does not require a return value. e.g. a DELETE query
 *
 * @since		20131221
 * @author		costmo
 * @param		sql					The query to perform
 */
-(void)noReturnQuery:(NSString *)sql;

/**
 * Gets the last value inserted into the table and ID field. Use this to get the last inserted surrogate key. This assumes a numeric surrogate key.
 *
 * @returns     An integer with the last inserted ID or 0 if there are no inserts
 * @since		20131221
 * @author		costmo
 * @param		table                       The name of the table to query
 * @param		idField						The name of the field containing the table's primary key. Use _idField as a default
 */
-(NSInteger)getLastIdFromTable:(NSString *)table withIdField:(NSString *)idField;

/**
 * Insert a blank record into a table for [object add] calls and return the primary key.
 *
 * @returns		0 if there was a problem getting the primary key, the newly inserted record's key value otherwise
 * @since		20131221
 * @author		costmo
 * @param		table                       The name of the table into which we are inserting
 * @param		idField						The name of the field containing the table's primary key. Use _idField as a default
 */
-(NSInteger)insertBlankIntoTable:(NSString *)table withIdField:(NSString *)idField;

/**
 * We're tempted to put query wrapper methods in here to aide in updates and deletes, but the proper place for those methods
 *   is in a schema adapter class, which is still private, but will be released publicly at a later date
 */

/**
 * Escapes a string to prepare it for a database query
 *
 * @returns		A string with apostrophes replaced by two apostrophes
 * @since		20131221
 * @author		costmo
 * @param		input				The string to escape
 */
+(NSString *)escapeString:(NSString *)input;

/**
 * Convert a database-native boolean value into native value for the current programming language
 *
 * @returns		A BOOL representative of the database-specific value. Non-zero values will evaluate true
 * @since		20131221
 * @author		costmo
 * @param		input                       The database-stored value to convert
 */
+(BOOL)fixBoolean:(NSInteger)input;

/**
 * Convert a programming language-native boolean value into native value for the database
 *
 * @returns		An integer representative of the programming language-specific value. Non-"NO" values will evaluate true
 * @since		20131221
 * @author		costmo
 * @param		input                       The BOOL value to convert
 */
+(NSInteger)fixDbBoolean:(BOOL)input;

/**
 * Gets number of rows from the most recent query
 *
 * @returns     The number of rows (records) from a query
 * @since		20131221
 * @author		costmo
 */
-(NSInteger)numRows;

/**
 * Gets number of columns (fields) from the most recent query
 *
 * @returns     The number of columns (fields) from a query
 * @since		20131221
 * @author		costmo
 */
-(NSInteger)numFields;

/**
 * Starts a transaction
 *
 * @since		20131221
 * @author		costmo
 */
-(void)beginTransaction;

/**
 * Ends a transaction
 *
 * @since		20131221
 * @author		costmo
 */
-(void)endTransaction;

/**
 * Return the number of seconds since the Unix epoch
 *
 * @returns     The current Unix epoch time
 * @since		20131221
 * @author		costmo
 */
+(NSInteger)getCurrentTimestamp;

/**
 * Strip semicolons from queries to guard against injection attacks.
 *
 * Since SQLite databases are in-device instead of on a server, this only protects malicious users from themselves
 *
 * @since		20131221
 * @author		costmo
 * @param		input				The string to parse
 */
+(NSString *)blockInjection:(NSString *)input;

/**
 * Get the in-device file path to the database
 *
 * @returns		An NSString with the full path to the database
 * @since		20131221
 * @author		costmo
 */
+(NSString *)getDbPath;

/**
 * Create a database in the Library/database directory if it doesn't already exist.
 *
 * This should only be called from the App Delegate on program startup
 *
 * @since		20131221
 * @author		costmo
 */
+(void)createDatabase;

/**
 * Gets the current database schema version. These should be sequential
 *
 * @returns     0 if there are no schema_versions records, else the largest version_number value from that table
 * @since		20131221
 * @author		costmo
 */
-(NSInteger)getCurrentVersion;

/**
 * Gets the maximum version number to which we can update based on files in the application bundle named <version_number>.sql
 *
 * @returns     The maximum update version number available
 * @since		20131221
 * @author		costmo
 */
-(NSInteger)getMaxUpdateVersion;

/**
 * Records a schema version update in the schema_versions table
 *
 * @since		20131221
 * @author		costmo
 * @param       version         The schema version number to record
 */
-(void)recordSchemaVersion:(NSInteger)version;

/**
 * Updates the database schema from current+1 to max (inclusive).
 *
 * This assumes that all files have been checked and reasonable sanity can be counted on.
 *
 * This should probably only be called by doUpgrade
 *
 * @since		20131221
 * @author		costmo
 * @param       current         The current version number
 * @param       max             The maximum version number to which we can update
 */
-(void)updateFromCurrentVersion:(NSInteger)current toMaxVersion:(NSInteger)max;

/**
 * Entry point for database updates. Calls updateFromCurrentVersion if updates are to be performed.
 *
 * This handles all input checking and is the only method for database updates that a programmer should ever call. It can safely be called regardless of whether or not there are updates to perform.
 *
 * @returns     YES if an upgrade was performed, NO otherwise
 * @since		20131221
 * @author		costmo
 */
-(BOOL)doUpgrade;


@end
