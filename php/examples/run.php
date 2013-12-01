#!/usr/local/bin/php -q
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
require_once( "../setup.php" );
require_once( "base/AiCommon.php" );

prompt();

// Prompt the user for input
function prompt()
{
	echo getCommands();
	$ch = fopen( "php://stdin", "r"  );
	$response = trim( fgets( $ch ) );
	fclose( $ch );
	runCommand( $response );
} // prompt

// List the available functions
function getCommands()
{
	return "
1.  Insert query. insert()
2.  Update query. update()
3.  Delete query. delete()
4.  Insert blank records (IDs only). insertBlank()
5.  Empty test table. emptyTest()
6.  Get a specific record from the test table. getRecord()
7.  Get all records from the test table. getAllRecords()
8.  Get a specific record from the test table by associative array. getRecordByArray()
9.  Get boolean values from the test table. getBooleans()
10. Update a CLOB field (Oracle only). updateClob()
		
Type in a number and press ENTER to run a command.
Press ctrl-c or 'q' to exit.

";
} // getCommands

// call a function to run
function runCommand( $response )
{
	echo "\n--------------------\n";
	if( "q" === strtolower( $response ) )
	{
		exit();
	}
	if( !is_numeric( $response ) || $response < 1 || $response > 10 )
	{
		echo "\nI don't know what option an option '" . $response . "' Please choose a valid option.\n";
		prompt();
	}
	
	switch( $response )
	{
		case 1:
			insert();
			break;
		case 2:
			update();
			break;
		case 3:
			getIdPrompt( "delete" );
			break;
		case 4:
			insertBlank();
			break;
		case 5:
			emptyTest();
			break;
		case 6:
			getIdPrompt( "getRecord" );
			break;
		case 7:
			getAllRecords();
			break;
		case 8:
			getIdPrompt( "getRecordByArray" );
			break;
		case 9:
			getBooleans();
			break;
		case 10:
			updateClob();
			break;
	}
	echo "\n--------------------\n";
	prompt();
} // runCommand

// Run an insert query
function insert()
{
	$common = new AiCommon();
	echo "Running insert() function from line " . __LINE__ . "...\n";
	
	// insert two new records
	$queries = array(
		"INSERT INTO test_table ( id, int_field, str_field, bool_field ) VALUES ( DEFAULT, 1, '" . $common->mDb->escapeString( "A 'test' \"String\"" ) . "', " . $common->mDb->fixDbBoolean( 1 ) . " )",
		"INSERT INTO test_table ( id, int_field, str_field, bool_field ) VALUES ( DEFAULT, 1, '" . $common->mDb->escapeString( "Another 'test' \"String\"" ) . "', " . $common->mDb->fixDbBoolean( 1 ) . " )"
	);
	
	foreach( $queries as $index => $sql )
	{
		echo "Executing query:\n" . stripslashes( $sql ) . "\n";
		$common->mDb->query( $sql, __FILE__, __LINE__ );
	}
	
	echo "Now retrieving all records...\n";
	getAllRecords();
	
} // insert

// run an update query
function update()
{
	$common = new AiCommon();
	echo "Running update() function from line " . __LINE__ . "...\n";
	
	$ids = array();
	$ids[0] = $common->mDb->insertBlank( "test_table", "id" );
	$ids[1] = $common->mDb->insertBlank( "test_table", "id" );
	echo "Created records with IDs: " . implode( ", ", $ids ) . "\n";
	
	foreach( $ids as $index => $id )
	{
		$updateSql = "UPDATE test_table SET int_field = " . ($index + 12) . ", str_field = 'An updated string for record with an ID of " . $id . "' WHERE id = " . $id;
		echo "Executing query:\n" . stripslashes( $updateSql ) . "\n";
		$common->mDb->query( $updateSql, __FILE__, __LINE__ );
	}
	
	echo "Now retrieving all records...\n";
	getAllRecords();

} // update

