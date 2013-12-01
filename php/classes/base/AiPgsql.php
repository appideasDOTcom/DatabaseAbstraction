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
require_once( "base/AiDb.php" );
require_once( "util/AiUtil.php" );
/**
* An implementation of the abstraction of the PostgreSQL database engine
* 
* @package		Ai_DatabaseAbstraction
*/
class AiPgsql implements AiDb
{
	/**
	 * Database host name
	 * @var string
	 */
	protected $mDbHost;
	
	/**
	 * Database username
	 * @var string
	 */
	protected $mDbUser;
	
	/**
	 * Database password
	 * @var string
	 */
	protected $mDbPass;
	
	/**
	 * Database schema name
	 * @var string
	 */
	protected $mDbName;
	
	/**
	 * Resource created by the database connection
	 * @var resource
	 */
	public $mConnectionResource;
	
	/**
	 * The name of the table that holds the schema version update history
	 * @var string
	 */
	protected $mVersionsTable = "schema_versions";
	
	/**
	* Class constructor.
	* 
	* Setup parameters through AiCommon and access the database through that class' instance of this class
	* 
	* @since 	Version 20120328
	* @author	Version 20120328, costmo
	* @param		string			$dbHost					The database host name
	* @param		string			$dbUser					The database username
	* @param		mixed				$dbPass					The database password
	* @param		string			$dbName					The name of the database
	*/
	public function __construct( $dbHost, $dbUser, $dbPass, $dbName )
	{
		$this->mDbHost = $dbHost;
		$this->mDbUser = $dbUser;
		$this->mDbPass = $dbPass;
		$this->mDbName = $dbName;
	} // Constructor

	/**
	 * Connect to the database and set the member connection resource
	 *
	 * @return	void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 */
	public function connect()
	{
		try
		{
			@$this->mConnectionResource = pg_connect( "host=" . $this->mDbHost . " user=" . $this->mDbUser . " password=" . $this->mDbPass . " dbname=" . $this->mDbName );
			if( !$this->mConnectionResource )
			{
				throw new Exception( "CONNECTION ERROR: Could not connect to the PostgreSQL database. Check your connection parameters in base/AiCommon.php" );
			}
		}
		catch( Exception $exception )
		{
			// if we could not connect, halt execution and display an error
			throw new Exception( $exception->getMessage() );
		}
	} // connect()
	
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
	public function query( $query, $file, $line )
	{
		// try a successful query
		try
		{
			@$result = pg_query( $this->mConnectionResource, $query );
			if( !$result )
			{
				throw new Exception( "QUERY ERROR: In file " . $file . ", line number " . $line . ", PostgreSQL said: " . pg_last_error() . "\n\nThe query was: \n" . $query . "\n" );
			}
			// the return value is only hit on no exception
			return $result;
		}
		catch( Exception $exception )
		{
			// show an error and halt execution.  This is OK in Postgres - if we are in a transaction,
			//  a die before the END or COMMIT block causes an implicit ROLLBACK
			throw new Exception( $exception->getMessage() );
		}
	} // query()
	
	/**
	 * Escape a string in a manner that the chosen DBMS can handle
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$string		The string to escape
	 */
	public function escapeString( $string )
	{
		// return pg_escape_string( stripslashes( $string ) );
		// return pg_escape_literal( stripslashes( $string ) );
		return preg_replace( '/\'/', '\'\'', $string );
	} // escapeString
	
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
	public function blockInjection( $string )
	{
		$split = preg_split( "/;/", $string );
		return $split[0];
	}
	
	/**
	 * Fetch a row form the database
	 *
	 * @return	array
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function fetchRow( $result )
	{
		return pg_fetch_row( $result );
	} // fetchRow()
	
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
	public function fetchArray( $result )
	{
		$returnValue = pg_fetch_array( $result );
		// The final attempt at fetch_array returns false when all records are retrieved in a loop,
		//   but array_change_key_case doesn't like that
		if( is_array( $returnValue ) )
		{
			// convert all keys to lower case
			$returnValue = array_change_key_case( $returnValue );
		}
		return $returnValue;
	} // fetchArray()
	
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
	public function fieldName( $result, $columnOffset )
	{
		return pg_field_name( $result, $columnOffset );
	} // fieldName()
	
	/**
	 * The number of rows returned by a query
	 *
	 * @return	int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function numRows( $result )
	{
		return pg_num_rows( $result );
	} // numRows()
	
	/**
	 * The number of fields returned by a query
	 *
	 * @return	int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 */
	public function numFields( $result )
	{
		return pg_num_fields( $result );
	} // numFields()
	
