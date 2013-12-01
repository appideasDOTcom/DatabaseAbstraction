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
 * The interface for DBMS implementors
 *
 * @package		Ai_DatabaseAbstraction
 */
interface AiDb
{
	/**
	 * Connect to the database and set the member connection resource
	 *
	 * @return	void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 */
	public function connect();
	
	/**
	 * Perform a query of the database.
	 *
	 * This does not assume that strings have been escaped, so be sure to escape them.
	 *
	 * Use the PHP macros __FILE__ and __LINE__ for the 2nd and 3rd parameters.
	 *
	 * @return	resource
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$query	The query to perform
	 * @param	string		$file		The file making the query
	 * @param	int			$line		The line number in the querying file
	 */
	public function query( $query, $file, $line );
	
	/**
	 * Escape a string in a manner that the chosen DBMS can handle
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$string		The string to escape
	 */
	public function escapeString( $string );
	
	/**
	 * Returns any part of a query before a semi-colon
	 * 
	 * If there is an attempt of an injection attack, or if your string input legitimately has semicolons,
	 *   this is likely to cause truncated input.
	 *   
	 * If your input may contain semicolons, be sure that you trust the source before allowing it to perfom
	 *   a query.
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$string		The string to de-inject
	 */
	public function blockInjection( $string );
	
	/**
	 * Fetch a row form the database
	 *
	 * @return	array
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function fetchRow( $result );
	
	/**
	 * Fetch a row form the database and return it as an indexed array and an associative array with field names as indexes
	 * 
	 * For consistency, returned keys are cast to lower case
	 *
	 * @return	array
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function fetchArray( $result );
	
	/**
	 * Get the name of a field at the given offset
	 * 
	 * For consistency, returned values are cast to lower case
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 * @param	int			$columnOffset	The offset of the requested column (0 is the first column)
	 */
	public function fieldName( $result, $columnOffset );
	
	/**
	 * The number of rows returned by a query
	 *
	 * @return	int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function numRows( $result );
	
	/**
	 * The number of fields returned by a query
	 *
	 * @return	int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function numFields( $result );
	
	/**
	 * The type of field at the given offset
	 * 
	 * The return type depends on the given database system. Each system returns different type information. Use $this->fieldSimpleType() for a more simplistic/portable data type representation
	 *
	 * @see		$this::fieldSimpleType
	 * @return	mixed
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 * @param	int			$columnOffset	The offset of the requested column (0 is the first column)
	 */
	public function fieldType( $result, $columnOffset );
	
	/**
	 * A uniform type of field at the given offset.
	 *
	 * Returns a string that represents a simplified field type for consistency across DBMS'
	 *
	 * We don't check every field type. This has been written for the field types that APP(ideas) uses commonly. It will probably need modification to suit the needs of others.
	 * 
	 * This globs a lot of different types together. You may need to make them more fine-grained
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 * @param	int			$columnOffset	The offset of the requested column (0 is the first column)
	 */
	public function simpleFieldType( $result, $columnOffset );
	
	/**
	 * Convert a database-formatted boolean value into something consistent with PHP
	 *
	 * @return	bool
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$booleanValue		A boolean value retrieved from a database query
	 */
	public function fixBoolean( $booleanValue );
	
	/**
	 * Fixes a boolean input value of any kind to one understood by the DBMS
	 * 
	 * The data type returned depends on the DBMS being used
	 *
	 * @return	mixed
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$booleanValue		A boolean value retrieved from a database query
	 */
	public function fixDbBoolean( $booleanValue );
	
	/**
	 * Inserts a blank record into the requested table and returns the value of the surrogate key of the new record.
	 *
	 * This allows us to use a "modify" method for saving new data rather than separate "add" and "modify"
	 * 
	 * If one of your "requiredFields" is a string, you must enclose it in apostrophes on input
	 *
	 * @return	int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		string			$tableName				The name of the table into which we are inserting
	 * @param		string			$fieldName				The name of the field into which we are inserting
	 * @param		mixed				$requiredFields		An array of other fields and values that must not be null on a new record insert
	 */
	public function insertBlank( $tableName, $fieldName );
	
	/**
	 * Begins a database transaction if supported by the DBMS
	 *
	 * @return	void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$file		The file making the query. Leave empty to report the DB connector file name.
	 * @param	int			$line		The line number in the querying file.  Leave empty to report the DB connector line number.
	 */
	public function beginTransaction( $file = false, $line = false );
	
	/**
	 * Ends (commits) a database transaction if supported by the DBMS
	 *
	 * @return	void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$file		The file making the query. Leave empty to report the DB connector file name.
	 * @param	int			$line		The line number in the querying file.  Leave empty to report the DB connector line number.
	 */
	public function endTransaction( $file = false, $line = false );

	/**
	 * Retrieves a value that can be inserted into the database as a date or timestamp indicating the current date and/or time
	 *
	 * @return string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		string		$format			The format of the string to return.  One of 'database' 'epoch' or a PHP date() format. The default is 'database'
	 */
	public function getCurrentTimestamp( $format = 'database' );
	
	/**
	 * Returns -1 if the versions table cannot be found, the current schema version number otherwise
	 *
	 * @return int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 */
	public function getCurrentVersion();
	
	/**
	 * Retrieves a list of all available files for possible upgrade/downgrade of the database schema.
	 *
	 * Will echo an error and exit if file validation does not pass
	 *
	 * @return array
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		string		$fromDir			The input directory
	 */
	public function getUpgradeFiles( $fromDir );
	
	/**
	 * Makes sure there are no skips in the version numbers
	 *
	 * @return bool
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		array		$files			The retrieved files
	 */
	public function validateUpgradeFiles( $files );
	
	/**
	 * Performs an upgrade to the latest version or downgrade a single version
	 *
	 * @return string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		int		$fromVersion			The user's current schema version
	 * @param		string	$direction				"up" for an upgrade or "down" for a downgrade
	 */
	public function doUpgrade( $fromVersion, $direction );
	
	/**
	 * Records a schema change in the database
	 *
	 * @return void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string	$action			The action to perform. Either "add" or "delete"
	 * @param	int		$versionNumber	The version number to record
	 */
	public function recordSchemaChange( $action, $versionNumber );

} // end AiDb interface