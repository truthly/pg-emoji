EXTENSION = emoji
DATA = emoji--1.0.sql

REGRESS = test
EXTRA_CLEAN = emoji--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: emoji--1.0.sql

SQL_SRC = \
  complain_header.sql \
  TABLES/chars.sql \
	FUNCTIONS/encode.sql \
	FUNCTIONS/decode.sql \
	FUNCTIONS/from_text.sql \
	FUNCTIONS/to_text.sql

emoji--1.0.sql: $(SQL_SRC)
	./fetch-chars.sh
	cat $^ > $@
	cat emoji-chars.sql >> $@
