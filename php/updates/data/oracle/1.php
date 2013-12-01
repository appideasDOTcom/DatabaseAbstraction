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
			'
			CREATE TABLE "TEST_TABLE"
			(
				"ID" NUMBER NOT NULL ENABLE,
				"INT_FIELD" NUMBER DEFAULT 0,
				"STR_FIELD" VARCHAR2(255),
				"LARGE_STR_FIELD" CLOB,
				"BOOL_FIELD" NUMBER(1, 0) DEFAULT 1,
				CONSTRAINT "TEST_TABLE_PK" PRIMARY KEY ( "ID" ) ENABLE
			)
			',
				
			'
			CREATE SEQUENCE  "TEST_TABLE_SEQ"
				MINVALUE 1
				MAXVALUE 999999999999999999999999999
				INCREMENT BY 1
				START WITH 1
				CACHE 20
				NOORDER
				NOCYCLE
			',
				
			'
			CREATE OR REPLACE TRIGGER "TEST_TABLE_TRG"
				BEFORE INSERT ON "TEST_TABLE"
				FOR EACH ROW
				BEGIN
					SELECT "TEST_TABLE_SEQ".NEXTVAL INTO :NEW."ID" FROM DUAL;
				END;
			'
		);
	}

	public function downgrade()
	{
		return array(
			'
			DROP TRIGGER "TEST_TABLE_TRG"
			',
			'
			DROP SEQUENCE "TEST_TABLE_SEQ"
			',
			'
			DROP TABLE "TEST_TABLE"
			'
		);
	}
}