#!/bin/sh
FILE=emoji-chars.sql
if [ ! -f "$FILE" ]; then
  echo "❗️Modifying the list will cause incompatibility problems❗️"
  curl -s https://unicode.org/Public/emoji/13.1/emoji-test.txt \
  | grep -E '^[0-9A-F]{4,5} +;' \
  | head -n 1024 \
  | awk '{print "INSERT INTO emoji.chars (emoji_char) VALUES ('\''"$5"'\'');"}' > emoji-chars.sql
fi
