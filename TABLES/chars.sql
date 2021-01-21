CREATE TABLE emoji.chars (
emoji_id integer NOT NULL GENERATED ALWAYS AS IDENTITY,
emoji_bits varbit NOT NULL GENERATED ALWAYS AS ((emoji_id-1)::bit(10)) STORED,
emoji_char char NOT NULL,
PRIMARY KEY (emoji_id),
UNIQUE (emoji_bits),
UNIQUE (emoji_char)
);
