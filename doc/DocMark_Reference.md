<style>
code {
	white-space: pre;
}
</style>

# DocMark

DocMark is not designed to be an expansion of Markdown, but is strongly inspired by it. Where I find it is simpler or more elegant to depart from Markdown convention, DocMark will. It is intended to be used as format for writing notes and formatting collections of simple documents with a wider range of built-in data-presentation methods.

<!--TODO
Consider adding a brief introductory section at the beginning that provides a high-level overview of what DocMark is, its purpose, and its key features. This can help users quickly understand the context before diving into the detailed syntax.
-->

## Table of Contents

- [DocMark](#docmark)
	- [Table of Contents](#table-of-contents)
	- [Syntax](#syntax)
		- [Whitespace](#whitespace)
		- [Headings](#headings)
			- [Heading Identifiers](#heading-identifiers)
			- [Examples](#examples)
		- [Paragraphs](#paragraphs)
			- [Indented Paragraphs](#indented-paragraphs)
			- [Merged Paragraphs](#merged-paragraphs)
		- [Emphasis](#emphasis)
		- [Blockquotes](#blockquotes)
			- [Merged Blockquotes](#merged-blockquotes)
			- [Nested Blockquotes](#nested-blockquotes)
		- [Lists](#lists)
			- [Ordered Lists](#ordered-lists)
			- [Unordered Lists](#unordered-lists)
			- [Description Lists](#description-lists)
		- [Code](#code)
			- [Inline Code](#inline-code)
			- [Code Blocks](#code-blocks)
		- [Horizontal Rules](#horizontal-rules)
		- [Links](#links)
		- [Media](#media)
			- [Images](#images)
				- [Linking Images](#linking-images)
			- [Audio](#audio)
			- [Video](#video)
		- [Escape Character](#escape-character)
		- [Tables](#tables)
				- [Centering](#centering)
			- [Top-Titled Tables](#top-titled-tables)
			- [Left-Titled Tables](#left-titled-tables)
			- [Two-Way Tables](#two-way-tables)
			- [Colspan and Rowspan](#colspan-and-rowspan)
			- [Multiple Titles](#multiple-titles)
		- [Columns](#columns)
		- [Infoboxes](#infoboxes)
		- [References](#references)
			- [Footnotes](#footnotes)
			- [Endnotes](#endnotes)
		- [Math](#math)
			- [Inline Math](#inline-math)
			- [Math Blocks](#math-blocks)
			- [Inserting Plots](#inserting-plots)
		- [Collapsible](#collapsible)
		- [HTML](#html)
		- [Macros](#macros)
			- [Variables](#variables)
			- [Functions](#functions)
		- [Built-In Macros](#built-in-macros)
			- [%\_css](#_css)
			- [%\_title](#_title)
			- [%\_timestamp()](#_timestamp)
			- [%\_fetch()](#_fetch)
			- [%\_insert()](#_insert)
			- [%\_insert()()](#_insert-1)
			- [Positional Parameters](#positional-parameters)

## Syntax

The following sections provide an overview of the syntax of DocMark.

### Whitespace

In most cases, any amount of whitespace characters in sequence will be collapsed to a single space when preprocessed, and any number of newlines in sequence will be collapsed to a maximum of two. The exceptions are code blocks, which must keep their contents faithful to input; comments, which are removed entirely with their contents; and lines that contain only whitespace, from which all whitespace will be deleted before the newlines are collapsed.

Since whitespace is invisible to the user, it is unwise to rely on distinctions between different whitespace characters such as tabs and the various spaces to format the document. The effect of newlines is less severe because they have a much more visible impact on the structure of a document, but long sequences of newlines can still be difficult to understand by eye. Dealing with multiple types of whitespace also complicates the effort of parsing and compiling documents. By collapsing whitespace, some degree of simplicity is enforced. The reduction in character count can also marginally assists with memory requirements for large documents.

### Headings

Headings are used to define the hierarchy of a document. They provide clear and visible representations of the document's structure to the reader.

To create a heading, a line must start with between one and six hash symbols (`#`). There can be no characters between the beginning of the line and the first hash symbol, and there can be no characters between the hash symbols. The text of the heading will follow these hash symbols separated by any amount of whitespace, and can contain any characters. The heading will be terminated by a newline.

The number of hash symbols corresponds to the heading level, with one hash symbol corresponding to a level 1 header (`<h1>`), two hash symbols corresponding to a level 2 header (`<h2>`), and so on. If there is no header text, the header will be created empty (i.e., `<h1></h1>`).

#### Heading Identifiers

Heading identifiers are attributes used to uniquely identify headers within a document, so that it can be linked to in other locations. They must begin with an alphabetic character, and may be followed by any number of alphanumeric characters, hyphens, underscores, colons, and periods. Identifiers are also case-sensitive, 

The compiler will automatically generate heading identifiers from the name of the title. By default, the identifier will be the same as the header text except all alphabetic characters have been converted to lowercase, all spaces have been replaced by hyphens, and all illegal characters have been removed.

If an identifier identical to this resulting identifier already exists when the compiler attempts to generate it, the compiler will append hyphen and an integer to the new identifier. Starting at 1, this integer will be incremented until there are no matching identifiers. For example, the headers

```
# Heading .
## Heading ?
### Heading !
```

will be assigned the identifiers

```html
heading-
heading--1
heading--2
```

respectively. (The illegal characters `.`, `?`, and `!` were each removed, leaving identical `heading-` identifiers.)

The user can also specify custom identifiers. A custom identifier must be separated from the heading text by whitespace, enclosed in brackets, and preceded by a hash symbol (i.e., `{#custom-identifier}`). The user should ensure that the custom identifier is unique. If not, it will be appended with a hyphen and an integer to be incremented according to the same procedure as with compiler-generated identifiers.

These custom identifiers must follow the composition rules for heading identifiers, but do not have to follow the same structure as compiler-generated identifiers. It is advised that the user start custom identifiers with uppercase characters, as the compiler will always generate identifiers that only contain lowercase characters.

To link to a header, perform the same steps as with a normal link but replace the address or path with a hash symbol followed by the heading identifier. For example,

```
## Subtitle {Custom-Subtitle}
```

can be linked to as follows: 

```
[Link Text](#Custom-Subtitle)
```

#### Examples

The six levels of headings will be compiled to HTML as follows:

| DocMark | HTML |
|:-:|:-:|
| `# Heading 1` | `<h1 id="heading-1">Heading 1</h1>` |
| `## Heading 2` | `<h2 id="heading-2">Heading 2</h2>` |
| `### Heading 3` | `<h3 id="heading-3">Heading 3</h3>` |
| `#### Heading 4` | `<h4 id="heading-4">Heading 4</h4>` |
| `##### Heading 5` | `<h5 id="heading-5">Heading 5</h5>` |
| `###### Heading 6` | `<h6 id="heading-6">Heading 6</h6>` |

### Paragraphs

Paragraphs are simple blocks of text for organizing and presenting textual information.

To create a paragraph, a line must not start with any markup elements and must be separated from other elements by an empty line.

| DocMark | HTML |
|:-:|:-:|
| `Lorem Ipsum` | `<p>Lorem Ipsum</p>` |

#### Indented Paragraphs

A paragraph that starts with whitespace will be indented. The amount and type of whitespace does not matter: spaces, tabs, etc. will all cause an indentation, and a line cannot be indented more than once.

| DocMark | HTML |
|:-:|:-:|
| ` Lorem Ipsum` | `<p class="indented">Lorem Ipsum</p>` |

The indentation is handled by CSS, but by default should look like this:

```css
.indented {
	margin-left: 25px;
}
```

#### Merged Paragraphs

If a paragraph does not have an empty line between itself and another paragraph with the same indentation, the two will be merged with a line break (`<br>`) between them. For example, 

```
Lorem ipsum dolor sit amet...
Lorem ipsum dolor sit amet...
```

becomes

```html
<p>
	Lorem ipsum dolor sit amet...<br>
	Lorem ipsum dolor sit amet...
</p>
```

while

```
 Lorem ipsum dolor sit amet...
Lorem ipsum dolor sit amet...
```

becomes

```html
<p class="indented">Lorem ipsum dolor sit amet...</p>
<p>Lorem ipsum dolor sit amet...</p>
```

instead.

### Emphasis

Text emphasis is used to convey additional meaning or importance by altering the appearance of the text without changing its content. DocMark supports seven different forms of emphasis: italics, boldfaced, underlines, strikethrough, highlights, superscript, and subscript. These emphasis styles can be combined with one another, providing flexibility for various text styling needs.

All emphasis markers must directly precede and follow the emphasized text, without any interrupting whitespace. However, there may be whitespace between words in the emphasized section.

| DocMark | HTML |
|:-:|:-:|
| `*Italic Text*` | `<em>Italic Text</em>` |
| `+Bold Text+` | `<strong>Bold Text</strong>` |
| `~Underlined Text~` | `<u>Underlined Text</u>` |
| `-Struckthrough Text-` | `<s>Struckthrough Text</s>` | 
| `=Highlighted Text=` | `<mark>Highlighted Text</mark>` |
| `^Superscripted Text^` | `<sup>Superscripted Text</sup>` |
| `_Subscripted Text_` | `<sub>Subscripted Text</sub>` |

Inline code *can* be used as emphasis and is syntactically similar to emphasis. However, it should be used to denote programming code or code-like elements instead of additional meaning or stress on a piece of text.

### Blockquotes<!--TODO: RESUME HERE-->

Block quotations are sections of text formatted to represent quoted content in writing.

To create a blockquote, a line must start with a greater-than symbol (`>`) separated from the text of the quote by whitespace.

| DocMark | HTML |
|:-:|:-:|
| `> Lorem Ipsum` | `<blockquote>Lorem Ipsum</blockquote>` |

#### Merged Blockquotes

If a blockquote does not have an empty line between itself and another blockquote, the two will be merged with a line break (`<br>`) between them.

#### Nested Blockquotes

Blockquotes can also be nested by stacking greater-than symbols..

```
> Lorem ipsum dolor sit amet...
> Lorem ipsum dolor sit amet...
>> Lorem ipsum dolor sit amet...
```

```html
<blockquote>
Lorem ipsum dolor sit amet...<br>
Lorem ipsum dolor sit amet...
	<blockquote>
		Lorem ipsum dolor sit amet...
	</blockquote>
</blockquote>
```

### Lists

Lists are used to sequentially organize a set of items in a document.

Lists can contain elements within themselves; this allows for headers, paragraphs, emphasis, and other lists to be elements of a list. The first level of a list must be the first element on its line, and indented sections are included as elements of the prior list item.

#### Ordered Lists

Ordered lists are used to list items when there is a need to refer to items by number or if the sequence of items is important. Each item in the list is bulleted by a unique, ascending numeric value.

```
1. First item
2. Second item
	1. First subitem
3. Third item
```

```html
<ol>
  <li>First item</li>
  <li>Second item</li>
		<ol>
			<li>First subitem</li>
		</ol>
  <li>Third item</li>
</ol>
```

#### Unordered Lists

Unordered lists are used to list items when the order and number of the list items are not important. Each item in the list is bulleted by the same mark, though it may change with the level of the list.

```
- First item
- Second item
	- First subitem
- Third item
```

```html
<ul>
  <li>First item</li>
  <li>Second item</li>
		<ul>
			<li>First subitem</li>
		</ul>
  <li>Third item</li>
</ul>
```

#### Description Lists

Description lists are used to list a series of matches between keywords and values.

```
Key 1
: Value 1
Key 2
: Value 2.1
: Value 2.2
```

```html
<dl>
  <dt>Key 1</dt>
  <dd>Value 1</dd>
  <dt>Key 2</dt>
  <dd>Value 2.1</dd>
  <dd>Value 2.2</dd>
</dl>
```

### Code

Any data that would normally be preprocessed will not be preprocessed if it is within an inline code section or a code block. However, escaping the variables or functions by preceding them with a backslash (`\`) will allow them to be expanded.

#### Inline Code

| DocMark | HTML |
|:-:|:-:|
| `` `code` `` | `<code>code</code>` |

#### Code Blocks

```
``
int main() {
	return 0;
}
``
```

```html
<pre>
int main() {
	return 0;
}
</pre>
```

To add syntax highlighting, specify a language after the backticks before the code block.

### Horizontal Rules

To create a horizontal rule, three hyphens must be placed on a line by themselves.

| DocMark | HTML |
|:-:|:-:|
| `---` | `<hr>` |

### Links

To create a link, enclose the link text in brackets and follow it immediately with the URL in parentheses.

```
[example](https://example.com/)
```

```html
<a href="https://example.com/">example</a>
```

### Media

#### Images

```
![alt text](example.png "title")
```

```html
<img src="example.png" alt="example" title="title">
```

##### Linking Images

```
[![alt text](example.mp3 "title")](link/to/example/article)
```

```html
<a href="https://example.com/">
	<img src="example.img" alt="example" title="title">
</a>
```

#### Audio

Supports .mp3, .wav, and .ogg.

```
![alt text](example.mp3 "title"; audio/mp3)
```

```html
<audio controls title="title">
  <source src="example.mp3" type="audio/mp3">
alt text
</audio>
```

#### Video

Supports .mp4, .webm, and .ogg.

```
![alt text](example.mp4 "title"; video/mp4)
```

```html
<video title="title">
  <source src="example.mp4" type="video/mp4">
alt text
</video>
```

### Escape Character

DocMark's escape character is the backslash (`\`). To display a character that would otherwise be used to format text, precede it with a backslash. For example, to display a backtick, you would enter `` \` ``. Macros in code can also be escaped to reenable preprocessor expansion.

### Tables

##### Centering

- `---`: default aligned
- `:--`: left aligned
- `:-:`: center aligned
- `--:`: right aligned

```
| A | B | C | D |
|---|:--|:-:|--:|
| 1 | 2 | 3 | 4 |
```

```html
<table>
<thead>
<tr>
<th>A</th>
<th style="text-align:left">B</th>
<th style="text-align:center">C</th>
<th style="text-align:right">D</th>
</tr>
</thead>
<tbody>
<tr>
<td>1</td>
<td style="text-align:left">2</td>
<td style="text-align:center">3</td>
<td style="text-align:right">4</td>
</tr>
</tbody>
</table>
```

#### Top-Titled Tables

```
| Title 1   | Title 2   | Title 3   |
|-----------|-----------|-----------|
| Content 1 | Content 2 | Content 3 |
| Content 4 | Content 5 | Content 6 |
```

```html
<table class="top-titled-table">
<thead>
<tr>
<th>Title 1</th>
<th>Title 2</th>
<th>Title 3</th>
</tr>
</thead>
<tbody>
<tr>
<td>Content 1</td>
<td>Content 2</td>
<td>Content 3</td>
</tr>
<tr>
<td>Content 4</td>
<td>Content 5</td>
<td>Content 6</td>
</tr>
</tbody>
</table>
```

#### Left-Titled Tables

```
| Title 1 || Content 1 | Content 4 |
| Title 2 || Content 2 | Content 5 |
| Title 2 || Content 3 | Content 6 |
```

```html
<table class="left-titled-table">
<thead>
</thead>
<tbody>
<tr>
<th>Title 1</th>
<td>Content 1</td>
<td>Content 4</td>
</tr>
<tr>
<th>Title 2</th>
<td>Content 2</td>
<td>Content 5</td>
</tr>
<tr>
<th>Title 3</th>
<td>Content 3</td>
<td>Content 6</td>
</tr>
</tbody>
</table>
```

#### Two-Way Tables

```
|         || Title 1     | Title 2     | Title 3     |
|---------||-------------|-------------|-------------|
| Title 1 || Content 1.1 | Content 2.1 | Content 3.1 |
| Title 2 || Content 1.2 | Content 2.2 | Content 3.2 |
| Title 3 || Content 1.3 | Content 2.3 | Content 3.3 |
```

```html
<table class="two-way-table">
<thead>
<tr>
<th ></th>
<th>Title 1</th>
<th>Title 2</th>
<th>Title 3</th>
</tr>
</thead>
<tbody>
<tr>
<th>Title 1</th>
<td>Content 1.1</td>
<td>Content 2.1</td>
<td>Content 3.1</td>
</tr>
<tr>
<th>Title 2</th>
<td>Content 1.2</td>
<td>Content 2.2</td>
<td>Content 3.2</td>
</tr>
<tr>
<th>Title 3</th>
<td>Content 1.3</td>
<td>Content 2.3</td>
<td>Content 3.3</td>
</tr>
</tr>
</tbody>
</table>
```

#### Colspan and Rowspan

```
| Title 1   | <<<       | Title 2   |
|:---------:|:---------:|:---------:|
| Content 1 | Content 2 | Content 3 |
| Content 4 | Content 5 | ^^^       |
```

```html
<table class="top-titled-table">
<thead>
<tr>
<th style="text-align:center" colspan="2">Title 1</th>
<th style="text-align:center">Title 2</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:center">Content 1</td>
<td style="text-align:center">Content 2</td>
<td style="text-align:center">Content 3</td>
</tr>
<tr>
<td style="text-align:center">Content 4</td>
<td style="text-align:center" rowspan="2">Content 5</td>
</tr>
</tbody>
</table>
```

#### Multiple Titles

```
|         | <<<     || Title 1     | Title 2     | Title 3     |
|---------|---------||-------------|-------------|-------------|
| Overall | Title 1 || Content 1.1 | Content 2.1 | Content 3.1 |
| ^^^     | Title 2 || Content 1.2 | Content 2.2 | Content 3.2 |
| ^^^     | Title 3 || Content 1.3 | Content 2.3 | Content 3.3 |
```

```html
<table class="two-way-table">
<thead>
<tr>
<th colspan="2"></th>
<th>Title 1</th>
<th>Title 2</th>
<th>Title 3</th>
</tr>
</thead>
<tbody>
<tr>
<th rowspan="3">Overall</th>
<th>Title 1</th>
<td>Content 1.1</td>
<td>Content 2.1</td>
<td>Content 3.1</td>
</tr>
<tr>
<th>Title 2</th>
<td>Content 1.2</td>
<td>Content 2.2</td>
<td>Content 3.2</td>
</tr>
<tr>
<th>Title 3</th>
<td>Content 1.3</td>
<td>Content 2.3</td>
<td>Content 3.3</td>
</tr>
</tr>
</tbody>
</table>
```

### Columns

Maximum of two columns, no recursive columns.

TODO

```
[|
Lorem ipsum dolor sit amet, ...
||
Lorem ipsum dolor sit amet, ...
|]
```

```html
<div class="column-box">
<div class="column">Lorem ipsum dolor sit amet, ...</div>
<div class="column">Lorem ipsum dolor sit amet, ...</div>
</div>
```

The indentation is handled by CSS, but by default should look like this:

```css
<style>
.column-box {
	display: flex;
	justify-content: space-between;
}

.column {
	width: 48%;
	padding: 10px;
	box-sizing: border-box;
	margin-bottom: 10px;
}
</style>
```

### Infoboxes

TODO

```
[[ TITLE

[ALT_TEXT](IMAGE_PATH)

### HEADING

CATEGORY
: CONTENT

]]
```

```html
<div class="infobox-container">
	<div class="infobox">
		<div class="heading">
			<h2>TITLE</h2>
		</div>
		<img src="IMAGE_PATH" alt="ALT_TEXT" class="infobox-img">
		<div class="infobox-group">
			<div class="heading">
				<h3>HEADING</h3>
			</div>
			<div class="infobox-data">
				<div class="infobox-datarow">
					<p class="data-heading">CATEGORY</p>
					<ul class="data-content">
						<li>CONTENT</li>
					</ul>
				</div>
			</div>
		</div>
	</div>
</div>
```

The TITLE element can only be inserted once per info box, but all other elements can be inserted repeatedly.

### References

References allow you to add notes without cluttering the body of the document. When you create a reference, a superscripted number with a link appears where you added the reference. Readers can click the link to jump to a note.

#### Footnotes

Footnotes link to a note at the base of their local heading section, before the next heading of any rank. They provide ease of access for quick reference, but should be kept short and sparse to preserve formatting. The text of the note must be located within the same header section as the reference, or it may be orphaned by the compiler. The ID is generated from the name of the heading that the footnote is named within and the number of the footnote within that heading, as `<heading_name>-footnote-<number>`.

```
## Section 1

Lorem ipsum[^1] dolor sit[^2] amet...

... Other text ...

[^1]: Footnote 1
[^2]: Footnote 2

### Subsection 1
```

```html
<h2>Section 1</h2>

<p>Lorem ipsum<sup><a href="#section-1-footnote-1">1</a></sup> dolor sit<sup><a href="#section-1-footnote-2">2</a></sup> amet...</p>

... Other text ...

<div class="footnotes">
	<hr>
	<ol>
		<li id="section-1-footnote-1">Footnote 1</li>
		<li id="section-1-footnote-2">Footnote 2</li>
	</ol>
</div>

<h3>Subsection 1</h3>
```

#### Endnotes

Endnotes link to a note at the end of the document. They can contain more text without compromising the format of the paper. Endnotes can be located anywhere in the document without risk of being orphaned. The ID is generated from the number of the footnote within the document, as `endnote-<number>`.

```
# Title

Lorem ipsum[_1] dolor sit[_2] amet...

... Remaining Document ...

[_1]: Endnote 1
[_2]: Endnote 2
```

```html
<h1>Title</h1>

<p>Lorem ipsum<sup><a href="#endnote-1">[1]</a></sup> dolor sit<sup><a href="#endnote-2">[2]</a></sup> amet...</p>

... Remaining Document ...

<div class="endnotes">
	<p>Notes</p>
	<hr>
	<ol>
		<li id="endnote-1">Endnote 1</li>
		<li id="endnote-2">Endnote 2</li>
	</ol>
</div>
```

### Math

TODO: figure out how to implement

#### Inline Math

Math can be rendered inline with the surrounding text if it is placed between pairs of dollar signs (`$`).

<p>This is an inline math expression: <span class="inline-math">a^2 + b^2 = c^2</span>.</p>

```
An equation: $ y=x^2 $
```

```html

```

#### Math Blocks

Math can be rendered in blocks with the surrounding text with LaTeX if it is placed between pairs of `\[` and `\]`

#### Inserting Plots

TODO: Way out there

### Collapsible

TODO

```html
<details>
	<summary>Title</summary>
	Content
</details>
```

### HTML

Raw HTML is inserted directly into the compiled document.

### Macros

Tokens that begin with a percentage symbol (`%`) are evaluated at compile time. Most of these tokens are macros, statements that are evaluated and expanded into the document. Macros must begin with an alphabetic character and can only contain alphanumeric characters or underscores. `%variable` is a variable, with a determinate value, while `%function()` is a function that will be evaluated based on its parameters. Functions and variables can be defined anywhere in a file, but must be defined before they are used.

Macros return in two ways. They are either assigned to other macros (`%var = %val`), or inserted at the location that they are called (`%var`).

#### Variables

The value of the variable is inserted at every location where the value occurs

For instance,
```
%var = val

...

The value of \%var is %var.
```
becomes
```
%var = val

...

The value of \%var is val.
```

Primarily used for dynamic, repetitive, and often-changing content.

#### Functions

```
%func(param) {
	...;
	return ...;
}
```

TODO: Choose or design a language for the macros. The scripting syntax for these functions and variables should be as C-like as possible.

### Built-In Macros

Variables and functions that begin with an underscore are built-in, and cannot be defined by the user. If a macro cannot be set by the user, it should be a function with no arguments

#### %_css

Specifies the path to the CSS of the document, which can be set to easily switch between different display schemes. Setting `%_css` to a list will use all CSS files in that list. Defaults to the compiler's standard CSS.

#### %_title

Specifies the HTML title of the document. Defaults to an empty string.

#### %_timestamp()

Returns the date and time at time of compilation. Formatted as (Subject to change) `YYYY/DD/MM HH:mm:SS` in 24-hour format.

#### %_fetch()

Dynamically fetches data from another location and returns it. Takes a single argument, the URL of the data.

#### %_insert()

Returns the contents of another file at the location of the macro. Takes a single argument, the path to the inserted file.

Preprocessor evaluation takes place (mostly) in order, so a file containing variable and function definitions can be inserted before their use in the inserting document to prevent non-rendering bloat.

#### %_insert()()

Returns the contents of another file at the location of the macro in a function-like manner. It first takes a single argument, the path to the inserted file, and then any number of arguments as specified by the inserted file. `%_insert(path/to/file)()` is functionally identical to `%_insert(path/to/file)`.

The second set of values passed to `%insert()()` will be inserted into the file as positional parameters, and expanded at locations specified by their order (the first argument is inserted at `%1`, the second at `%2`, and so on).

Inserted file
```
| %1 | %2 |
|---|---|
| %3 | %4 |
```

After %_insert(path/to/file)(good, bad, apples, kiwis)
```
| good | bad |
|---|---|
| apples | kiwis |
```

#### Positional Parameters

Imported files can act in a function-like manner with the %_insert()() function. The arguments contained within the second set of parentheses identify positional parameters, which are expanded at insertion. To render a positional parameter, enter `%` followed by the position value of the desired parameter as an integer starting at 1. Technically, the zeroth positional parameter is the filename, but there shouldn't be too much use for it.

For `insert(example/file.dm)(alpha, beta, gamma)`, `%1` will be `alpha`, `%2` `beta`, and `%3` `gamma`. `%0` will be `example/file.dm`, which could be used to label sections more dynamically.

Attempting to set a positional parameter that is not used will not throw an error (perhaps a warning), but the value will not be used (naturally). If a positional parameter is used but not provided, the variable will not be expanded, and may also throw a warning.