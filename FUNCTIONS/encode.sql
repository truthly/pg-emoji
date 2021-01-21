CREATE OR REPLACE FUNCTION emoji.encode(bytea)
RETURNS text
IMMUTABLE
STRICT
LANGUAGE sql AS $$
WITH
q1 AS (
  SELECT
    $1 AS input,
    10 AS nbits,
    sha512($1)
),
q2 AS (
  SELECT
    right(input::text,-1)::varbit AS bitstring
  FROM q1
),
q3 AS (
  SELECT
    repeat('0',nbits-length(bitstring)%nbits)::varbit || bitstring AS padded_bitstring
  FROM q1,q2
),
q4 AS (
  SELECT array_agg(substring(padded_bitstring,1+i*nbits,nbits)) AS emoji_bitss
  FROM q1
  CROSS JOIN q3
  CROSS JOIN LATERAL generate_series(0,length(padded_bitstring)/nbits-1) AS i
)
SELECT
  checksum.emoji_char || array_to_string(array_agg(chars.emoji_char ORDER BY ORDINALITY),'')
FROM q1
CROSS JOIN q4
CROSS JOIN unnest(emoji_bitss) WITH ORDINALITY
JOIN emoji.chars ON chars.emoji_bits = unnest
JOIN emoji.chars AS checksum ON checksum.emoji_bits = ((length(input)*8)%10 <= 2)::integer::bit||get_byte(sha512,0)::bit(8)||get_byte(sha512,1)::bit(1)
GROUP BY checksum.emoji_char
$$;