// Delete a record by specific ID
function delete( $id )
{
	$common = new AiCommon();
	echo "Running delete() function from line " . __LINE__ . "...\n";
	
	$deleteSql = "DELETE FROM test_table WHERE id = " . $id;
	echo "Executing query:\n" . stripslashes( $deleteSql ) . "\n";
	$common->mDb->query( $deleteSql, __FILE__, __LINE__ );
	
	echo "Now retrieving all records...\n";
	getAllRecords();
	
} // delete

// Insert a blank record and get its ID
function insertBlank()
{
	$common = new AiCommon();
	echo "Running insertBlank() function from line " . __LINE__ . "...\n";
	
	$ids = array();
	$ids[0] = $common->mDb->insertBlank( "test_table", "id" );
	$ids[1] = $common->mDb->insertBlank( "test_table", "id" );
	echo "Created empty records with IDs: " . implode( ", ", $ids ) . "\n";
	
	echo "Now retrieving all records...\n";
	getAllRecords();
	
} // insertBlank

// Empty the test_table
function emptyTest()
{
	$common = new AiCommon();
	echo "Running emptyTest() function from line " . __LINE__ . "...\n";
	
	// Delete all records
	$queries = array(
			"DELETE FROM test_table"
	);
	
	foreach( $queries as $index => $sql )
	{
		echo "Executing query:\n" . stripslashes( $sql ) . "\n";
		$common->mDb->query( $sql, __FILE__, __LINE__ );
	}
	
	echo "Now retrieving all records...\n";
	getAllRecords();
	
} // emptyTest

// Get a specific record by ID
function getRecord( $id )
{
	$common = new AiCommon();
	echo "Running getRecord() function from line " . __LINE__ . "...\n";
	
	$sql = "SELECT * FROM test_table WHERE id = " . $id;
	echo "Executing query:\n" . stripslashes( $sql ) . "\n";
	echo "Results:\n";
	
	$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
	$fields = $common->mDb->numFields( $result );
	while( $row = $common->mDb->fetchRow( $result ) )
	{
		for( $i = 0; $i < $fields; $i++ )
		{
			// Oracle needs to have its CLOB values converted to string
			if( "oracle" === $common->mDbMethod && "binary" === $common->mDb->simpleFieldType( $result, $i ) )
			{
				// show field name = stored value
				echo $common->mDb->fieldName( $result, $i ) . " = " . $common->mDb->clobToString( $row[$i] ) . "\n";
			}
			else
			{
				// show field name = stored value
				echo $common->mDb->fieldName( $result, $i ) . " = " . $row[$i] . "\n";
			}
		}
		echo "\n";
	}
	
} // getRecord

// get all records from the test_table
function getAllRecords()
{
	$common = new AiCommon();
	echo "Running getAllRecords() function from line " . __LINE__ . "...\n";
	
	$queries = array(
			"SELECT * FROM test_table ORDER BY id"
	);
	
	foreach( $queries as $index => $sql )
	{
		echo "Executing query:\n" . stripslashes( $sql ) . "\n";
		echo "Results:\n";
		$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
		// This query may have a varying number of fields, so walk through them rather than specifying a fixed number
		$fields = $common->mDb->numFields( $result );
		while( $row = $common->mDb->fetchRow( $result ) )
		{
			for( $i = 0; $i < $fields; $i++ )
			{
				// Oracle needs to have its CLOB values converted to string
				if( "oracle" === $common->mDbMethod && "binary" === $common->mDb->simpleFieldType( $result, $i ) )
				{
					// show field name = stored value
					echo $common->mDb->fieldName( $result, $i ) . " = " . $common->mDb->clobToString( $row[$i] ) . "\n";
				}
				else
				{
					// show field name = stored value
					echo $common->mDb->fieldName( $result, $i ) . " = " . $row[$i] . "\n";
				}
			}
			echo "\n";
		}
	}
} // getAllRecords

