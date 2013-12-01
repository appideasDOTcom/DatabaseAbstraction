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
	define( "PHPUnit_MAIN_METHOD", "testAiUtil::main" );
}

require_once( "PHPUnit/Autoload.php" );
require_once( "util/AiUtil.php" );

			
class testAiUtil extends PHPUnit_Framework_TestCase
{
	public $dbTypes = array(
			"mysql" => AiMysql,
			"pgsql" => AiPgsql,
			"oracle" => AiOracle
	);
	
	public static function main()
	{
		require_once( "PHPUnit/TextUI/TestRunner.php" );
	
		$suite  = new PHPUnit_Framework_TestSuite( "testAiUtil" );
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
	 * Test successful construction of an AiUtil object.
	 * 
	 * Called methods should be static, so the constructor doesn't give you anything useful
	 */
	public function test_Construct()
	{
		$util = new AiUtil();
		$this->assertTrue( ($util instanceof AiUtil) );
		
	} // test_Construct
	
	/**
	 * Test util->mustBeArray
	 */
	public function test_MustBeArray()
	{
		// String input
		$str = AiUtil::mustBeArray( "foo" );
		$this->assertInternalType( "array", $str );
		$this->assertEquals( 1, count( $str ) );
		$this->assertEquals( "foo", $str[0] );
		
		// empty input
		$empty = AiUtil::mustBeArray( "" );
		$this->assertInternalType( "array", $empty );
		$this->assertEquals( 0, count( $empty ) );
		$this->assertEquals( "foo", $str[0] );
		
		// array input
		$arr = AiUtil::mustBeArray( array( "foo", "bar" ) );
		$this->assertInternalType( "array", $arr );
		$this->assertEquals( 2, count( $arr ) );
		$this->assertEquals( "foo", $arr[0] );
		$this->assertEquals( "bar", $arr[1] );
		
	} // test_MustBeArray
	
	/**
	 * Test util->mustBeIndexedArray
	 */
	public function test_MustBeIndexedArray()
	{
		// non-indexed array input
		$arr = AiUtil::mustBeIndexedArray( array( "foo" => "bar" ) );
		$this->assertInternalType( "array", $arr );
		$this->assertEquals( 1, count( $arr ) );
		$this->assertEquals( "foo", key( $arr[0] ) );
		$this->assertEquals( "bar", $arr[0]["foo"] );
		
		// indexed array input
		$arr = AiUtil::mustBeIndexedArray( array( "foo", "bar" ) );
		$this->assertInternalType( "array", $arr );
		$this->assertEquals( 2, count( $arr ) );
		$this->assertEquals( "foo", $arr[0] );
		$this->assertEquals( "bar", $arr[1] );
		
	} // test_MustBeIndexedArray
	
	/**
	 * Test util->arrayEndsAsExpected
	 */
	public function test_ArrayEndsAsExpected()
	{
		$emptyString["one"]["two"]["three"] = "";
		$nonemptyString["one"]["two"]["three"] = "foo";
		$numeric["one"]["two"]["three"] = 1;
		$array["one"]["two"]["three"] = array( "foo", "bar" );
		$malformedArray["one"]["two"] = "foo";
		$longArray["one"]["two"] = "foo";
		
		// Test input sanity
		// input is not an array
		$this->assertFalse( AiUtil::arrayEndsAsExpected( "foo", array( "one", "two", "three" ), "string" ) );
		// empty input array
		$this->assertFalse( AiUtil::arrayEndsAsExpected( array(), array( "one", "two", "three" ), "string" ) );
		// keys is not an array
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $nonemptyString, "foo", "string" ) );
		// empty keys array
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $nonemptyString, array(), "string" ) );
		// invalid expected type
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $nonemptyString, array( "one", "two", "three" ), "foo" ) );
		// a key is not a member of the input array
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $nonemptyString, array( "one", "two", "four" ), "string" ) );
		// input array has an end-element that is not an array
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $malformedArray, array( "one", "two", "three" ), "string" ) );
		
		// string return true
		$this->assertTrue( AiUtil::arrayEndsAsExpected( $emptyString, array( "one", "two", "three" ), "string" ) );
		$this->assertTrue( AiUtil::arrayEndsAsExpected( $nonemptyString, array( "one", "two", "three" ), "string" ) );
		// string return false
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $array, array( "one", "two", "three" ), "string" ) );
		
		// non-empty string return true
		$this->assertTrue( AiUtil::arrayEndsAsExpected( $nonemptyString, array( "one", "two", "three" ), "nonempty_string" ) );
		// non-empty string return false
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $emptyString, array( "one", "two", "three" ), "nonempty_string" ) );
		
		// numeric return true
		$this->assertTrue( AiUtil::arrayEndsAsExpected( $numeric, array( "one", "two", "three" ), "numeric" ) );
		// numeric return false
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $nonemptyString, array( "one", "two", "three" ), "numeric" ) );
		
		// array return true
		$this->assertTrue( AiUtil::arrayEndsAsExpected( $array, array( "one", "two", "three" ), "array" ) );
		// array return false
		$this->assertFalse( AiUtil::arrayEndsAsExpected( $numeric, array( "one", "two", "three" ), "array" ) );
		
	} // test_ArrayEndsAsExpected
	
	/**
	 * Test util->mustBeNumer
	 */
	public function test_MustBeNumber()
	{
		$str = AiUtil::mustBeNumber( "foo" );
		$int = AiUtil::mustBeNumber( 3 );
		$intStr = AiUtil::mustBeNumber( "4" );
		
		$this->assertEquals( 0, $str );
		$this->assertEquals( 3, $int );
		$this->assertEquals( 4, $intStr );
		
	} // test_MustBeNumber
	
	/**
	 * Test util->stripChars
	 */
	public function test_StripChars()
	{
		$before = "Some ;string &thi/ng";
		$after = "Some string thing";
		
		$return = AiUtil::stripChars( $before, array( ";", "&", "/" ) );
		
		$this->assertEquals( $after, $return );
	
	} // test_StripChars
		
} // end class

// Call self::main() if this source file is executed directly.
if( PHPUnit_MAIN_METHOD == "testAiUtil::main" )
{
	testAiCommon::main();
}
