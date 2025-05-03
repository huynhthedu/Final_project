
-- I - create primary keys for tables

ALTER TABLE library ADD COLUMN IF NOT EXISTS id SERIAL PRIMARY KEY;

ALTER TABLE instruction  ADD COLUMN IF NOT EXISTS id SERIAL PRIMARY KEY;

ALTER TABLE institution
ADD CONSTRAINT pk_institution PRIMARY KEY (unitid);

ALTER TABLE sector
ADD CONSTRAINT pk_sector PRIMARY KEY (sector);

ALTER TABLE state
ADD CONSTRAINT pk_state PRIMARY KEY (stabbr);

ALTER TABLE "library_D"
ADD CONSTRAINT pk_item PRIMARY KEY (lb_id);

ALTER TABLE "instructional"
ADD CONSTRAINT pk_instructionalid PRIMARY KEY (instructional);

ALTER TABLE "instructional_id"
ADD CONSTRAINT pk_instructionalid PRIMARY KEY ("Instructional_id");

ALTER TABLE gender
ADD CONSTRAINT pk_gender PRIMARY KEY ("gender_id");

-- II  create foreign keys for tables

ALTER TABLE instruction 
ADD CONSTRAINT fk_institution
FOREIGN KEY ("UNITID")
REFERENCES institution (unitid);

ALTER TABLE instruction 
ADD CONSTRAINT fk_instructional
FOREIGN KEY ("Item")
REFERENCES instructional (instructional);

ALTER TABLE instructional 
ADD CONSTRAINT fk_instructionalid 
FOREIGN KEY ("Instructional_id")
REFERENCES "instructional_id" ("Instructional_id");

ALTER TABLE instructional 
ADD CONSTRAINT fk_gender
FOREIGN KEY ("Gender_ID")
REFERENCES gender ("gender_id");

ALTER TABLE final_project_evaluation
ADD CONSTRAINT fk_evaluation
FOREIGN KEY (unitid)
REFERENCES institution (unitid);

ALTER TABLE library
ADD CONSTRAINT fk_institution
FOREIGN KEY ("UNITID")
REFERENCES institution (unitid);

ALTER TABLE library
ADD CONSTRAINT fk_item
FOREIGN KEY ("Item")
REFERENCES "library_D" (lb_id);


ALTER TABLE institution
ADD CONSTRAINT fk_sector
FOREIGN KEY (sector)
REFERENCES "sector" (sector);

ALTER TABLE institution
ADD CONSTRAINT fk_state
FOREIGN KEY ("stabbr")
REFERENCES "state" ("stabbr");


-- Create library data 
DROP VIEW IF EXISTS library_view;
CREATE VIEW library_view AS
SELECT 
    lb."UNITID" AS unitid, 
    ld."name" AS item, 
    CAST(lb."Year" AS text) AS year,  
    lb."Value" AS value, 
    inst.instnm AS institution, 
    inst.stabbr, 
    st.name AS state, 
    sec.name AS sector,
    ROW_NUMBER() OVER (ORDER BY lb."UNITID", ld."name", lb."Year") AS id
FROM library lb
JOIN "library_D" ld ON lb."Item" = ld.lb_id
JOIN institution inst ON CAST(lb."UNITID" AS integer) = inst.unitid
JOIN state st ON inst.stabbr = st.stabbr
JOIN sector sec ON inst.sector = sec."sector"


-- Create faculty data
DROP VIEW IF EXISTS faculty_view;
CREATE VIEW faculty_view AS
SELECT 
    fc."UNITID" AS unitid, 
    id."varTitle" AS item, 
    CAST(fc."Year" AS text) AS year,  
    fc."Value" AS value, 
    inst.instnm AS institution, 
    inst.stabbr, 
    st.name AS state, 
    sec."name" AS sector,
    td."Tenure" as tenure,
    gd."gender",
    ROW_NUMBER() OVER (ORDER BY fc."UNITID", inst.instnm, fc."Year") AS id
FROM instruction fc
JOIN "instructional" ins ON fc."Item" = ins."instructional"
JOIN "tenure_id" td ON cast(fc."ARANK" as integer)= td."Tenure_ID"
JOIN "instructional_id" id ON ins."Instructional_id" = id."Instructional_id"
JOIN institution inst ON CAST(fc."UNITID" AS text) = CAST(inst.unitid AS text)
JOIN state st ON inst.stabbr = st.stabbr
JOIN sector sec ON inst.sector = sec."sector"
join gender gd on gd.gender_id = ins."Gender_ID"


-- IV Other queries

ALTER TABLE "institution" DROP CONSTRAINT "fk_sectors";

ALTER TABLE "instructional"
DROP COLUMN "Duration_ID";

ALTER TABLE instruction  ADD COLUMN IF NOT EXISTS id SERIAL PRIMARY KEY;

TRUNCATE TABLE library;

TRUNCATE table instruction;

ALTER TABLE library
ALTER COLUMN "UNITID" TYPE INTEGER USING "UNITID"::integer;

ALTER TABLE instruction
ALTER COLUMN "UNITID" TYPE INTEGER USING "UNITID"::integer;

SELECT * FROM "sector" WHERE "sector" = 0;

SELECT "UNITID"
FROM library
WHERE "UNITID" NOT IN (SELECT unitid FROM institution);

SELECT "sector" 
FROM "institution" 
WHERE "sector" NOT IN (SELECT "sector" FROM "sector");

SELECT "stabbr" 
FROM "institution" 
WHERE "stabbr" NOT IN (SELECT "stabbr" FROM "state");


delete  FROM library
WHERE "UNITID" NOT IN (SELECT unitid FROM institution);

delete  FROM instruction 
WHERE "UNITID" NOT IN (SELECT unitid FROM institution);

CREATE TABLE institutions AS
SELECT unitid, instnm, stabbr, sector
FROM institution;


SELECT unitid, COUNT(*)
FROM institution
GROUP BY unitid
HAVING COUNT(*) > 1;


ALTER TABLE institution 
ADD COLUMN comments VARCHAR(255);

ALTER TABLE institution 
ADD COLUMN grade INTEGER;

alter table final_project_evaluation
drop constraint final_project_evaluation_pkey

SELECT conname
FROM pg_catalog.pg_constraint
WHERE contype = 'p'  -- 'p' indicates a primary key constraint
  AND conrelid = 'final_project_evaluation'::regclass;

SELECT conname
FROM pg_catalog.pg_constraints
WHERE contype = 'p'  -- 'p' indicates a primary key constraint
  AND conrelid = 'final_project_evaluation'::regclass;


SELECT conname, confrelid::regclass AS foreign_table, af.attname AS foreign_column, cl.relname AS local_table, al.attname AS local_column
FROM pg_constraint AS c
JOIN pg_class AS cl ON cl.oid = c.conrelid
JOIN pg_class AS ft ON ft.oid = c.confrelid
JOIN pg_attribute AS al ON al.attnum = c.conkey[1] AND al.attrelid = cl.oid
JOIN pg_attribute AS af ON af.attnum = c.confkey[1] AND af.attrelid = ft.oid
WHERE cl.relname = 'institution' AND c.conname = 'fk_state';
