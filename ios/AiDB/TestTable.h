/**
 * The Model representation for test_table
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
#import "AiDatabase.h"


@interface TestTable : NSObject
{
    /**
     * The database primary key
     */
    NSInteger _id;
    
    /**
     * Value of int_field
     */
    NSInteger intField;
    
    /**
     * Value of str_field
     */
    NSString *strField;
    
    /**
     * Value of bool_field
     */
    BOOL boolField;
    
    /**
     * value of time_field
     */
    NSInteger timeField;
    
    /**
     * Human-readable format of time_field
     */
    NSString *readableTime;
    
    /**
     * value of float_field
     */
    float floatField;
    
    /**
     * An instance of the database class
     */
    AiDatabase *db;
}

@property (nonatomic, assign) NSInteger _id;
@property (nonatomic, assign) NSInteger intField;
@property (nonatomic, retain) NSString *strField;
@property (nonatomic, assign) BOOL boolField;
@property (nonatomic, assign) NSInteger timeField;
@property (nonatomic, retain) NSString *readableTime;
@property (nonatomic, assign) float floatField;
@property (nonatomic, retain) AiDatabase *db;

/**
 * Initialize a test_table instance
 *
 * @returns		An instance of TestTable. If the primary key is not found, will return default values.
 * @since		20131221
 * @author		costmo
 * @param       id          The value of the entry's primary key
 */
-(id)initWithId:(NSInteger)primaryKey;

/**
 * Returns an array of all entries sorted by data (newest first). Returned array contains instances of TestTable
 *
 * @returns		An NSMutableDictionary of key/value pairs
 * @since		20131221
 * @author		costmo
 */
+(NSMutableArray *)getAllEntries;

/**
 * Returns default values in case the initialized object isn't in the database
 *
 * @returns		An NSMutableDictionary of key/value pairs
 * @since		20131221
 * @author		costmo
 */
+(NSMutableDictionary *)getDefaultValues;

/**
 * Checks to make sure the primary key is a known record in the database
 *
 * @returns		YES if the ID was found, NO otherwise
 * @since		20131221
 * @author		costmo
 * @param       id          The value of the entry's primary key
 */
+(BOOL)isValidId:(NSInteger)primaryKey;

/**
 * Saves the current instance's member variables into the database. Assumes that input checking has already been performed.
 *
 * If the current instance's ID is zero, this will create a new record, otherwise, it updates the record with the given ID.
 *
 * @since		20131221
 * @author		costmo
 */
-(void)save;

/**
 * Removes the object with the given ID
 *
 * @since		20131221
 * @author		costmo
 * @param       primaryKey          The ID of the entry to remove
 */
+(void)deleteWithPrimaryKey:(NSInteger)primaryKey;

@end
