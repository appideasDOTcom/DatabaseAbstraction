<?php
/**
 This file is part of the APP(ideas) database abstraction project (AiDb).
 Copyright 2013, APPideas

 AiDb is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published
 by the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 AiDb is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public License
 along with AiDb (in the 'resources' directory).  If not, see
 <http://www.gnu.org/licenses/>.
 http://appideas.com/abstract-your-database-introduction
 */
/**
* Utility functions to make writing code easier.
* 
* @package		Ai_DatabaseAbstraction
*/

class AiUtil
{
	/**
	* Class constructor.
	*
	* Creates an instance
	*
	* @since 	Version 20120629
	* @author	Version 20120629, costmo
	*/
	public function __construct()
	{
		
	} // AiUtil
	
	/**
	* If the input is not an array, returns an empty array.  Otherwise returns the input array
	*
	* @return	array
	* @since 	Version 20120629
	* @author	Version 20120629, costmo
	* @param		array			$input				Input to test
	*/
	public static function mustBeArray( $input )
	{
		if( !is_array( $input ) )
		{
			if( strlen( trim( $input ) ) > 0 )
			{
				return array( $input );
			}
			else
			{
				return array();
			}
		}
		else
		{
			return $input;
		}

	} // mustBeArray()
	
	/**
	 * If the array must be indexed, this will move the entire contents of an array without a 0 node into a new 0 node
	 *
	 * @return	array
	 * @since 	Version 20120629
	 * @author	Version 20120629, costmo
	 * @param		array			$input				Input to test
	 */
	public static function mustBeIndexedArray( $input )
	{
		$input = AiUtil::mustBeArray( $input );

		if( !array_key_exists( 0, $input ) )
		{
			$tmp = $input;
			unset( $input );
			$input = array( $tmp );
		}
		
		return $input;
	
	} // mustBeIndexedArray()
	
	/**
	 * Walks the keys in a multi-dimensional array to verify that all intermediate keys exist and that the array ends with the expected type.
	 *
	 * This should help avoid lengthy if( array_key_exists... && is_array... test chains
	 *
	 * @since 	Version 20121129
	 * @author	Version 20121129, costmo
	 * @param	array		$inputArray				The array to examine
	 * @param	array		$keys						And array of key names to examine from the inputArray
	 * @param	string	$expectedType			The type of data expected at the end (string, nonempty_string, numeric or array)
	 * @return 	bool
	 */
	public static function arrayEndsAsExpected( $inputArray, $keys, $expectedType )
	{
		$validTypes = array( 'string', 'nonempty_string', 'numeric', 'array' );
	
		// input or key list is not an array or expected type is unknown
		if( !is_array( $inputArray ) || count( $inputArray ) < 1 || !is_array( $keys ) || count( $keys ) < 1 || !in_array( $expectedType, $validTypes ) )
		{
			return false;
		}
	
		$lastKey =  end( $keys );
		$keyCount = count( $keys );
	
		$current = $inputArray;
		$counter = 0;
		foreach( $keys as $index => $key )
		{
			if( array_key_exists( $key, $current ) )
			{
				$current = $current[$key];
			}
			else // the next key is not an element of the array
			{
				return false;
			}
				
			// we have reached the last key to find
			if( ($key === $lastKey) && ($counter == ($keyCount - 1)) )
			{
				// no need for a 'default' case since the types are checked in the sanity test
				switch( $expectedType )
				{
					case 'string':
						return is_string( $current );
						break;
					case 'nonempty_string':
						return (is_string( $current ) && strlen( $current ) > 0);
						break;
					case 'numeric':
						return is_numeric( $current );
						break;
					case 'array':
						return is_array( $current );
						break;
				} // switch
			} // if( $key == $lastKey )
			else
			{
				// intermediate key is not the end element, nor is it an array
				if( !is_array( $current ) )
				{
					return false;
				}
			}
			$counter++;
		} // foreach( $keys as $index => $key )
	
		// every condition has been accounted for, so this should never be reached
		return false;
	
	} // arrayEndsAsExpected
	
	/**
	 * Makes sure the input is numeric. If it is not, will return 0;
	 *
	 * @since 	Version 20121129
	 * @author	Version 20121129, costmo
	 * @param	mixed		$input					The array to examine
	 * @return 	int
	 */
	public static function mustBeNumber( $input )
	{
		if( !is_numeric( $input ) )
		{
			$input = 0;
		}
		
		return $input;
	}
	
	/**
	 * Strips characters from $chars from the input sctring
	 *
	 * @since 	Version 20121129
	 * @author	Version 20121129, costmo
	 * @param	string		$input					The input string from which characters will be stripped
	 * @param	array			$chars					An array of characters to remove from the string
	 * @return 	string
	 */
	public static function stripChars( $input, $chars )
	{
		$chars = self::mustBeArray( $chars );
		
		foreach( $chars as $index => $char )
		{
			$input = preg_replace( "/" . preg_quote( $char, "/" ) . "/", "", $input );
		}
	
		return $input;
	}
	
}
