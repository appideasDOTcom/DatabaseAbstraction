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
$cmd = "phpdoc --force  --sourcecode --title 'APP(ideas) DatabaseAbstraction' --directory ../classes --target phpdoc";

system( $cmd );

$fp = fopen( "phpdoc/css/template.css", "a" );

$css = "
li#charts-menu, li#reports-menu, footer.row-fluid section.span4
{
	display: none;
}
";
fwrite( $fp, $css );