	/**
	 * The type of field at the given offset
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	resource		$result		The conenction resource returned by a query
	 * @param	int			$columnOffset	The offset of the requested column (0 is the first column)
	 */
	public function fieldType( $result, $columnOffset )
	{
		return strtolower( pg_field_type( $result, $columnOffset ) );
	} // fieldType()
	
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
	public function simpleFieldType( $result, $columnOffset )
	{
		$rawType = strtolower( pg_field_type( $result, $columnOffset ) );
		switch( $rawType )
		{
			case "bit":
			case "float4":
			case "float8":
			case "int2":
			case "int4":
			case "int8":
			case "numeric":
			case "varbit":
				return "numeric";
				break;
			case "date":
			case "time":
			case "timestamp":
			case "timestamptz":
			case "timetz":
				return "date";
				break;
			case "text":
			case "varchar":
				return "string";
				break;
			case "bool":
				return "bool";
				break;
			default:
				return "unknown";
				break;
		}
	} // simpleFieldType
	
	/**
	 * Convert a database-formatted boolean value into something consistent with PHP
	 * 
	 * Since PostgreSQL has a native boolean data type, this is looking for "TRUE" or "FALSE"
	 *
	 * @return	bool
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$booleanValue		A boolean value retrieved from a database query
	 */
	public function fixBoolean( $booleanValue )
	{
		if( "t" === strtolower( $booleanValue ) || "true" === strtolower( $booleanValue ) )
		{
			return TRUE;
		}
		else
		{
			return FALSE;
		}
	} // fixBoolean()
	
	/**
	 * Fixes a boolean input value of any kind to one understood by the DBMS
	 * 
	 * Since PostgreSQL has a boolean data type, this will return either "true" or "false"
	 *
	 * @return	string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$booleanValue		A boolean value retrieved from a database query
	 */
	public function fixDbBoolean( $booleanValue )
	{
		$returnValue = "true";
		if(	(strlen( $booleanValue ) < 1) ||
				(0 === $booleanValue) ||
				('0' === $booleanValue) ||
				(false === $booleanValue) ||
				("false" === strtolower( $booleanValue )) ||
				("f" === strtolower( $booleanValue )) ||
				(NULL === $booleanValue) )
		{
			$returnValue = "false";
		}

		return $returnValue;
	} // end fixDbBoolean
	
	
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
	public function insertBlank( $tableName, $fieldName, $requiredFields = FALSE )
	{
		if( !$requiredFields || !is_array( $requiredFields ) )
		{
			$insertQuery = "
							INSERT
							INTO   " . $tableName . " ( " . $fieldName . " )
							VALUES ( DEFAULT )
						";
		}
		else
		{
			$fields = "";
			$values = "";
			foreach( $requiredFields as $field => $value )
			{
				$fields .= ", " . $field;
				$values .= ", " . $value;
			}
			$insertQuery = "
							INSERT
							INTO   " . $tableName . " ( " . $fieldName . $fields . " )
							VALUES ( DEFAULT" . $values . " )
						";
			
		}
		
		$mungedTableName = preg_replace( '/\"$/', '', $tableName );
		$mungedTableName = $mungedTableName . "_" . $fieldName . "_seq";
		$returnQuery = "
		SELECT CURRVAL( '" . $mungedTableName . "' )
		";
		
		$this->beginTransaction( __FILE__, __LINE__ );
		$this->query( $insertQuery, __FILE__, __LINE__ );
		$this->endTransaction( __FILE__, __LINE__ );
		$result = $this->query( $returnQuery, __FILE__, __LINE__ );
		$row = $this->fetchRow( $result );
		$returnValue = $row[0];
		
		return $returnValue;

	} // insertBlank()
	
