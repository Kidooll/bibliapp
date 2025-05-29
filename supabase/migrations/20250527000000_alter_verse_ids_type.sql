-- Remove a foreign key constraint existente
ALTER TABLE bookmarks DROP CONSTRAINT IF EXISTS bookmarks_verse_ids_fkey;

-- Altera o tipo da coluna verse_ids para array de bigint
ALTER TABLE bookmarks 
ALTER COLUMN verse_ids TYPE bigint[] 
USING ARRAY[verse_ids]::bigint[];

-- Adiciona um índice GIN para melhorar performance de buscas em arrays
CREATE INDEX IF NOT EXISTS bookmarks_verse_ids_gin_idx ON bookmarks USING GIN (verse_ids);

-- Note: Não recriamos a foreign key constraint porque não podemos ter uma FK
-- entre um array e uma coluna única. A integridade referencial precisará
-- ser garantida na aplicação.
