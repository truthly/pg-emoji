CREATE OR REPLACE FUNCTION emoji.to_text(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
SELECT convert_from(emoji.decode($1),'utf8')
$$;
