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
if( !defined( "PHPUnit_MAIN_METHOD" ) )
{
	define( "PHPUnit2_MAIN_METHOD", "Framework_AllTests::main" );
}

require_once( "PHPUnit/Autoload.php" );
require_once( "PHPUnit/TextUI/TestRunner.php" );

require_once( "testAiCommon.php" );
require_once( "testAiConnectors.php" );
require_once( "testAiUtil.php" );

class Framework_AllTests
{
	public static function main()
	{
		PHPUnit_TextUI_TestRunner::run( self::suite() );
	}

	public static function suite()
	{
		$suite = new PHPUnit_Framework_TestSuite( "Ai_DbAbstraction" );

		$suite->addTestSuite( "testAiCommon" );
		$suite->addTestSuite( "testAiConnectors" );
		$suite->addTestSuite( "testAiUtil" );
		
		return $suite;
	}
	
}

if( PHPUnit_MAIN_METHOD == "Framework_AllTests::main" )
{
	Framework_AllTests::main();
}
?>