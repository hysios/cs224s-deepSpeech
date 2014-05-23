CREATE TABLE candidate (
    lattice_id    TEXT,     -- which lattice (document) it belongs
    source        TEXT,     -- dc / nc / ...
    starts        BIGINT,   -- start from 1
    ends          BIGINT,   -- start from 0, according to source
    word          TEXT,
    confirm       INT,      --  -1 / 0 (sil) / 1
    candidate_id  BIGINT,   -- unique, generated by loading script
    is_true       BOOLEAN,  -- to predict
    id            BIGINT
    )  DISTRIBUTED BY (lattice_id);

CREATE TABLE f_cand_2gram (
  lattice_id    TEXT,
  candidate_id  BIGINT,
  ngram         TEXT
  )  DISTRIBUTED BY (lattice_id);

CREATE TABLE transcript (
    lattice_id    TEXT,     -- which lattice (document) it belongs
    wordid        TEXT,
    word          TEXT
    )  DISTRIBUTED BY (lattice_id);

CREATE TABLE candidate_label (
    lattice_id    TEXT,     -- which lattice (document) it belongs
    candidate_id  BIGINT,   -- unique, generated by loading script
    is_true       BOOLEAN   -- supervision label
  ) DISTRIBUTED BY (lattice_id);

CREATE TABLE transcript_array (
    lattice_id    TEXT,     -- which lattice (document) it belongs
    words         TEXT[]
) DISTRIBUTED BY (lattice_id);

-- CREATE TABLE transcript_array AS
--   SELECT  lattice_id, 
--           ARRAY_AGG(word ORDER BY wordid) AS words
--   FROM    transcript
--   GROUP BY lattice_id
-- DISTRIBUTED BY (lattice_id);
