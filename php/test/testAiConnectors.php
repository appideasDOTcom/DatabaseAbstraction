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
 * We're testing all of our database connectors here.
 * 
 * We normally write only one test class for each implementation class, but since all three
 *   database connectors are supposed to have the same behavior, we'll test them together.
 *   
 * We try to make this compact and consistent and repeat as little code as possible by wrapping queries
 *   to each DBMS in foreach loops
 *   
 * In order to run these tests, you must upgrade your database to version 1 from the sample code. Instructions are here:
 * http://appideas.com/database-abstraction-part-1-php/
 * 
 * To run tests specifically from your system, remove the database types that you do not use from the $dbTypes member array
 */
// Call ::main() if this source file is executed directly.
if( !defined( "PHPUnit_MAIN_METHOD" ) )
{
	define( "PHPUnit_MAIN_METHOD", "testAiConnectors::main" );
}

require_once( "PHPUnit/Autoload.php" );
require_once( "base/AiCommon.php" );

			
class testAiConnectors extends PHPUnit_Framework_TestCase
{
	public $dbTypes = array(
		"mysql" => AiMysql,
		"pgsql" => AiPgsql,
		"oracle" => AiOracle
	);
	
	public $inputOne = array(
		"int_field" => 1,
		"str_field" => "Short \"quot'ed\" string one",
		"large_str_field" => "Large \"quot'ed\" string one",
		"bool_field" => true
	);
	public $inputTwo = array(
		"int_field" => 2,
		"str_field" => "Short \"quot'ed\" string two",
		"large_str_field" => "Large \"quot'ed\" string two",
		"bool_field" => false
	);
	
	public $mungedStrings = array(
			"original" => "\"This\" is a 'test string",
			"expect" => "\"This\" is a ''test string"
	);
	
	
	public static function main()
	{
		require_once( "PHPUnit/TextUI/TestRunner.php" );
	
		$suite  = new PHPUnit_Framework_TestSuite( "testAiConnectors" );
		$result = PHPUnit_TextUI_TestRunner::run( $suite );
	}
	
	protected function setUp()
	{
		parent::setUp();
	}
	
