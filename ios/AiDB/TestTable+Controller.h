/**
 * Controller for the TestTable class. Extends ("is a category of" in Objective-C lingo) TestTable
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
#import "TestTable.h"

@interface TestTable (Controller)
{
    
}

/**
 * Checks user input for valid values
 *
 * For the test app, this only validates that the str_field input has been provided.
 *
 * The caller should handle errors.
 *
 * @returns		"ok" if input checks pass. A string with the error message otherwise.
 * @since		20131221
 * @author		costmo
 */
-(NSString *)checkInput;

@end
