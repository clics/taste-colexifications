sqlite3 lexibank.sqlite3 <<EOF
.mode csv
.headers on

-- selection of the two joined tables
-- check for colexifications in the last column
SELECT 
  ROW_NUMBER() OVER() as ID,
  table_a.LanguageName, 
  table_a.Language, 
  table_a.Latitude,
  table_a.Longitude,
  table_a.Family, 
  table_a.Concept||'+'||table_b.ConceptB as Parameter, 
  table_a.Segments, 
  table_b.SegmentsB,
  table_a.Segments = table_b.SegmentsB as Value
-- query four words in the first table
FROM
  (
    SELECT 
      l.cldf_name as LanguageName,
      l.cldf_latitude as Latitude,
      l.cldf_longitude as Longitude, 
      l.cldf_glottocode as Language, 
      l.family as Family, 
      p.cldf_name as Concept, 
      f.cldf_segments as Segments
    FROM 
      formtable as f, 
      languagetable as l, 
      parametertable as p
    WHERE
      p.cldf_id = f.cldf_parameterReference
        AND
      l.cldf_id = f.cldf_languageReference
        AND
      (
        p.cldf_name = 'SOUR' 
          OR p.cldf_name = 'BITTER' 
          OR p.cldf_name = 'SWEET' 
          OR p.cldf_name = 'SALTY'
      )  
) as table_a
-- query the words in the second table to join them
INNER JOIN 
  (
    SELECT 
      l2.cldf_glottocode as LanguageB,
      p2.cldf_name as ConceptB,
      f2.cldf_segments as SegmentsB
    FROM
      formtable as f2,
      parametertable as p2,
      languagetable as l2
    WHERE
      f2.cldf_languageReference = l2.cldf_id
        AND
      f2.cldf_parameterReference = p2.cldf_id
        AND
      (
        ConceptB = 'SOUR' 
          OR ConceptB = 'BITTER'
          OR ConceptB = 'SWEET'
          OR ConceptB = 'SALTY'
      )
  ) as table_b
-- conditions for the output, limit to the same language
-- and also to diverging concepts
ON
  table_a.Language = table_b.LanguageB
    AND
  table_a.Concept != table_b.ConceptB
    AND (
      (
        table_a.Concept = 'BITTER' 
          AND table_b.ConceptB == 'SALTY'
      )
        OR
      (
        table_a.Concept = 'BITTER' 
          AND table_b.ConceptB == 'SOUR'
      )
        OR
      (
        table_a.Concept = 'BITTER' 
          AND table_b.ConceptB == 'SWEET'
      )
        OR
      (
        table_a.Concept = 'SALTY' 
          AND table_b.ConceptB == 'SOUR'
      )
        OR
      (
        table_a.Concept = 'SALTY' 
          AND table_b.ConceptB == 'SWEET'
      )
        OR
      (
        table_a.Concept = 'SOUR' 
          AND table_b.ConceptB == 'SWEET'
      )
    )
-- order to retrieve data for each language in a block
ORDER BY 
  Language, 
  Concept
;
EOF
