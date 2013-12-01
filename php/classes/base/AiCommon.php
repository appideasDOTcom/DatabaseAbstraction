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
* A class to manage Common needs. For this project, this is used as a gateway to the database layer.
* 
* @package		Ai_DatabaseAbstraction
*/
class AiCommon
{
	// database connection info
	// reset these to match your server
	/**
	 * Database host name
	 * @var string
	 */
	protected $mDbHost = "localhost";
	
	/**
	 * Database schema name
	 * @var string
	 */
	protected $mDbName = "mydatabase";
	
	/**
	 * Database username
	 * @var string
	 */
	protected $mDbUser = "myusername";
	
	/**
	 * Database password
	 * @var string
	 */
	protected $mDbPass = "mypasswd";
	
	/**
	 * Database system utilized if the argument to the constructor is blank. This only ever needs to get reset through the constructor for testing.
	 * Under normal circumstances, leave the constructor argument blank, and this will be used.
	 * Valid values with the default distribution are 'pgsql' 'mysql' or 'oracle'
	 * @var string
	 */
	public $mAutoDbMethod = "mysql";
	
	/**
	 * Database system utilized by instances of this class.
	 * @var string
	 */
	public $mDbMethod;
	
	/**
	 * An instance of the database
	 * @var AiDb
	 */
	public $mDb;


	/**
	* Class constructor.
	*
	* Creates an instance
	*
	* @since 	Version 20120328
	* @author	Version 20120328, costmo
	* @param		string		$dbMethod			Specify a different DBMS to use. This is for testing only. Normal use would have $mAutoDbMethod defined and this class instantiated with a blank constructor.
	*/
	function __construct( $dbMethod = null )
	{
		$this->mDbMethod = (null === $dbMethod) ? strtolower( $this->mAutoDbMethod ) : strtolower( $dbMethod );
		
		if( "mysql" === $this->mDbMethod )
		{
			require_once( "base/AiMysql.php" );
			$this->mDb = new AiMysql( $this->mDbHost, $this->mDbUser, $this->mDbPass, $this->mDbName );
			$this->mDb->connect();
		}
		else if( "pgsql" === $this->mDbMethod )
		{
			require_once( "base/AiPgsql.php" );
			$this->mDb = new AiPgsql( $this->mDbHost, $this->mDbUser, $this->mDbPass, $this->mDbName );
			$this->mDb->connect();
		}
		else if( "oracle" === $this->mDbMethod )
		{
			require_once( "base/AiOracle.php" );
			$this->mDb = new AiOracle( $this->mDbHost, $this->mDbUser, $this->mDbPass, $this->mDbName );
			$this->mDb->connect();
		}
		else
		{
			echo "FATAL ERROR: '" . $this->mDbMethod . "' is an unknown database connector.
			I tried my best, but you fed me information that I don't comprehend.
			Please consult your system administrator.";
			exit();
		}
		
		// get our PHP version and define generic names for superglobal arrays
		$phpVer = phpversion();
		$split = explode( ".", $phpVer );
		$major = (int) $split[0];

		// force PHP version >= 5
		if( !$major || $major < 5 )
		{
			echo "Sorry, PHP version must be at least 5.
			Current version detected: " . $phpVer . "\n";
			exit();
		}

	} // end constructor

} // end Common
