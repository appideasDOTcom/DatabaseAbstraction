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

$common = new AiCommon();

// Check for command line input issues
$error = "
There was a problem running updates. Proper usage:
" . $argv[0] . " upgrade|downgrade
";
$validArgs = array( "upgrade", "downgrade" );
if( 2 !== $argc || !in_array( $argv[1], $validArgs ) )
{
	echo $error . "\n";
	exit();
}

// Make sure the basics are setup for schema updating
$versionNumber = $common->mDb->getCurrentVersion();
if( $versionNumber < 0 )
{
	echo "
The upgrade process requires a table called 'schema_versions' but you do not appear to have one.
";
	exit();
}

// Perform the upgrade or downgrade
if( "upgrade" === $argv[1] )
{
	$result = $common->mDb->doUpgrade( $versionNumber, "up" );
}
else
{
	$result = $common->mDb->doUpgrade( $versionNumber, "down" );
}

echo $result . "\n";
exit();
