# trac2md

Conversion tool for Wiki Syntax from trac/moinmoin to markdown

## Usage

    lua trac2md.lua < in.trac > out.md

## Requirements

- lua (juajit)
- lpeg
- penlight

## Example

See [test.md](/test.md) which has been created from [test.wiki](/test.wiki).

## Parameters

The following environment variables are considered:

* `LINK_ROOT` remove this prefix from all trac links. Can be used to change the root of link URLs.

* `TRAC_ROOT` Base url of the trac wiki. Links starting with this URL will be converted to relative links.

## Internals

This converter uses a PEG grammar to parse the wiki syntax and is
sensitive to the context in which expressions are found. This means,
for example, that no styling rules will be translated inside
pre-formatted blocks.

Conversion rules are abstracted as functions, so that the
implementation can be extended to include more corner cases using
plain lua.