	/**
	 * Begins a database transaction if supported by the DBMS
	 *
	 * @return	void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$file		The file making the query. Leave empty to report the DB connector file name.
	 * @param	int			$line		The line number in the querying file.  Leave empty to report the DB connector line number.
	 */
	public function beginTransaction( $file = false, $line = false )
	{
		$file = (is_string( $file )) ? $file : __FILE__;
		$line = (is_numeric( $line )) ? $line : __FILE__;
		$this->query( "BEGIN", $file, $line );
	} // beginTransaction()
	
	/**
	 * Ends (commits) a database transaction if supported by the DBMS
	 *
	 * @return	void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string		$file		The file making the query. Leave empty to report the DB connector file name.
	 * @param	int			$line		The line number in the querying file.  Leave empty to report the DB connector line number.
	 */
	public function endTransaction( $file = false, $line = false )
	{
		$file = (is_string( $file )) ? $file : __FILE__;
		$line = (is_numeric( $line )) ? $line : __FILE__;
		$this->query( "COMMIT", $file, $line );
	} // endTransaction()
	
	
	/**
	 * Retrieves a value that can be inserted into the database as a date or timestamp indicating the current date and/or time
	 * 
	 * @return string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		string		$format			The format of the string to return.  One of 'database' 'epoch' or a PHP date() format. The default is 'database'
	 */
	public function getCurrentTimestamp( $format = 'database' )
	{
		$returnString = date( "Y-m-d H:i:s" );
		
		if( "database" === $format )
		{
			// Do nothing. This is the default
		}
		else if( "epoch" === $format )
		{
			$returnString = time();
		}
		else
		{
			$returnString = date( $format );
		}
		
		return $returnString;
	} // end getCurrentTimestamp
	
	/**
	 * Returns -1 if the versions table cannot be found, the current version number otherwise
	 *
	 * @return int
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 */
	public function getCurrentVersion()
	{
		$returnValue = 0;
		$sql = "SELECT * FROM information_schema.tables where table_name='" . $this->mVersionsTable . "'";
		$result = $this->query( $sql, __FILE__, __LINE__ );
		if( $this->numRows( $result ) < 1 )
		{
			$returnValue = -1;
		}
		else
		{
			$sql = "SELECT MAX( version_number ) FROM " . $this->mVersionsTable;
			$result = $this->query( $sql, __FILE__, __LINE__ );
			$row = $this->fetchRow( $result );
			$returnValue = (is_numeric( $row[0] )) ? $row[0] : 0;
		}
		
		return $returnValue;
	}
	
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
	public function getUpgradeFiles( $fromDir )
	{
		$returnValue = array();
		
		if( !is_dir( $fromDir ) )
		{
			return $returnValue;
		}
		
		$dh = opendir( $fromDir );
		while( false !== ($file = readdir( $dh )) )
		{
			if( 1 === preg_match( "/\.php$/", $file ) )
			{
				$returnValue[] = $file;
			}
		}
		
		sort( $returnValue, SORT_NUMERIC );
		// get out of here if the upgrade files are not in a valid sequence
		if( !$this->validateUpgradeFiles( $returnValue ) )
		{
			exit();
		}
		
		return $returnValue;
	}
	
	/**
	 * Makes sure there are no skips in the version numbers
	 *
	 * @return bool
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		array		$files			The retrieved files
	 */
	public function validateUpgradeFiles( $files )
	{
		$returnValue = true;
		
		$files = AiUtil::mustBeArray( $files );
		
		$lastFileName = 0;
		foreach( $files as $index => $fileName )
		{
			$split = preg_split( "/\./", $fileName );
			if( (int) $split[0] !== $lastFileName + 1 )
			{
				echo "File name: " . $fileName . " represents a skip from number " . $lastFileName . ". The upgrade cannot continue.\n";
				$returnValue = false;
				$lastFileName = $split[0];
			}
			else
			{
				$lastFileName++;
			}
		}
		
		return $returnValue;
	}
	
