# Trac Wiki Syntax

mtrack has a built in small and powerful wiki rendering engine. This wiki engine implements an ever growing subset of the commands from other popular Wikis, especially MoinMoin.
This page demonstrates the formatting syntax available anywhere WikiFormatting is allowed.
Font Styles #

The Trac wiki supports the following font styles:

* **bold**, **!''' can be bold too**, and **! **
 * *italic*
 * ***bold italic***
 * __underline__
 * `monospace` or `monospace`
 * ~~strike-through~~
 * ^superscript^ 
 * ,,subscript,,

Notes:

`...` and `...` commands not only select a monospace font, but also treat their content as verbatim text, meaning that no further wiki processing is done on this text.
! tells wiki parser to not take the following characters as wiki format, so pay attention to put a space after !, e.g. when ending bold.


# Headings

You can create heading by starting a line with one up to five equal
characters ("=") followed by a single space and the headline text. The
line should end with a space followed by the same number of =
characters. The heading might optionally be followed by an explicit
id. If not, an implicit but nevertheless readable id will be
generated.  Example:


# Heading

## Subheading

### About *this*


### Explicit id #using-explicit-id-in-heading

A new text paragraph is created whenever two blocks of text are separated by one or more empty lines.

A forced line break can also be inserted, using:
Line 1  
Line 2

The wiki supports both ordered/numbered and unordered lists.
Example:
 * Item 1     * Item 1.1        * Item 1.1.1           * Item 1.1.2        * Item 1.1.3     * Item 1.2
 * Item 2

 1. Item 1     a. Item 1.a     a. Item 1.b        i. Item 1.b.i        i. Item 1.b.ii
 1. Item 2
And numbered lists can also be given an explicit number:
 3. Item 3

The wiki also supports definition lists.
Example:

* **llama**      some kind of mammal, with hair
* **ppython**      some kind of reptile, without hair     (can you spot the typo?)



# Preformatted Text

Block containing preformatted text are suitable for source code snippets, notes and examples. Use three curly braces wrapped around the text to define a block quote. The curly braces need to be on a separate line.
Example:

```
  def HelloWorld():
      print "Hello World"
```


# Blockquotes

In order to mark a paragraph as blockquote, indent that paragraph with two spaces.
Example:
    This text is a quote from someone else.


# Discussion Citations

To delineate a citation in an ongoing discussion thread, such as the ticket comment area, e-mail-like citation marks (">", ">>", etc.) may be used.

Example:
>> Someone's original text
> Someone else's reply text

Note: Some WikiFormatting elements, such as lists and preformatted text, are lost in the citation area. Some reformatting may be necessary to create a clear citation.


# Tables

Simple tables can be created like this:

|Cell 1|Cell 2|Cell 3|
|---|---|---|
|Cell 4|Cell 5|Cell 6|


# Links

Hyperlinks are automatically created for WikiPageNames and URLs. WikiPageLinks can be disabled by prepending an exclamation mark "!" character, such as WikiPageLinkWikiPageLink}}}.

Example:
    TitleIndex, http://www.edgewall.com/, !NotAlink

Links can be given a more descriptive title by writing the link
followed by a space and a title and all this inside square
brackets. If the descriptive title is omitted, then the explicit
prefix is discarded, unless the link is an external link. This can be
useful for wiki pages not adhering to the WikiPageNames convention.

Example:
 * [Edgewall Software](http://www.edgewall.com/)
 * [Title Index](/TitleIndex.md)
 * [/ISO9000.md](/ISO9000.md)


# Trac Links

Wiki pages can link directly to other parts of the Trac system. Pages can refer to tickets, reports, changesets, milestones, source files and other Wiki pages using the following notations:

* Tickets: #1 or ticket:1
 * Reports: {1} or report:1
 * Changesets: r1, [/1.md](/1.md) or changeset:1
 * Milestones: milestone:1
 * Help: help:WikiFormatting
 * Users: user:wez
 * ...



# Escaping Links and WikiPageNames

You may avoid making hyperlinks out of TracLinks by preceding an expression with a single "!" (exclamation mark).

Example:
 NoHyperLink
 !#42 is not a link

The simplest way to include an image is to upload it as an attachment to the current page, and put the filename in a macro call like ![Image: 'picture.gif'](/assets/picture.gif?raw=true).

In addition to the current page, it is possible to refer to other resources:
![Image: 'wiki:WikiFormatting:picture.gif'](/assets/wiki:WikiFormatting:picture.gif?raw=true) (referring to attachment on another page)
![Image: 'ticket:1:picture.gif'](/assets/ticket:1:picture.gif?raw=true) (file attached to a ticket)
Other parameters:
![Image: 'photo.jpg,200px'](/assets/photo.jpg,200px?raw=true) (scale picture to be 200px wide)
![Image: 'photo.jpg,200px,nolink'](/assets/photo.jpg,200px,nolink?raw=true) (don't generate a link to picture)
![Image: 'photo.jpg,200px'](/assets/photo.jpg,200px?raw=true) (float image to right)
![Image: 'photo.jpg,width=200,height=300'](/assets/photo.jpg,width=200,height=300?raw=true) (explicitly set size)
![Image: 'photo.jpg,name=value,other=otherval'](/assets/photo.jpg,name=value,other=otherval?raw=true) (set arbitrary attributes on the IMG tag. Values are HTML escaped)


# Processors

Trac supports alternative markup formats using WikiProcessors. For example, processors are used to write pages in HTML.


## HTML

<h1 style="text-align: right; color: blue">HTML Test</h1>


## Python

```python
class Test:

    def __init__(self):
        print "Hello World"
if __name__ == '__main__':
   Test()
```


## Perl

```perl
my ($test) = 0;
if ($test > 0) {
    print "hello";
}
```


## Markdown

mtrack has a markdown processor that can be used as shown below. In addition to supporting the Markdown Extra flavor of Markdown, this implementation supports mtrack style links as both reference and inline links, and supports all of the mtrack wiki processors in fenced blocks.

```markdown
# Markdown title

This is some markdown text
```


## Diagrams with ASCIIToSVG

mtrack includes ASCIIToSVG, an ASCII art diagram to SVG translator. This is nice if you're writing technical documentation and want to have some diagrams inlined.
Here's a brief example:

```a2s
.-------------.  .--------------.
|[Red Box]    |->|[Blue Box]    |
'-------------'  '--------------'

[Red Box]: {"fill":"#aa4444"}
[Blue Box]: {"fill":"#ccccff"}
```


## Comments

Comments can be added to the plain text. These will not be rendered and will not display in any other format than plain text.




## Data output from SQL command line utilities

If you have text that you want to copy and paste from a command line utility, such as psql, then you can enclose it in the dataset processor:

```dataset
            current_query             | procpid | usename | client_addr  |     elapsed
--------------------------------------+---------+---------+--------------+-----------------
 SELECT * FROM build_mailing(59508)   |    6595 | user  | 10.16.40.80 | 00:04:24.377262
 FETCH NEXT FROM "<unnamed portal 5>" |   27597 | user  | 10.16.40.80 | 00:00:44.208982
 commit                               |   19188 | user  | 10.16.40.67 | 00:00:00.013402
 COMMIT                               |   26390 | user  | 10.16.1.56  | 00:00:00.007778
```


## Miscellaneous

Four or more dashes will be replaced by a horizontal line (<HR>)

Example:
 ----
