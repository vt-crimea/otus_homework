DROP TABLE IF EXISTS documents;
create table documents(id bigint generated always as identity, kind int, name varchar);
											
DROP TABLE IF EXISTS doclines;											
create TABLE doclines(id bigint generated always as identity, docid bigint, description varchar);

CREATE OR REPLACE FUNCTION random_string(
  num INTEGER,
  chars TEXT default '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  res_str TEXT := '';
BEGIN
  IF num < 1 THEN
      RAISE EXCEPTION 'Invalid length';
  END IF;
  FOR __ IN 1..num LOOP
    res_str := res_str || substr(chars, floor(random() * length(chars))::int + 1, 1);
  END LOOP;
  RETURN res_str;
END $$;


WITH inserted
AS
(
insert INTO documents(name, kind)
SELECT random_string(10) AS name, 1 AS kind
FROM generate_series(1, 1000) 
RETURNING id
)
INSERT INTO doclines (docid, description)
SELECT i.id AS docid, l.description
FROM inserted i
JOIN LATERAL (
	SELECT random_string(20) AS description
	FROM generate_series(1, 3::int) gs
) l ON TRUE;

WITH inserted
AS
(
insert INTO documents(name, kind)
SELECT random_string(10) AS name, 2 AS kind
FROM generate_series(1, 100) 
RETURNING id
)
INSERT INTO doclines (docid, description)
SELECT i.id AS docid, l.description
FROM inserted i
JOIN LATERAL (
	SELECT random_string(20) AS description
	FROM generate_series(1, 2::int) gs
) l ON TRUE;

WITH inserted
AS
(
insert INTO documents(name, kind)
SELECT random_string(10) AS name, 3 AS kind
FROM generate_series(1, 5) 
RETURNING id
)
INSERT INTO doclines (docid, description)
SELECT i.id AS docid, l.description
FROM inserted i
JOIN LATERAL (
	SELECT random_string(20) AS description
	FROM generate_series(1, 2::int) gs
) l ON TRUE;


CREATE OR REPLACE FUNCTION test_func(_p_kind int, _p_somevar varchar)
 RETURNS int
 LANGUAGE plpgsql
AS $function$
DECLARE 
	_v_ref1 refcursor = 'cursorTest';
	_v_rec record;
BEGIN
	
	FOR _v_rec in SELECT * FROM documents WHERE kind = _p_kind
	LOOP 
		DROP TABLE IF EXISTS _tmp_doclines;
		CREATE TEMP TABLE _tmp_doclines
		AS
		SELECT *
		FROM doclines
		WHERE docid = _v_rec.id;

		RAISE NOTICE '%', _v_rec.name;
	END LOOP;
	
	
	
	RETURN 1;


	
end;
$function$
;
