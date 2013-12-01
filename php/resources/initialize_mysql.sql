CREATE TABLE `schema_versions` (
  `version_number` int(11) NOT NULL default '0',
  `update_time` timestamp NOT NULL default CURRENT_TIMESTAMP
);
