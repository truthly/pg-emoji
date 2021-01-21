CREATE OR REPLACE FUNCTION emoji.decode(text)
RETURNS bytea
IMMUTABLE
STRICT
LANGUAGE sql AS $$
WITH
q1 AS (
  SELECT
    $1 AS input,
    10 AS nbits
),
q2 AS (
  SELECT string_agg(chars.emoji_bits::text,'' ORDER BY i)::varbit AS bits
  FROM q1
  CROSS JOIN generate_series(1,length(input)-1) AS i
  JOIN emoji.chars ON chars.emoji_char = substr(input,1+i,1)
),
q3 AS (
  SELECT decode(string_agg(lpad(to_hex(substring(bits,1+length(bits)%8+i*8,8)::bit(8)::integer),2,'0'),'' ORDER BY i),'hex') AS padded
  FROM q2
  CROSS JOIN generate_series(0,length(bits)/8-1) AS i
),
q4 AS (
  SELECT
    CASE
      WHEN get_bit(emoji_bits,0) = 1 AND get_byte(padded,0) = 0 THEN substring(padded,2)
      WHEN get_bit(emoji_bits,0) = 0 THEN padded
    END AS decoded,
    substring(emoji_bits,2) AS checksum
  FROM q1
  CROSS JOIN q3
  JOIN emoji.chars AS checksum ON checksum.emoji_char = substr(input,1,1)
),
q5 AS (
  SELECT
    decoded,
    checksum,
    sha512(decoded)
  FROM q4
)
SELECT decoded
FROM q5
WHERE checksum = get_byte(sha512,0)::bit(8)||get_byte(sha512,1)::bit(1)
$$;
