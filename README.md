<h1 id="top">😍🐘<code>pg-emoji</code></h1>

1. [About](#about)
1. [Dependencies](#dependencies)
1. [Installation](#installation)
1. [Usage](#usage)
1. [API](#api)
      1. [emoji.encode(bytea)→text]
      1. [emoji.decode(text)→bytea]
      1. [emoji.from_text(text)→text]
      1. [emoji.to_text(text)→text]

[emoji.encode(bytea)→text]: #api-emoji-encode
[emoji.decode(text)→bytea]: #api-emoji-decode
[emoji.from_text(text)→text]: #api-emoji-from-text
[emoji.to_text(text)→text]: #api-emoji-to-text

<h2 id="about">1. About</h2>

`emoji` is a pure SQL [PostgreSQL] extension to encode/decode bytea/text to/from emoji.

A lookup-table is constructed from the first 1024 emojis from [https://unicode.org/Public/emoji/13.1/emoji-test.txt],
where each emoji maps to a unique 10 bit sequence.

The input data is split into 10 bit fragments, mapped to the corresponding emojis.

The first emoji in the result is a header,
where the first bit is 1 if the result was zero padded,
and the remaining 9 bits is a checksum based on the input data.

If the checksum is invalid during decode, `NULL` is returned.

[PostgreSQL]: https://www.postgresql.org/

<h2 id="dependencies">2. Dependencies</h2>

None.

<h2 id="installation">3. Installation</h2>

Install the `emoji` extension with:

    $ git clone https://github.com/truthly/pg-emoji.git
    $ cd pg-emoji
    $ make
    $ sudo make install
    $ make installcheck

<h2 id="usage">4. Usage</h2>

Use with:

    $ psql
    # CREATE EXTENSION emoji;
    CREATE EXTENSION;


<h2 id="api">5. API</h2>

<h3 id="api-emoji-encode"><code>emoji.encode(bytea)→text</code></h3>

```sql
SELECT emoji.encode('\x0123456789abcdef'::bytea);
  encode
----------
 👦😀🥺🪀🦠🖖🌌🥚
(1 row)
```

Making a subtle change to the input data will not only change
the corresponding emoji, but also the first emoji which contains a
9-bit checksum of the data, which means it will change with 99.8%
confidence (511/512). Notice in the example below what happens if
the last **f** is changed to **7**.

```sql
SELECT emoji.encode('\x0123458789abcde7'::bytea);
  encode
----------
 💜😀🥺🪀🍼🖖🌌🍕
(1 row)
```

<h3 id="api-emoji-decode"><code>emoji.decode(text)→bytea</code></h3>

```sql
SELECT emoji.decode('👦😀🥺🪀🦠🖖🌌🥚');
       decode
--------------------
 \x0123456789abcdef
(1 row)
```

Thanks to the first emoji containing a 9-bit checksum of the data,
failing to properly copy/paste the entire emoji string will be
detected upon decoding with 99.8% confidence and `NULL` will be returned.

```sql
SELECT emoji.decode('👦😀🥺🪀🦠🖖🌌');
 decode
--------

(1 row)
```

<h3 id="api-emoji-from-text"><code>emoji.from_text(text)→text</code></h3>

```sql
SELECT emoji.from_text('Hello 🌎!');
 from_text
------------
 🦳🥺🐞🕰🎐🎗📷🧂🎖🫖
(1 row)
```

<h3 id="api-emoji-to-text"><code>emoji.to_text(text)→text</code></h3>

```sql
SELECT emoji.to_text('🦳🥺🐞🕰🎐🎗📷🧂🎖🫖');
 to_text
----------
 Hello 🌎!
(1 row)
```