// Shows the database-stored values and the responding PHP value (1 for true, blank for false)
function getBooleans()
{
	$common = new AiCommon();
	echo "Running getBooleans() function from line " . __LINE__ . "...\n";
	
	$sql = "SELECT id, bool_field FROM test_table";
	
	echo "Executing query:\n" . stripslashes( $sql ) . "\n";
	echo "Results (ID:database value:PHP value):\n";
	$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
	while( $row = $common->mDb->fetchRow( $result ) )
	{
		echo $row[0] . ":" . $row[1] . ":" . $common->mDb->fixBoolean( $row[1] ) . "\n";
	}
	
} // getBooleans

// Get a specific record and show it by associative array
function getRecordByArray( $id )
{
	$common = new AiCommon();
	echo "Running getRecordByArray() function from line " . __LINE__ . "...\n";
	
	$sql = "SELECT * FROM test_table WHERE id = " . $id;
	echo "Executing query:\n" . stripslashes( $sql ) . "\n";
	echo "Results:\n";
	
	$result = $common->mDb->query( $sql, __FILE__, __LINE__ );
	while( $row = $common->mDb->fetchArray( $result ) )
	{
		echo "Result produced this array:\n" . print_r( $row, true ) . "\n";
		echo "Values:\n";
		foreach( $row as $key => $value )
		{
			if( !is_numeric( $key ) )
			{
				echo $key . " = ";

				// Oracle needs to have its CLOB values converted to string
				if( "oracle" === $common->mDbMethod && "object" === gettype( $value ) )
				{
					// show field name = stored value
					echo $common->mDb->clobToString( $value ) . "\n";
				}
				else
				{
					// show field name = stored value
					echo $value . "\n";
				}
			}

		}
		
		echo "\n";
	}
	
	
} // getRecordByArray

// update an Oracle CLOB
function updateClob()
{
	$common = new AiCommon();
	
	if( "oracle" !== $common->mDbMethod )
	{
		echo "This will only work with Oracle.\n";
		return;
	}
	
	echo "Running updateClob() function from line " . __LINE__ . "...\n";
	
	$id = $common->mDb->insertBlank( "test_table", "id" );
	echo "Inserted blank record with ID: " . $id . "\n";
	$str = "A 'test' \"String\" for CLOB";
	echo "Running updateLob() for ID: " . $id . " with string: " . $str . "\n";
	
	$common->mDb->updateLob( "test_table", "id", $id, "large_str_field",$str, true );
	
	getRecord( $id );

} // updateClob


/////////////////////////////////////////////////

// prompt for an ID for functions that need a specific record
function getIdPrompt( $action )
{
	$common = new AiCommon();
	echo "
Type an ID from the following list and then press ENTER:
		
";
	
	$result = $common->mDb->query( "SELECT id, str_field FROM test_table ORDER BY id", __FILE__, __LINE__ );
	while( $row = $common->mDb->fetchArray( $result ) )
	{
		echo $row['id'] . ": " . $row['str_field'] . "\n";
	}
	
	echo "
Your selection:
";
	
	$ch = fopen( "php://stdin", "r"  );
	$id = trim( fgets( $ch ) );
	fclose( $ch );
	
	if( idIsValid( $id ) )
	{
		switch( $action )
		{
			case "delete":
				delete( $id );
				break;
			case "getRecord":
				getRecord( $id );
				break;
			case "getRecordByArray":
				getRecordByArray( $id );
				break;
		}
	}
	else
	{
		echo "\n'" . $id . "' is not a valid ID. Starting over.\n";
		prompt();
	}
}

// validate an ID from user input 
function idIsValid( $id )
{
	if( !is_numeric( $id ) )
	{
		return false;
	}
	$common = new AiCommon();
	$result = $common->mDb->query( "SELECT COUNT(*) FROM test_table WHERE id =  " . $id, __FILE__, __LINE__ );
	while( $row = $common->mDb->fetchRow( $result ) )
	{
		if( 1 === (int)$row[0] )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	
}