	/**
	 * Performs an upgrade to the latest version or downgrade a single version
	 *
	 * @return string
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param		int		$fromVersion			The user's current schema version
	 * @param		string	$direction				"up" for an upgrade or "down" for a downgrade
	 */
	public function doUpgrade( $fromVersion, $direction )
	{
		$files = $this->getUpgradeFiles( $_ENV["PWD"] . "/data/pgsql" );
		// make sure there are files and the input directory exists
		if( count( $files ) < 1 )
		{
			return "Either there were no files in the updates/data/pgsql directory or the directory was not found.";
		}
		
		$lastFile = end( $files );
		$split = preg_split( "/\./", $lastFile );
		$lastVersion = $split[0];
		
		// exit if we can't or don't need to up/downgrade
		if( "up" === $direction && $fromVersion >= $lastVersion )
		{
			return "Already up to date.";
		}
		else if( "down" === $direction && $fromVersion > $lastVersion )
		{
			return "I do not have a file that is late enought to perform this downgrade. Your version is " . $fromVersion . " and the latest downgrade file is " . $lastFile;
		}
		
		if( "up" === $direction )
		{
			echo "Upgrading from version " . $fromVersion . " to " . $lastVersion . "...\n";
			
			// Run the updates
			foreach( $files as $index => $fileName )
			{
				if( ($index + 1) > $fromVersion )
				{
					$split = preg_split( "/\./", $fileName );
					echo "Upgrading to version " . $split[0] . "...\n";
					
					require_once( $_ENV["PWD"] . "/data/pgsql/" . $fileName );
					$className = DbUpdater . $split[0];
					$update = new $className();
					$sqlArray = $update->upgrade();
					$this->beginTransaction( __FILE__, __LINE__ ); // cause an explicit rollback if any one of the intermediate queries fails
					foreach( $sqlArray as $index => $sql )
					{
						echo $sql . "\n";
						$this->query( $sql, __FILE__, __LINE__ );
					}
					$this->recordSchemaChange( "add", $split[0] );
					$this->endTransaction( __FILE__, __LINE__ );
				} // if( ($index + 1) > $fromVersion ) )
			} // foreach( $files as $index => $fileName )
		}
		else if( "down" === $direction ) // run a downgrade
		{
			echo "Downgrading version " . $fromVersion . "...\n";
			if( $fromVersion > 0 )
			{
				require_once( $_ENV["PWD"] . "/data/pgsql/" . $fromVersion . ".php" );
				$className = DbUpdater . $fromVersion;
				$update = new $className();
				$sqlArray = $update->downgrade();
				$this->beginTransaction( __FILE__, __LINE__ ); // cause an explicit rollback if any one of the intermediate queries fails
				foreach( $sqlArray as $index => $sql )
				{
					echo $sql . "\n";
					$this->query( $sql, __FILE__, __LINE__ );
				}
				$this->recordSchemaChange( "delete", $fromVersion );
				$this->endTransaction( __FILE__, __LINE__ );
			}
		}
		
		return "\n" . ucfirst( $direction ) . "grade complete.";
	}
	
	/**
	 * Records a schema change in the database
	 *
	 * @return void
	 * @since 	Version 20120328
	 * @author	Version 20120328, costmo
	 * @param	string	$action			The action to perform. Either "add" or "delete"
	 * @param	int		$versionNumber	The version number to record
	 */
	public function recordSchemaChange( $action, $versionNumber )
	{
		// get out of here if the action isn't "add" or "delete"
		if( !in_array( strtolower( $action ), array( "add", "delete" ) ) )
		{
			return;
		}
		
		// Make the query
		$sql = "INSERT INTO " . $this->mVersionsTable . " ( version_number ) VALUES( " . AiUtil::MustBeNumber( $versionNumber ) . " )";
		// overwrite the query if this is a downgrade
		if( strtolower( "delete" ) === $action )
		{
			$sql = "DELETE FROM " . $this->mVersionsTable . " WHERE version_number = " . AiUtil::MustBeNumber( $versionNumber );
		}
		$this->query( $sql, __FILE__, __LINE__ );
	}

} // end class