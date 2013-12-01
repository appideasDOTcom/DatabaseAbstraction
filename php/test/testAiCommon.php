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
// Call ::main() if this source file is executed directly.
if( !defined( "PHPUnit_MAIN_METHOD" ) )
{
	define( "PHPUnit_MAIN_METHOD", "testAiCommon::main" );
}

require_once( "PHPUnit/Autoload.php" );
require_once( "base/AiCommon.php" );

			
class testAiCommon extends PHPUnit_Framework_TestCase
{
	public $dbTypes = array(
			"mysql" => AiMysql,
			"pgsql" => AiPgsql,
			"oracle" => AiOracle
	);
	
	public static function main()
	{
		require_once( "PHPUnit/TextUI/TestRunner.php" );
	
		$suite  = new PHPUnit_Framework_TestSuite( "testAiCommon" );
		$result = PHPUnit_TextUI_TestRunner::run( $suite );
	}
	
	protected function setUp()
	{
		parent::setUp();
	}
	
	protected function tearDown()
	{
		parent::tearDown();
	}
	
	/**
	 * Test successful construction of an AiCommon object for each DBMS connector
	 */
	public function test_Construct()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			$this->assertTrue( ($common instanceof AiCommon) );
			$this->assertTrue( ($common->mDb instanceof $dbClass) );
			unset( $common );
		}
	} // test_Construct
		
} // end class

// Call self::main() if this source file is executed directly.
if( PHPUnit_MAIN_METHOD == "testAiCommon::main" )
{
	testAiCommon::main();
}
