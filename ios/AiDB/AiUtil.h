/**
 * App(ideas) Utility helper methods.
 *
 * Utility methods should be static
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
#import "constants.h"

@interface AiUtil : NSObject
{
    
}

/**
 * Strips characters from the input string
 *
 * @returns		A string with the given characters stripped
 * @since		20131221
 * @author		costmo
 * @param       charArray           An array of characters that are to be stripped
 * @param		inputString			The string from which characters are to be stripped
 */
+(NSString *)stripChars:(NSMutableArray *)charArray fromString:(NSString *)inputString;

/**
 * Using a Unix epoch date, returns a human-readable date. Use entries from constants.h for outputFormat specifiers
 *
 * @returns		A string representing the date or date/time in human-readable format
 * @since		20131221
 * @author		costmo
 * @param       epochDate           The epoch date to display
 * @param		outputFormat		The outout date format specifier. http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
 */
+(NSString *)readableDateFromEpoch:(NSInteger)epochDate withFormat:(NSString *)outputFormat;

@end
