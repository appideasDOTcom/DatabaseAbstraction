/**
 * Application constants
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

#ifndef AiDB_constants_h
#define AiDB_constants_h

/**
 * This serves no purpose, but doxygen generates documentation incorrectly if there is nothing between the doc comments and the first real variable
 */
#define _aiTag                  @"1.0"

/**
 * Set to true to print debug messages
 */
#define _debug                  false

/**
 * The name of the sqlite file to use
 */
#define _databaseFileName       @"com.appideas.AiDB.sqlite"

/**
 * The default surrogate key (ID) field in each table
 */
#define _idField                @"id"

//
// Human-readable date formats
//

/**
 * Date format code e.g. 20130927132245
 */
#define	_terseLongDateTimeFormat            @"yyyyMMddHHmmss"

/**
 * Date format code e.g. Fri Sep 27, 2013 13:22
 */
#define _longDateTimeNiceFormat             @"eee MMM d, yyyy HH:mm"

/**
 * Date format code e.g. Fri Sep 27, 2013 1:22 PM
 */
#define _usLongDateTimeNiceFormat           @"eee MMM d, yyyy h:mm a"

/**
 * Date format code e.g. Sep 27, 13:22
 */
#define _shortDateTimeFormat                @"MMM d, HH:mm"

/**
 * Date format code e.g. Sep 27, 1:22 PM
 */
#define _usShortDateTimeFormat              @"MMM d, h:mm a"

/**
 * Date format code e.g. Sep 27
 */
#define _shortDateFormat                    @"MMM d"

/**
 * Date format code e.g. 13:22
 */
#define _shortTimeFormat                    @"HH:mm"

/**
 * Date format code e.g. 1:22 PM
 */
#define _usShortTimeFormat                  @"h:mm a"


#endif
