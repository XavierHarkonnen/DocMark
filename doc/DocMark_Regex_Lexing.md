# DocMark Regex Lexing

This document contains specifications for creating a DocMark-standard compliant lexer. The lexer takes a text file as input and outputs a tree of tokens.

## Table of Contents

- [DocMark Regex Lexing](#docmark-regex-lexing)
	- [Table of Contents](#table-of-contents)
	- [Validation Process](#validation-process)
	- [Tokens and Token Types](#tokens-and-token-types)
		- [Data vs Attribute Field](#data-vs-attribute-field)
		- [Root](#root)
		- [Raw Tokens](#raw-tokens)
	- [Context Sensitivity](#context-sensitivity)
	- [Escaped Characters](#escaped-characters)
	- [Empty Line](#empty-line)
	- [Headings](#headings)
		- [Heading with Identifier](#heading-with-identifier)
	- [Italic](#italic)
		- [Italic containing Bold](#italic-containing-bold)
	- [Bold](#bold)
		- [Bold containing Italic](#bold-containing-italic)
	- [Underline](#underline)
		- [Underline containing Strikethrough](#underline-containing-strikethrough)
	- [Strikethrough](#strikethrough)
		- [Strikethrough containing Underline](#strikethrough-containing-underline)
	- [Highlight](#highlight)
	- [Superscript](#superscript)
	- [Subscript](#subscript)
	- [Blockquote](#blockquote)
	- [Lists](#lists)
		- [Ordered List](#ordered-list)
		- [Unordered List](#unordered-list)
		- [Description List](#description-list)
			- [First Key and Value](#first-key-and-value)
				- [Key](#key)
				- [Value](#value)
			- [Subsequent Value](#subsequent-value)
	- [Inline Code](#inline-code)
	- [Code Blocks](#code-blocks)
	- [Horizontal Rules](#horizontal-rules)
	- [Links](#links)
	- [Images](#images)
	- [Audio](#audio)
	- [Video](#video)
	- [Tables](#tables)
	- [Columns](#columns)
	- [Infoboxes](#infoboxes)
	- [References](#references)
		- [Footnote References](#footnote-references)
		- [Footnote Notes](#footnote-notes)
		- [Endnote References](#endnote-references)
		- [Endnote Notes](#endnote-notes)
	- [](#)
	- [Macros](#macros)
		- [Variable Definitions](#variable-definitions)
		- [Variable Returns](#variable-returns)
		- [Function Definitions](#function-definitions)
		- [Function Returns](#function-returns)
		- [Built-In Variable Definitions](#built-in-variable-definitions)
		- [Built-In Variable Returns](#built-in-variable-returns)
		- [Built-In Function Returns](#built-in-function-returns)

## Validation Process

For the framework, ensure that:
- Every [enumerated TokenType](#tokens-and-token-types) is valid and adheres to standard.
- Every [context-sensitivity flag](#context-sensitivity) is valid and adheres to standard.

For each token section, ensure that:
- An example of the specified token syntax is provided.
- The `regex` matches all accepted variants of the corresponding element.
- The `type` field specifies a type that correctly matches the token.
- The `type` field specifies a type that is in the enumeration of token types.
- The `data` field corresponds to a single valid capture group OR is marked with `N/A`.
- The `data` field is designated to receive data that will be subject to further lexing UNLESS the token type is `RAW_DATA`.
- The `attribute` field corresponds to only valid capture groups OR is marked with `N/A`.
- The `attribute` field orders multiple capture groups by separating them with a comma and space (`, `).
- The `attribute` field is designated to receive only data that does not need to be further lexed.
- The `rank` field specifies an expression that depends only on valid capture groups OR is marked with `N/A`.
- The `rank` field specifies an expression that correctly determines the rank of the token.
- All fields which contain references to capture groups refer to them as `group(#)`, where the hash (`#`) stands for the order of the group within the `regex`.
- If the token is context-sensitive:
  - The manner in which it is context-sensitive is fully explained.
  - The flags which will be used for determining context are listed.
  - The flags which will be used for determining context are listed within the flags table of the [Context Sensitivity](#context-sensitivity) section.
- The usage of all elements in the attribute field is specified <!--TODO-->
- The tokens which the data section of this token can be lexed for are fully specified.
- The section is properly formatted for readability.

## Tokens and Token Types

```C
#define INT_16_MIN -0x8000

typedef enum TokenType {
	HORIZONTAL_RULE = INT_16_MIN,
	FOOTNOTE_REFERENCE,
	ENDNOTE_REFERENCE,

	RAW_DATA = 0,

	ROOT,
	HEADING,
	ITALIC,
	BOLD,
	UNDERSCORE,
	STRIKETHROUGH,
	HIGHLIGHT,
	SUPERSCRIPT,
	SUBSCRIPT,
	BLOCKQUOTE,
	ORDERED_LIST_ELEMENT,
	UNORDERED_LIST_ELEMENT,
	DESCRIPTION_LIST_KEY,
	DESCRIPTION_LIST_VALUE,
	INLINE_CODE,
	CODE_BLOCK,
	LINK,
	IMAGE,
	AUDIO,
	VIDEO,
	TOP_TITLED_TABLE,
	LEFT_TITLED_TABLE,
	TWO_WAY_TABLE,
	LEFT_COLUMN,
	RIGHT_COLUMN,
	INFOBOX_TITLE,
	INFOBOX_CONTENT,
	FOOTNOTE_NOTE,
	ENDNOTE_NOTE,
	PARAGRAPH,
	VARIABLE_DEFINITION,
	VARIABLE_RETURN,
	FUNCTION_DEFINITION,
	FUNCTION_RETURN,
	BUILT_IN_VARIABLE_DEFINITION,
	BUILT_IN_VARIABLE_RETURN,
	BUILT_IN_FUNCTION_RETURN,
} TokenType;

typedef struct Token {
	TokenType type;
	char* data;
	char* attribute;
	unsigned int rank;

	Token *parent;
	Token **children;
	size_t num_children;
} Token;
```

All tokens contain a `type` specifier, `data` field, an `attribute` field, and a `rank`. These are used to determine the value of the token.

All tokens also contain a pointer to their `parent` token and a pointer to an array of pointers to its `children`. These are used to construct a tree which will be modified throughout lexing and inform the next parsing step.

When the `data` field of a token is lexed, pointers to the resulting tokens will be added to a dynamically allocated array, and the `children` pointer of the current token will be assigned to this array. Each child will also have its `parent` pointer assigned to the address of the current token.

The `data` field of the current token will also be freed after lexing to reduce memory requirements.

### Data vs Attribute Field

The `data` field is for data that can be further tokenized, while the `attribute` field is for raw data that is used to modify the presentation or interpretation of the data in the `data` field. If a section of text will be visible in the final, compiled project, it should not be placed into the `attribute` field.

The number of captured groups is always known for each token type, and captures are always entered into the same field for the same token. As such, multiple different captures can be stored in the same character array if they are separated by null terminators. Only the `attribute` field should be filled this way; the `data` field should only ever contain a single string.

When a section specifies what its attribute is used for, the number enclosed in curly brackets (`{}`) refers to the order of the string in the attribute array, **NOT** the regex capture group. For instance,

```
src="{1}" title="{2}" type="{3}"
```

means that `src` uses the first null-terminated string in the attribute array, `title` uses the second, and `type` uses the third, even though `src` actually uses the second regex capture, `title` uses the third, and `type` uses the fourth.

The attribution specification also indicates how global flags are used in combination with strings in the attribute array. Global flags will also be enclosed in curly brackets.

```
href="{header_identifier}-footnote-{1}"
```

### Root

The `ROOT` token is the base of the document. Before the recursive lexing takes place, the entire document is be assigned as the data field of the `ROOT` token. Recursive lexing starts at the `ROOT` token, and ends when the `ROOT` token has been marked as `RAW`.

### Raw Tokens

Tokens that are `RAW` do not contain any data that can be further lexed or otherwise manipulated.

Some tokens are *inherently* `RAW`; these tokens **MUST** have no child tokens and **SHOULD** have empty `data` fields. The one exception to the empty-data-field rule for `RAW` tokens is the `RAW_DATA` token, which contains raw data within its data field that will not be further manipulated by any step in compilation.

All tokens can be *marked* as `RAW`, which is an imperative part of the compilation process. After a token is lexed, if did not generate any child tokens, it is marked as `RAW` and the lexer moves back up the token tree to its parent. When the lexer moves up the tree, it checks which of the token's children are marked as `RAW`. If any of the children are not `RAW`, it will move to that child node and lex it recursively until it generates an inherently `RAW` token. Once all of a token's children are `RAW`, it marks the current token as `RAW` and moves up the tree. This process continues until the `ROOT` token is marked as `RAW`, whereupon the lexing ends.

To mark a token as `RAW`, it's `type` is negated if it is greater than zero. This avoids negating inherently `RAW` tokens, which are already either negative or zero.

## Context Sensitivity

Some tokens are context sensitive; they will set and/or read global flags to determine their own behavior or the behavior of other tokens. The sections of tokens which exhibit content sensitive behavior will begin with an explanation of this behavior and the flags which the token interacts with.

| Flags | Type | Usage |
|:-:|:-:|:-:|
| `list_rank` | integer | Defines whether a list of given rank is valid |
| `description_list` | boolean | Determines whether elements of a description list can be added to a description list |
| `header_identifier` | char * | Stores the header identifier of the current header |

## Escaped Characters

**IMPORTANT**

Order this **LAST** in lexing. All regular expressions should properly handle escape codes on their own; this token is just to clean up.

---

Example:

```
\*
```

Regex:

```regex
(?<!\\)\\(\S)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `RAW_DATA` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- None

## Empty Line

**CONTEXT SENSITIVE**

Sets the `list_rank` and `description_list` flags to `0`.

---

Example:

```
 
```

Regex:

```ragel
^\s*$
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `RAW_DATA` | `N/A` | `N/A` | `N/A` |

Allowed Internal Tokens:
- N/A

## Headings

**CONTEXT SENSITIVE**

1. Sets the value of the `header_identifier` flag as the compiler-generated header identifier.
2. Sets the `list_rank` and `description_list` flags to `0`.

---

Example:

```
# Heading
```

Regex:

```regex
^(#{1,6})(?:$|[^\S\n]+(.*?)[^\S\n]*$)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HEADING` | `group(2)` | `N/A` | `length(group(1)` |

Allowed Internal Tokens:
- Emphasis
- Links
- Inline Code

### Heading with Identifier

**CONTEXT SENSITIVE**

1. Sets the value of the `header_identifier` flag as the custom header identifier.
2. Sets the `list_rank` and `description_list` flags to `0`.

---

Example:

```
# Heading {identifier}
```

Regex:

```regex
^(#{1,6})[^\S\n]+(|\S.*?[^\S\n]+)\{[^\S\n]*([A-Za-z][a-zA-Z0-9-_:\.]*[^\S\n]*)\}
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HEADING` | `group(2)` | `group(3)` | `length(group(1)` |

Attribute used for: `id="{1}"`

Allowed Internal Tokens:
- Emphasis
- Links
- Inline Code

## Italic

Example:

```
*Italic*
```

Regex:

```regex
(?<!\\)\*(\S.*?\S|\S)(?<!\\)\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ITALIC` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not italic, bold)
- Links
- Inline Code

### Italic containing Bold

Example:

```
*Italic **Bold and Italic***
```

Regex:

```regex
(?<!\\)\*((?:|\S.*?)(?<!\\)\*\*(?:[^\s\*]|[^\s\*].*?[^\s\*])(?<!\\)\*\*(?:|.*?\S))(?<!\\)\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ITALIC` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not italic)
- Links
- Inline Code

## Bold

Example:

```
**Bold**
```

Regex:

```regex
(?<!\\)\*\*(\S.*?\S|\S)(?<!\\)\*\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BOLD` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not italic, bold)
- Links
- Inline Code

### Bold containing Italic

Example:

```
**Bold *Italic and Bold***
```

Regex:

```regex
(?<!\\)\*\*((?:|\S.*?)(?<!\\)\*(?:[^\s\*]|[^\s\*].*?[^\s\*])(?<!\\)\*(?:|.*?\S))(?<!\\)\*\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BOLD` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not bold)
- Links
- Inline Code

## Underline

Example:

```
~Underline~
```

Regex:

```regex
(?<!\\)~(\S.*?\S|\S)(?<!\\)~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `UNDERLINE` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not underline, strikethrough)
- Links
- Inline Code

### Underline containing Strikethrough

Example:

```
~Underline ~~Strikethrough and Underline~~~
```

Regex:

```regex
(?<!\\)~((?:|\S.*?)(?<!\\)~~(?:[^\s~]|[^\s~].*?[^\s~])(?<!\\)~~(?:|.*?\S))(?<!\\)~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `UNDERLINE` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not underline)
- Links
- Inline Code

## Strikethrough

Example:

```
~~Strikethrough~~
```

Regex:

```regex
(?<!\\)~~(\S.*?\S|\S)(?<!\\)~~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `STRIKETHROUGH` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not underline, strikethrough)
- Links
- Inline Code

### Strikethrough containing Underline

Example:

```
~~Strikethrough ~Underline and Strikethrough~~~
```

Regex:

```regex
(?<!\\)~~((?:|\S.*?)(?<!\\)~(?:[^\s~]|[^\s~].*?[^\s~])(?<!\\)~(?:|.*?\S))(?<!\\)~~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `STRIKETHROUGH` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not strikethrough)
- Links
- Inline Code

## Highlight

Example:

```
==Highlight==
```

Regex:

```regex
(?<!\\)==(\S.*?\S|\S)(?<!\\)==
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HIGHLIGHT` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not highlight)
- Links
- Inline Code

## Superscript

Example:

```
^Superscript^
```

Regex:

```regex
(?<!\\)\^(\S.*?\S|\S)(?<!\\)\^
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `SUPERSCRIPT` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not superscript)
- Links
- Inline Code

## Subscript

Example:

```
_Subscript_
```

Regex:

```regex
(?<!\\)_(\S.*?\S|\S)(?<!\\)_
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `SUBSCRIPT` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not subscript)
- Links
- Inline Code

## Blockquote

Example:

```
> Blockquote
```

Regex:

```regex
^(\>+)[^\S\n]+(.*)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BLOCKQUOTE` | `group(2)` | `N/A` | `length(group(1))` |

Allowed Internal Tokens:
- Emphasis
- Inline Code

## Lists

TODO: define formula to calculate rank of list elements.

### Ordered List

**CONTEXT SENSITIVE**

1. Check if `rank` is greater than `list_rank` flag + 1 (default 0).
2. If so, render as indented paragraph.
3. If not, render as ordered list.
1. Set `list_rank` flag to `rank`.

See the Paragraph token section for information on paragraph processing.

---

Example:

```
1. Ordered List Element
```

Regex:

```regex
^([^\S\n]*)([0-9]*\.[^\S\n]*(.*))
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ORDERED_LIST_ELEMENT` | `group(3)` | `N/A` |  |
| `INDENTED_PARAGRAPH` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis
- Inline Code

### Unordered List

**CONTEXT SENSITIVE**

1. Check if `rank` is greater than `list_rank` flag + 1 (default 0).
2. If so, render as indented paragraph.
3. If not, render as unordered list.
1. Set `list_rank` flag to `rank`.

See the Paragraph token section for information on paragraph processing.

---

Example:

```
- Unordered List Element
```

Regex:

```regex
^([^\S\n]*)(-[^\S\n]*(.*))
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `UNORDERED_LIST_ELEMENT` | `group(3)` | `N/A` |  |
| `INDENTED_PARAGRAPH` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis
- Inline Code

### Description List

#### First Key and Value

**CONTEXT SENSITIVE**

1. Set `description_list` flag to `1`.

---

Example:

```
Key
: Value
```

Regex:

```regex
^([^\s:].*)\n:[^\S\n]+(.*)
```

##### Key

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `DESCRIPTION_LIST_KEY` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis

##### Value

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `DESCRIPTION_LIST_VALUE` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis
- Blockquotes
- Inline Code

#### Subsequent Value

**CONTEXT SENSITIVE**

1. If `description_list` flag is `1`, render as description list value.
2. If not, render as paragraph.

See the Paragraph token section for information on paragraph processing.

---

Example:

```
: Value
```

Regex:

```regex
^(:[^\S\n]+(.*))
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `DESCRIPTION_LIST_VALUE` | `group(2)` | `N/A` | `N/A` |
| `PARAGRAPH` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis
- Blockquotes
- Inline Code

## Inline Code

Example:

```
`Inline Code`
```

Regex:

```regex
(?<!\\)`(.+?)(?<!\\)`
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `INLINE_CODE` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- None

## Code Blocks

Example:

```
``
Code Block Content
``
```

Regex:

```regex
^``(|[A-Za-z0-9]*)\n([\s\S]*?)^``
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `CODE_BLOCK` | `group(2)` | `group(1)` | `N/A` |

Attribute used for: `class="language-{1}"`

Allowed Internal Tokens:
- None

## Horizontal Rules

Example:

```
---
```

Regex:

```regex
^---+$
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HORIZONTAL_RULE` | `N/A` | `N/A` | `N/A` |

Allowed Internal Tokens:
- N/A

## Links

Example:

```
[example](https://example.com/)
```

Regex:

```regex
(?<![\\!])\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)")[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `LINK` | `group(1)` | `group(2), group(3)` | `N/A` |

Attribute used for: `href="{1}" title="{2}"`

Allowed Internal Tokens:
- Emphasis
- Images
- Inline Code

## Images

Example:

```
![alt text](example.png "title")
```

Regex:

```regex
(?<!\\)!\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)(?<!\\)")[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `IMAGE` | `group(1)` | `group(2), group(3)` | `N/A` |

Attribute used for: `src="{1}" title="{2}"`

Allowed Internal Tokens:
- Emphasis
- Inline Code

## Audio

Example:

```
![alt text](example.mp3 "title"; audio/mp3)
```

Regex:

```regex
(?<!\\)!\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)(?<!\\)")[^\S\n]*;[^\S\n]*(audio\/(?:mp3|wav|ogg))[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `AUDIO` | `group(1)` | `group(2), group(3), group(4)` | `N/A` |

Attribute used for: `src="{1}" title="{2}" type="{3}"`

Allowed Internal Tokens:
- Emphasis
- Inline Code

## Video

Example:

```
![alt text](example.mp4 "title"; video/mp4)
```

Regex:

```regex
(?<!\\)!\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)(?<!\\)")[^\S\n]*;[^\S\n]*(video\/(?:mp4|webm|ogg))[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `VIDEO` | `group(1)` | `group(2), group(3), group(4)` | `N/A` |

Attribute used for:`src="{0}" title="{2}" type="{3}"`

Allowed Internal Tokens:
- Emphasis
- Inline Code

## Tables

TODO

Example:

```

```

Regex:


```regex

```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `` | `` | `` | `` |

Attribute used for: ``

Allowed Internal Tokens:
- Emphasis
- Inline Code

## Columns

Example:

```
[|
Column 1
||
Column 2
|]
```

Regex:

```regex
^\[\|\n([\s\S]*?)\n^\|\|\n([\s\S]*?)\n^\|\]
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `LEFT_COLUMN` | `group(1)` | `N/A` | `N/A` |
| `RIGHT_COLUMN` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Everything except columns and infoboxes

## Infoboxes

Example:

```
[[ Title
Content
]]
```

Regex:

```regex
^\[\[(?:$|[^\S\n]+(.*?)[^\S\n]*$)\n([\s\S]*)\n^\]\]
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `INFOBOX_TITLE` | `group(1)` | `N/A` | `N/A` |
| `INFOBOX_CONTENT` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens (`INFOBOX_TITLE`):
- Emphasis
- Links
- Inline Code

Allowed Internal Tokens (`INFOBOX_CONTENT`):
- Emphasis
- Images
- Audio
- Video
- Headings (only of level 3)
- Description Lists
- Inline Code

TODO: note - the infobox classes are applied to all children of the infobox.

## References

### Footnote References

**CONTEXT SENSITIVE**

1. Depends on the value of the `header_identifier` flag.

Example:

```
[^1]
```

Regex:

```regex
\[(\^[A-Za-z0-9]*)\]
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FOOTNOTE_REFERENCE` | `N/A` | `group(1)` | `N/A` |

Attribute used for: `href="{header_identifier}-footnote-{1}"`

Allowed Internal Tokens:
- None

### Footnote Notes

**CONTEXT SENSITIVE**

1. Depends on the value of the `header_identifier` flag.

---

Example:

```
[^1]: Footnote
```

Regex:

```regex
^\[(\^[A-Za-z0-9]*)\]:[^\S\n](.+)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FOOTNOTE_NOTE` | `group(2)` | `group(1)` | `N/A` |

Attribute used for: `id="{header_identifier}-footnote-{1}"`

Allowed Internal Tokens:
- Emphasis
- Inline Code

### Endnote References

Example:

```
[_1]
```

Regex:

```regex
\[(_[A-Za-z0-9]*)\]
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ENDNOTE_REFERENCE` | `N/A` | `group(1)` | `N/A` |

Attribute used for: `href="endnote-{1}"`

Allowed Internal Tokens:
- N/A

### Endnote Notes

Example:

```
[_1]: Endnote
```

Regex:

```regex
^\[(_[A-Za-z0-9]*)\]:[^\S\n](.+)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ENDNOTE_NOTE` | `group(2)` | `group(1)` | `N/A` |

Attribute used for: `id="endnote-{1}"`

Allowed Internal Tokens:
- Emphasis
- Inline Code

## 

```regex

```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `` | `` | `` | `` |

Attribute used for: ``

Allowed Internal Tokens:
- Emphasis

## Macros

### Variable Definitions

```regex
^%([A-Za-z][A-Za-z0-9_]*?)[^\S\n]*=[^\S\n]*(.*)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `VARIABLE_DEFINITION` | `group(2)` | `group(1)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- None

### Variable Returns

```regex
\s%([A-Za-z][A-Za-z0-9_]*?)\s
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `VARIABLE_RETURN` | `N\A` | `group(1)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- N/A

### Function Definitions

TODO: Incomplete; allow passing literal parameters inside of quotes

```regex
^%([A-Za-z][A-Za-z0-9_]*?)\([^\S\n]*(|[^\s\(\),\\]+[^\S\n]*(?:,[^\S\n]*[^\s\(\),\\]+[^\S\n]*)*)(?<!\\)\)[^\S\n]*{([\S\s]*?)(?<!\\)}
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FUNCTION_DEFINITION` | `group(3)` | `group(1), group(2)` | `` |

Attribute used for: ``

Allowed Internal Tokens:
- None

### Function Returns

```regex
\s%([A-Za-z][A-Za-z0-9_]*?)\([^\S\n]*(|[^\s\(\),\\]+[^\S\n]*(?:,[^\S\n]*[^\s\(\),\\]+[^\S\n]*)*)(?<!\\)\)\s
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FUNCTION_RETURN` | `N\A` | `group(1), group(2)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- N/A

### Built-In Variable Definitions

```regex
^%(_[A-Za-z0-9_]*?)[^\S\n]*=[^\S\n]*(.*)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BUILT_IN_VARIABLE_DEFINITION` | `group(2)` | `group(1)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- None

### Built-In Variable Returns

```regex
\s%(_[A-Za-z0-9_]*?)\s
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `VARIABLE_RETURN` | `N\A` | `group(1)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- N/A

### Built-In Function Returns

```regex
\s%(_[A-Za-z0-9_]*?)\([^\S\n]*(|[^\s\(\),\\]+[^\S\n]*(?:,[^\S\n]*[^\s\(\),\\]+[^\S\n]*)*)(?<!\\)\)\s
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FUNCTION_RETURN` | `N\A` | `group(1), group(2)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- N/A
