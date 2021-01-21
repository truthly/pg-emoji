CREATE EXTENSION IF NOT EXISTS emoji;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
random_bytes bytea;
encoded text;
decoded bytea;
decoded_text text;
_ok integer := 0;
_tests integer := 100;
BEGIN
FOR i IN 1.._tests LOOP
  random_bytes := gen_random_bytes(i);
  encoded := emoji.encode(random_bytes);
  decoded := emoji.decode(encoded);
  IF decoded = random_bytes THEN
    _ok := _ok + 1;
  ELSE
    RAISE WARNING '% % -> % -> %', i, random_bytes, encoded, decoded;
  END IF;
  encoded := emoji.from_text(random_bytes::text);
  decoded_text := emoji.to_text(encoded);
  IF decoded_text = random_bytes::text THEN
    _ok := _ok + 1;
  ELSE
    RAISE WARNING '% % -> % -> %', i, random_bytes, encoded, decoded_text;
  END IF;
END LOOP;
IF _ok = _tests*2 THEN
  RAISE NOTICE 'OK';
ELSE
  RAISE EXCEPTION 'ERROR';
END IF;
END
$$;