	protected function tearDown()
	{
		parent::tearDown();
		// clean up our test data
		$sql = "DELETE FROM test_table";
		
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			$common->mDb->beginTransaction( __FILE__, __LINE__ );
			$common->mDb->query( $sql, __FILE__, __LINE__ );
			$common->mDb->endTransaction( __FILE__, __LINE__ );
			unset( $common );
		}
	}
	
	/**
	 * Tests the connection
	 * 
	 * This is technically done in the AiCommon constructor tests, but is added here for thoroughness
	 */
	public function test_Connect()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			$common->mDb->connect();
			
			$this->assertTrue( ($common instanceof AiCommon) );
			$this->assertTrue( ($common->mDb instanceof $dbClass) );
			
			if( "mysql" === $dbType )
			{
				$this->assertEquals( get_class( $common->mDb->mConnectionResource ), "mysqli" );
			}
			else
			{
				$this->assertEquals( gettype( $common->mDb->mConnectionResource ), "resource" );
			}
			unset( $common );
		}
	} // test_Connect
	
	/**
	 * Test a query
	 */
	public function test_Query()
	{	
		$sql = "SELECT 1 + 1";
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );

			// if this is Oracle, the query has to be modified slightly
			$querySql = ("oracle" === $dbType) ? $sql . " FROM DUAL" : $sql;
			
			$result = $common->mDb->query( $querySql, __FILE__, __LINE__ );
			$row = $common->mDb->fetchRow( $result );
			
			$this->assertEquals( 2, $row[0] );
			
			if( "mysql" === $dbType )
			{
				$this->assertEquals( get_class( $result ), "mysqli_result" );
			}
			else
			{
				$this->assertEquals( gettype( $common->mDb->mConnectionResource ), "resource" );
			}
			
			unset( $common );
		}
	} // test_Query
	
	/**
	 * Test db->escapeString()
	 */
	public function test_EscapeString()
	{
		$rawUpdateSql = "UPDATE test_table SET str_field = '%str' WHERE id = %id";
		$rawGetSql = "SELECT str_field FROM test_table WHERE id = %id";
		
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			
			// pre-escape the string
			$escaped = $common->mDb->escapeString( $this->mungedStrings['original'] );
			// Insert a new object so we can have its ID
			$id = $common->mDb->insertBlank( "test_table", "id" );
			// perform string replacements on the queries
			$updateSql = preg_replace( "/%id$/", $id, $rawUpdateSql );
			$updateSql = preg_replace( "/%str/", $escaped, $updateSql );
			$getSql = preg_replace( "/%id$/", $id, $rawGetSql );
			
			// update the blank record
			$common->mDb->query( $updateSql, __FILE__, __LINE__ );
			// get the new record
			$result = $common->mDb->query( $getSql, __FILE__, __LINE__ );
			$row = $common->mDb->fetchRow( $result );
			
			// perform our tests
			$this->assertInternalType( 'numeric', $id );
			$this->assertGreaterThan( 0, $id );
			$this->assertEquals( $this->mungedStrings['expect'], $escaped );
			$this->assertEquals( $this->mungedStrings['original'], $row[0] );
			
			unset( $common );
		}
	} // test_EscapeString
	
	/**
	 * Test db->blockInjection()
	 */
	public function test_BlockInjection()
	{
		$inputSql = "SELECT 1 + 1;DROP TABLE test_table";
		$expect = "SELECT 1 + 1";
		
		//setup DBMS-specific queries to test for table existence after the fact
		$tableQueryFor = array(
			"mysql" => "SHOW TABLES LIKE 'test_table'",
			"pgsql" => "SELECT * FROM information_schema.tables where table_name='test_table'",
			"oracle" => "SELECT count(*) FROM user_tables WHERE LOWER( table_name ) = 'test_table'"
		);
		
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			
			$querySql = $common->mDb->blockInjection( $inputSql );
			// modify the queries for Oracle
			$querySql = ("oracle" === $dbType) ? $querySql . " FROM DUAL" : $querySql;
			$expectSql = ("oracle" === $dbType) ? $expect . " FROM DUAL" : $expect;
			
			$result = $common->mDb->query( $querySql, __FILE__, __LINE__ );
			$row = $common->mDb->fetchRow( $result );
			
			$this->assertEquals( $expectSql, $querySql );
			$this->assertEquals( 2, $row[0] );
			
			// make sure the command after the semicolon did not get executed
			$result = $common->mDb->query( $tableQueryFor[ $dbType ], __FILE__, __LINE__ );
			$row = $common->mDb->fetchRow( $result );
			
			if( "oracle" === $dbType )
			{
				$this->assertEquals( 1, $row[0] );
			}
			else
			{
				$this->assertEquals( 1, $common->mDb->numRows( $result ) );
			}
			
			unset( $common );
		}

	} // test_BlockInjection
	
	/**
	 * Test db->fetchRow()
	 */
	public function test_FetchRow()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			
			$ids = $this->insertQueries( $dbType );
		
			// read the values from the database
			$idsForIn = $ids[0] . ", " . $ids[1];
			$idsForCompare = array( $ids[0], $ids[1] );
			$sql = "SELECT int_field, str_field, bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			while( $row = $common->mDb->fetchRow( $result ) )
			{
				$int = $row[0];
				$str = $row[1];
				$bool = $common->mDb->fixBoolean( $row[2] );
				$id =$row[3];
				
				$this->assertTrue( in_array( $id, $idsForCompare ) );
				
				// set the array to which we will compare the results
				$originArray = ($id === $ids[0]) ? $this->inputOne : $this->inputTwo;
					
				$this->assertEquals( $originArray['int_field'], $int );
				$this->assertEquals( $originArray['str_field'], $str );
				$this->assertInternalType( 'boolean', $bool );
				
				// just to be sure we got proper true/false values in and out of the database, do explicit checks given the knowledge we have about the input arrays
				if( $id === $ids[0] )
				{
					$this->assertTrue( $bool );
				}
				else
				{
					$this->assertFalse( $bool );
				}
			}
			unset( $common );
		}
	} // test_FetchRow
	
	/**
	 * Test db->fetchArray()
	 */
	public function test_FetchArray()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
				
			$ids = $this->insertQueries( $dbType );
	
			// read the values from the database
			$idsForIn = $ids[0] . ", " . $ids[1];
			$idsForCompare = array( $ids[0], $ids[1] );
			$sql = "SELECT int_field, str_field, bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			while( $row = $common->mDb->fetchArray( $result ) )
			{
				$intByIndex = $row[0];
				$strByIndex = $row[1];
				$boolByIndex = $common->mDb->fixBoolean( $row[2] );
				$idByIndex = $row[3];
				
				$intByKey = $row['int_field'];
				$strByKey = $row['str_field'];
				$boolByKey = $common->mDb->fixBoolean( $row['bool_field'] );
				$idByKey = $row['id'];
	
				$this->assertTrue( in_array( $idByIndex, $idsForCompare ) );
				$this->assertEquals( $intByIndex, $intByKey );
				$this->assertEquals( $strByIndex, $strByKey );
				$this->assertEquals( $boolByIndex, $boolByKey );
				$this->assertEquals( $idByIndex, $idByKey );
	
				// set the array to which we will compare the results
				$originArray = ($idByIndex === $ids[0]) ? $this->inputOne : $this->inputTwo;
					
				$this->assertEquals( $originArray['int_field'], $intByIndex );
				$this->assertEquals( $originArray['str_field'], $strByIndex );
				$this->assertInternalType( 'boolean', $boolByIndex );
	
				// just to be sure we got proper true/false values in and out of the database, do explicit checks given the knowledge we have about the input arrays
				if( $idByIndex === $ids[0] )
				{
					$this->assertTrue( $boolByIndex );
				}
				else
				{
					$this->assertFalse( $boolByIndex );
				}
				
			}
			unset( $common );
		}
	} // test_FetchArray
	
	/**
	 * Test db->fetchFieldObject()
	 * 
	 * Test the fetchFieldObject helper method that is only in MySQL
	 */
	public function test_FetchFieldObject()
	{
		$common = new AiCommon( "mysql" );
		$ids = $this->insertQueries( "mysql" );
		
		$idsForIn = $ids[0] . ", " . $ids[1];
		
		$sql = "SELECT int_field, str_field, bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
		$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
		$intField = $common->mDb->fetchFieldObject( $result, 0 );
		$strField = $common->mDb->fetchFieldObject( $result, 1 );
		$boolField = $common->mDb->fetchFieldObject( $result, 2 );
		$idField = $common->mDb->fetchFieldObject( $result, 3 );
		
		$this->assertEquals( "int_field", $intField->name );
		$this->assertEquals( "test_table", $intField->table );
		$this->assertEquals( MYSQLI_TYPE_LONG, $intField->type );
		
		$this->assertEquals( "str_field", $strField->name );
		$this->assertEquals( "test_table", $strField->table );
		$this->assertEquals( MYSQLI_TYPE_BLOB, $strField->type );
		
		$this->assertEquals( "bool_field", $boolField->name );
		$this->assertEquals( "test_table", $boolField->table );
		$this->assertEquals( MYSQLI_TYPE_LONG, $boolField->type );
		
		$this->assertEquals( "id", $idField->name );
		$this->assertEquals( "test_table", $idField->table );
		$this->assertEquals( MYSQLI_TYPE_LONG, $idField->type );
	} // test_FetchFieldObject
	
	/**
	 * Test db->fieldName()
	 */
	public function test_FieldName()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			
			$ids = $this->insertQueries( $dbType );
	
			$idsForIn = $ids[0] . ", " . $ids[1];
		
			$sql = "SELECT int_field, str_field, bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			$intField = $common->mDb->fieldName( $result, 0 );
			$strField = $common->mDb->fieldName( $result, 1 );
			$boolField = $common->mDb->fieldName( $result, 2 );
			$idField = $common->mDb->fieldName( $result, 3 );
		
			$this->assertEquals( "int_field", $intField );
			$this->assertEquals( "str_field", $strField );
			$this->assertEquals( "bool_field", $boolField );
			$this->assertEquals( "id", $idField );
		}
	} // test_FieldName
	
	/**
	 * Test db->numRows()
	 */
	public function test_NumRows()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
				
			$ids = $this->insertQueries( $dbType );
	
			$idsForIn = $ids[0] . ", " . $ids[1];
	
			$sql = "SELECT int_field, str_field, bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			$numRows = $common->mDb->numRows( $result );
	
			$this->assertEquals( 2, $numRows );
		}
	} // test_NumRows
	
	/**
	 * Test db->numFields()
	 */
	public function test_NumFields()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
	
			$ids = $this->insertQueries( $dbType );
	
			$idsForIn = $ids[0] . ", " . $ids[1];
	
			$sql = "SELECT int_field, str_field, bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			$numFields = $common->mDb->numFields( $result );
	
			$this->assertEquals( 4, $numFields );
		}
	} // test_NumFields
	
	/**
	 * Test db->fieldType()
	 */
	public function test_FieldType()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
	
			$ids = $this->insertQueries( $dbType );
	
			$idsForIn = $ids[0] . ", " . $ids[1];
	
			$sql = "SELECT int_field, str_field, bool_field, large_str_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			$intField = $common->mDb->fieldType( $result, 0 );
			$strField = $common->mDb->fieldType( $result, 1 );
			$boolField = $common->mDb->fieldType( $result, 2 );
			$largeStrField = $common->mDb->fieldType( $result, 3 );
			$idField = $common->mDb->fieldType( $result, 4 );
			
			if( "mysql" === $dbType )
			{
				$this->assertEquals( MYSQLI_TYPE_LONG, $intField );
				$this->assertEquals( MYSQLI_TYPE_BLOB, $strField );
				$this->assertEquals( MYSQLI_TYPE_LONG, $boolField );
				$this->assertEquals( MYSQLI_TYPE_BLOB, $largeStrField );
				$this->assertEquals( MYSQLI_TYPE_LONG, $idField );
			}
			else if( "pgsql" === $dbType )
			{
				$this->assertEquals( "int4", $intField );
				$this->assertEquals( "text", $strField );
				$this->assertEquals( "bool", $boolField );
				$this->assertEquals( "text", $largeStrField );
				$this->assertEquals( "int4", $idField );
			}
			else if( "oracle" === $dbType )
			{
				$this->assertEquals( "number", $intField );
				$this->assertEquals( "varchar2", $strField );
				$this->assertEquals( "number", $boolField );
				$this->assertEquals( "clob", $largeStrField );
				$this->assertEquals( "number", $idField );
			}

		}
	} // test_FieldType
	
	/**
	 * Test db->simpleFieldType()
	 */
	public function test_SimpleFieldType()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
	
			$ids = $this->insertQueries( $dbType );
	
			$idsForIn = $ids[0] . ", " . $ids[1];
	
			$sql = "SELECT int_field, str_field, bool_field, large_str_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			$intField = $common->mDb->simpleFieldType( $result, 0 );
			$strField = $common->mDb->simpleFieldType( $result, 1 );
			$boolField = $common->mDb->simpleFieldType( $result, 2 );
			$largeStrField = $common->mDb->simpleFieldType( $result, 3 );
			$idField = $common->mDb->simpleFieldType( $result, 4 );

			$this->assertEquals( "numeric", $intField );
			$this->assertEquals( "string", $strField );
			$this->assertEquals( "numeric", $idField );
			
			if( "pgsql" === $dbType )
			{
				$this->assertEquals( "bool", $boolField );
			}
			else
			{
				$this->assertEquals( "numeric", $boolField );
			}
			
			if( "oracle" === $dbType )
			{
				$this->assertEquals( "binary", $largeStrField );
			}
			else
			{
				$this->assertEquals( "string", $largeStrField );
			}

			// make sure we can also read a "date" type
			$sql = "SELECT update_time FROM schema_versions";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			$dateField = $common->mDb->simpleFieldType( $result, 0 );
			$this->assertEquals( "date", $dateField );
			
			unset( $common );
		}
	} // test_FieldType
	
	/**
	 * Test db->fixBoolean()
	 * 
	 * This has already been tested through test_FetchRow et. al.
	 */
	public function test_FixBoolean()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
				
			$ids = $this->insertQueries( $dbType );
		
			// Test true/false values from queries
			$idsForIn = $ids[0] . ", " . $ids[1];
			$idsForCompare = array( $ids[0], $ids[1] );
			$sql = "SELECT bool_field, id FROM test_table WHERE id IN ( " . $idsForIn . " )";
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			while( $row = $common->mDb->fetchRow( $result ) )
			{
				$bool = $common->mDb->fixBoolean( $row[0] );
				$id =$row[1];
		
				$this->assertTrue( in_array( $id, $idsForCompare ) );
		
				// set the array to which we will compare the results
				$originArray = ($id === $ids[0]) ? $this->inputOne : $this->inputTwo;
					
				$this->assertInternalType( 'boolean', $bool );
		
				// just to be sure we got proper true/false values in and out of the database, do explicit checks given the knowledge we have about the input arrays
				if( $id === $ids[0] )
				{
					$this->assertTrue( $bool );
				}
				else
				{
					$this->assertFalse( $bool );
				}
			}
			
			// explicit tests with specific values
			if( "pgsql" === $dbType )
			{
				$trueValue = $common->mDb->fixBoolean( "t" );
				$falseValue = $common->mDb->fixBoolean( "f" );
				
				$this->assertInternalType( 'boolean', $trueValue );
				$this->assertInternalType( 'boolean', $falseValue );
				$this->assertTrue( $trueValue );
				$this->assertFalse( $falseValue );
				
				$trueValue = $common->mDb->fixBoolean( "true" );
				$falseValue = $common->mDb->fixBoolean( "false" );
				
				$this->assertInternalType( 'boolean', $trueValue );
				$this->assertInternalType( 'boolean', $falseValue );
				$this->assertTrue( $trueValue );
				$this->assertFalse( $falseValue );
			}
			else
			{
				$trueValue = $common->mDb->fixBoolean( 1 );
				$falseValue = $common->mDb->fixBoolean( 0 );
				
				$this->assertInternalType( 'boolean', $trueValue );
				$this->assertInternalType( 'boolean', $falseValue );
				$this->assertTrue( $trueValue );
				$this->assertFalse( $falseValue );
			}
			
			unset( $common );
		}
		
	} // test_FixBoolean
	
	/**
	 * Test db->fixBoolean()
	 *
	 * This has already been tested through test_FetchRow et. al.
	 */
	public function test_FixDbBoolean()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );

			$falseValues = array(
				$common->mDb->fixDbBoolean( "" ),
				$common->mDb->fixDbBoolean( 0 ),
				$common->mDb->fixDbBoolean( "0" ),
				$common->mDb->fixDbBoolean( false ),
				$common->mDb->fixDbBoolean( "false" ),
				$common->mDb->fixDbBoolean( "f" ),
				$common->mDb->fixDbBoolean( null )
			);
			
			// This is really overkill since anything not in the "false" list will return true
			$trueValues = array(
				$common->mDb->fixDbBoolean( "foo" ),
				$common->mDb->fixDbBoolean( 1 ),
				$common->mDb->fixDbBoolean( "1" ),
				$common->mDb->fixDbBoolean( true ),
				$common->mDb->fixDbBoolean( "true" ),
				$common->mDb->fixDbBoolean( "t" )
			);

			foreach( $falseValues as $index => $returnValue )
			{
				if( "pgsql" === $dbType )
				{
					$this->assertInternalType( "string", $returnValue );
					$this->assertEquals( "false", $returnValue );
				}
				else
				{
					$this->assertInternalType( "numeric", $returnValue );
					$this->assertEquals( 0, $returnValue );
				}
			}
			
			foreach( $trueValues as $index => $returnValue )
			{
				if( "pgsql" === $dbType )
				{
					$this->assertInternalType( "string", $returnValue );
					$this->assertEquals( "true", $returnValue );
				}
				else
				{
					$this->assertInternalType( "numeric", $returnValue );
					$this->assertEquals( 1, $returnValue );
				}
			}
			
			unset( $common );
		}
	} // test_FixDbBoolean
	
	/**
	 * Test db->insertBlank()
	 */
	public function test_InsertBlank()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
	
			// first, try the simple insert that has only an ID field.
			// This has already been tested many times above, but just to be sure...
			$simpleId = $common->mDb->insertBlank( "test_table", "id" );
			$this->assertInternalType( 'numeric', $simpleId );
			$this->assertGreaterThan( 0, $simpleId );
			
			// now do an insert with extra required fields (even though our test table does not actually require them to be not null
			$setupArray = array(
				'int_field' => $this->inputOne['int_field'],
				'str_field' => "'" . $common->mDb->escapeString( $this->inputOne['str_field'] ) . "'"
			);
			$complexId = $common->mDb->insertBlank( "test_table", "id", $setupArray );
			$this->assertInternalType( 'numeric', $complexId );
			$this->assertGreaterThan( 0, $complexId );
			$this->assertNotEquals( $simpleId, $complexId );
	
			$sql = "SELECT int_field, str_field, id FROM test_table WHERE id = " . $complexId;
			$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
			while( $row = $common->mDb->fetchRow( $result ) )
			{
				$int = $row[0];
				$str = $row[1];
				$id = $row[2];
				
				$this->assertInternalType( 'numeric', $int );
				$this->assertInternalType( 'string', $str );
				$this->assertInternalType( 'numeric', $id );
				
				$this->assertEquals( $this->inputOne['int_field'], $int );
				$this->assertEquals( $this->inputOne['str_field'], $str );
				$this->assertEquals( $complexId, $id );
			}
				
			unset( $common );
		}
	} // test_InsertBlank
	
	/**
	 * There are no explicit tests for beginTransaction() or endTransaction() because purposefully breaking out of transactions will require halting of execution
	 */
	
	/**
	 * Test db->getCurrentTimestamp()
	 */
	public function test_GetCurrentTimestamp()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
	
			// get truncated versions of the current time for comparison
			$currentTime = date( "Y-m-d H" );
			$altFormat = "YmdH";
			$epochCurrentTime = substr( time(), 0, 8 );
			$altCurrentTime = date( $altFormat );
			
			$defaultTime = $common->mDb->getCurrentTimestamp();
			$dbTime = $common->mDb->getCurrentTimestamp( "database" );
			$epochTime = $common->mDb->getCurrentTimestamp( "epoch" );
			$altTime = $common->mDb->getCurrentTimestamp( $altFormat );
			
			$this->assertEquals( $dbTime, $defaultTime );
			$this->assertEquals( 1, preg_match( "/^" . $epochCurrentTime . "/", $epochTime ) );
			$this->assertEquals( 1, preg_match( "/^" . $altCurrentTime . "/", $altTime ) );
			
			if( "oracle" === $dbType )
			{
				$this->assertEquals( 1, preg_match( "/^TO_DATE\( '" . $currentTime . "/", $dbTime ) );
			}
			else
			{
				$this->assertEquals( 1, preg_match( "/^" . $currentTime . "/", $dbTime ) );
			}
			
			unset( $common );
		}
	} // test_GetCurrentTimestamp
	
	/**
	 * Tests for the schema upgrade system. These have to be somewhat fabricated.
	 */
	
	/**
	 * Test db->getCurrentVersion()
	 * 
	 * We aren't going to test the condition that doesn't find an upgrade table ($returnValue = -1)
	 */
	public function test_GetCurrentVersion()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			$version = $common->mDb->getCurrentVersion();
			
			$this->assertGreaterThan( 0, $version );
				
			unset( $common );
		}
	} // test_GetCurrentVersion
	
	/**
	 * Test db->recordSchemaChange()
	 */
	public function test_RecordSchemaChange()
	{
		foreach( $this->dbTypes as $dbType => $dbClass )
		{
			$common = new AiCommon( $dbType );
			$version = $common->mDb->getCurrentVersion();
			$nextVersion = $version + 1;
			$this->assertGreaterThan( 0, $version );
			
			$common->mDb->recordSchemaChange( "foo", $nextVersion );
			$newVersion = $common->mDb->getCurrentVersion();
			$this->assertEquals( $version, $newVersion );
			
			$common->mDb->recordSchemaChange( "add", $nextVersion );
			$upVersion = $common->mDb->getCurrentVersion();
			$this->assertEquals( $nextVersion, $upVersion );
			
			$common->mDb->recordSchemaChange( "delete", $nextVersion );
			$downVersion = $common->mDb->getCurrentVersion();
			$this->assertEquals( $version, $downVersion );
	
			unset( $common );
		}
	} // test_RecordSchemaChange
	
	/**
	 * The remainder of the schema upgrade file methods require that they be run from the 'updates' directory,
	 *   so we can't run tests on them without halting execution
	 */
	
	/**
	 * oracle clob tests
	 */
	
	/**
	 * Test db->updateLob() and db->clobToString()
	 */
	public function test_UpdateLob_ClobToString()
	{
		$common = new AiCommon( "oracle" );
		$id = $common->mDb->insertBlank( "test_table", "id" );
		// make sure the inserted ID looks sane before continuing
		$this->assertInternalType( 'numeric', $id );
		$this->assertGreaterThan( 0, $id );
		
		// Returning for non-empty clob data works as expected
		$common->mDb->updateLob( "test_table", "id", $id, "large_str_field", $this->inputOne['large_str_field'], true );
		$selectSql = "SELECT large_str_field, id FROM test_table WHERE id = " . $id;
		$result = $common->mDb->query( $selectSql, __FILE__, __LINE__ );
		$row = $common->mDb->fetchRow( $result );
		$str = $common->mDb->clobToString( $row[0] );
		$this->assertEquals( $this->inputOne['large_str_field'], $str );
		$this->assertEquals( $id, $row[1] );
		
		// Returning empty for clob data works as expected
		$common->mDb->updateLob( "test_table", "id", $id, "large_str_field", "", true );
		$result = $common->mDb->query( $selectSql, __FILE__, __LINE__ );
		$row = $common->mDb->fetchRow( $result );
		$str = $common->mDb->clobToString( $row[0] );
		$this->assertEquals( "", $str );
		$this->assertEquals( $id, $row[1] );
		
		// Returning a string from a varchar field works as expected when we tell the system to get it as a clob
		$updateSql = "UPDATE test_table SET str_field = '" . $common->mDb->escapeString( $this->inputOne['str_field'] ) . "' WHERE id = " . $id;
		$common->mDb->query( $updateSql, __FILE__, __LINE__ );
		$nonClobSelectSql = "SELECT str_field, id FROM test_table WHERE id = " . $id;
		$result = $common->mDb->query( $nonClobSelectSql, __FILE__, __LINE__ );
		$row = $common->mDb->fetchRow( $result );
		$str = $common->mDb->clobToString( $row[0] );
		$this->assertEquals( $this->inputOne['str_field'] , $str );
		$this->assertEquals( $id, $row[1] );
		
	} // test_UpdateLob_ClobToString
	
	
	
	/**
	 * Helper methods for the tester class. Methods below here are not tests, although they contain assertions to validate the sanity of the data
	 */
	
	/**
	 * Inserts the default data into the database for later retrieval.
	 * Will return an array with the inserted IDs.
	 *
	 * @return	array
	 * @param	string	$dbType		The database type to INSERT into
	 */
	public function insertQueries( $dbType )
	{
		$returnValue = array();
	
		$common = new AiCommon( $dbType );
	
		// Get two blank records and make sure they look valid before continuing
		// make sure that they are not string integers for the === comparison below
		$returnValue[0] = $common->mDb->insertBlank( "test_table", "id" );
		$returnValue[1] = $common->mDb->insertBlank( "test_table", "id" );
	
		$this->assertInternalType( 'numeric', $returnValue[0] );
		$this->assertInternalType( 'numeric', $returnValue[1] );
		$this->assertGreaterThan( 0, $returnValue[0] );
		$this->assertGreaterThan( 0, $returnValue[1] );
		$this->assertNotEquals( $returnValue[0], $returnValue[1] );
	
		// setup our update queries
		$sqlOne = "
		UPDATE	test_table
		SET		int_field = " . $this->inputOne['int_field'] . ",
					str_field = '" . $common->mDb->escapeString( $this->inputOne['str_field'] ) . "',
					bool_field = " . $common->mDb->fixDbBoolean( $this->inputOne['bool_field'] ) . "
		WHERE		id = " . $returnValue[0] . "
		";
	
		$sqlTwo = "
		UPDATE	test_table
		SET		int_field = " . $this->inputTwo['int_field'] . ",
					str_field = '" . $common->mDb->escapeString( $this->inputTwo['str_field'] ) . "',
					bool_field = " . $common->mDb->fixDbBoolean( $this->inputTwo['bool_field'] ) . "
		WHERE		id = " . $returnValue[1] . "
		";
	
		$common->mDb->beginTransaction( __FILE__, __LINE__ );
		$common->mDb->query( $sqlOne, __FILE__, __LINE__ );
		$common->mDb->query( $sqlTwo, __FILE__, __LINE__ );
		$common->mDb->endTransaction( __FILE__, __LINE__ );
	
		return $returnValue;
	} // insertQueries
	
} // end class

// Call self::main() if this source file is executed directly.
if( PHPUnit_MAIN_METHOD == "testAiConnectors::main" )
{
	testAiConnectors::main();
}
