CREATE TABLE schema_versions
(
  version_number integer DEFAULT 0,
  update_time timestamp without time zone DEFAULT now()
);