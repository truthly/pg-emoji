CREATE OR REPLACE FUNCTION emoji.from_text(text)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
SELECT emoji.encode(convert_to($1,'utf8'))
$$;
