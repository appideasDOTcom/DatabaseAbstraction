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
class DbUpdater1
{
	public function __construct()
	{
	}

	public function upgrade()
	{
		return array(
			"
			CREATE TABLE `test_table` (
			`id` int(11) NOT NULL auto_increment,
			`int_field` int(11) NOT NULL default '0',
			`str_field` text,
			`large_str_field` longtext,
			`bool_field` int(11) NOT NULL default '0',
			PRIMARY KEY  (`id`)
			)
			"
		);
	}

	public function downgrade()
	{
		return array(
				"
			DROP TABLE test_table
			"
		);
	}
}