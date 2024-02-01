# DocMark Regex

Tokens are recursively scanned for internal syntax.

## Table of Contents

- [DocMark Regex](#docmark-regex)
	- [Table of Contents](#table-of-contents)
	- [Tokens](#tokens)
	- [Context Sensitivity and Flags](#context-sensitivity-and-flags)
	- [Data vs Attribute Field](#data-vs-attribute-field)
	- [Empty Line](#empty-line)
	- [Escaped Characters](#escaped-characters)
	- [Heading](#heading)
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

## Tokens

```C
typedef enum TokenType {
	RAW_DATA,
	HEADING,
	PARAGRAPH,
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
	HORIZONTAL_RULE,
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
	FOOTNOTE_REFERENCE,
	FOOTNOTE_NOTE,
	ENDNOTE_REFERENCE,
	ENDNOTE_NOTE,

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

	Token* parent;
	Token** children;
	size_t num_children;
} Token;
```

All tokens contain a data field and a list of children tokens. After the entire document is parsed, the data field of each individual token is parsed and the resulting tokens are placed into the child field (make sure to free the data field after it is parsed to minimize memory). If a token's data section is parsed and no tokens can be extracted from it, it is placed into a `RAW_DATA` token, which are themselves not parsed (neither are `HORIZONTAL_RULE` tokens). This ensures that the parser will come to the end of the tree.

## Context Sensitivity and Flags

Some elements are context sensitive, and require setting and reading flags to determine their behavior. The specifications for this behavior will be given in any sections where relevant.

| Flags | Usage |
|:-:|:-:|
| list rank |  |
| definition list |  |
|  |  |

## Data vs Attribute Field

The data field is for data that can be further tokenized, while the attribute field is for raw data that is used to modify the presentation of the data in the data field.

The number of captured groups is always known for each token type, so multiple different captures can be stored in the same character array separated by null terminators. Only fill the attribute field in this way.

When a section specifies what its attribute is used for, the number enclosed in curly brackets refers to the order of the string in the attribute array, NOT the capture group. for instance,

```
src="{1}" title="{2}" type="{3}"
```

means that src is the first null-terminated string in the attribute array, title is the second, and type is the third, even though src is the second capture, title is the third, and type is the fourth for that token.

## Empty Line

**CONTEXT SENSITIVE**

Un-sets all flags.

```ragel
^\s*$
```

## Escaped Characters

**IMPORTANT**

Order this **LAST**

```regex
(?<!\\)\\(\S)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `RAW_DATA` | `group(1)` | `N/A` | `N/A` |

## Heading

```regex
^(#{1,6})(?:$|[^\S\n]+(.*?)[^\S\n]*$)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HEADING` | `group(2)` | `N/A` | `length(group(1)` |

Allowed Internal Tokens:
- Emphasis
- Links

### Heading with Identifier

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

## Italic

```regex
(?<!\\)\*(\S.*?\S|\S)(?<!\\)\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ITALIC` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not italic, bold)
- Links

### Italic containing Bold

```regex
(?<!\\)\*((?:|\S.*?)(?<!\\)\*\*(?:[^\s\*]|[^\s\*].*?[^\s\*])(?<!\\)\*\*(?:|.*?\S))(?<!\\)\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ITALIC` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not italic)
- Links

## Bold

```regex
(?<!\\)\*\*(\S.*?\S|\S)(?<!\\)\*\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BOLD` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not italic, bold)
- Links

### Bold containing Italic

```regex
(?<!\\)\*\*((?:|\S.*?)(?<!\\)\*(?:[^\s\*]|[^\s\*].*?[^\s\*])(?<!\\)\*(?:|.*?\S))(?<!\\)\*\*
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BOLD` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not bold)
- Links

## Underline

```regex
(?<!\\)~(\S.*?\S|\S)(?<!\\)~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `UNDERLINE` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not underline, strikethrough)
- Links

### Underline containing Strikethrough

```regex
(?<!\\)~((?:|\S.*?)(?<!\\)~~(?:[^\s~]|[^\s~].*?[^\s~])(?<!\\)~~(?:|.*?\S))(?<!\\)~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `UNDERLINE` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not underline)
- Links

## Strikethrough

```regex
(?<!\\)~~(\S.*?\S|\S)(?<!\\)~~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `STRIKETHROUGH` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not underline, strikethrough)
- Links

### Strikethrough containing Underline

```regex
(?<!\\)~~((?:|\S.*?)(?<!\\)~(?:[^\s~]|[^\s~].*?[^\s~])(?<!\\)~(?:|.*?\S))(?<!\\)~~
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `STRIKETHROUGH` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not strikethrough)
- Links

## Highlight

```regex
(?<!\\)==(\S.*?\S|\S)(?<!\\)==
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HIGHLIGHT` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not highlight)
- Links

## Superscript

```regex
(?<!\\)\^(\S.*?\S|\S)(?<!\\)\^
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `SUPERSCRIPT` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not superscript)
- Links

## Subscript

```regex
(?<!\\)_(\S.*?\S|\S)(?<!\\)_
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `SUBSCRIPT` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis (not subscript)
- Links

## Blockquote

```regex
^(\>+)[^\S\n]+(.*)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `BLOCKQUOTE` | `group(2)` | `N/A` | `length(group(1))` |

Allowed Internal Tokens:
- Emphasis

## Lists

TODO: define formula to calculate rank of list elements.

### Ordered List

**CONTEXT SENSITIVE**

Check if current rank is greater than list rank flag + 1 (default 0). If so, render as indented paragraph. If not, render as ordered list. Set list rank flag to current rank.

```regex
^([^\S\n]*)([0-9]*\.[^\S\n]*(.*))
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ORDERED_LIST_ELEMENT` | `group(3)` | `N/A` |  |
|
| `INDENTED_PARAGRAPH` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis

### Unordered List

**CONTEXT SENSITIVE**

Check if current rank is greater than list rank flag + 1 (default 0). If so, render as indented paragraph. If not, render as unordered list. Set list rank flag to current rank.

```regex
^([^\S\n]*)(-[^\S\n]*(.*))
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `UNORDERED_LIST_ELEMENT` | `group(3)` | `N/A` |  |
|
| `INDENTED_PARAGRAPH` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis

### Description List

#### First Key and Value

**CONTEXT SENSITIVE**

Set description list flag to 1.

```regex
^([^\s:].*)\n:[^\S\n]+(.*)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `DESCRIPTION_LIST_KEY` | `group(1)` | `N/A` | `N/A` |
| `DESCRIPTION_LIST_VALUE` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis

#### Subsequent Value

If description list flag is 1, render as description list value. If not, render as paragraph.

```regex
^(:[^\S\n]+(.*))
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `DESCRIPTION_LIST_VALUE` | `group(2)` | `N/A` | `N/A` |
|
| `PARAGRAPH` | `group(1)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Emphasis

## Inline Code

```regex
(?<!\\)`(.+?)(?<!\\)`
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `INLINE_CODE` | `group(1)` | `N/A` | `N/A` |

## Code Blocks

```regex
^``(|[A-Za-z0-9]*)\n([\s\S]*?)^``
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `CODE_BLOCK` | `group(2)` | `group(1)` | `N/A` |

Attribute used for: `class="language-{1}"`

## Horizontal Rules

```regex
^---+$
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `HORIZONTAL_RULE` | `N/A` | `N/A` | `N/A` |

Allowed Internal Tokens:
- N/A

## Links

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

## Images

```regex
(?<!\\)!\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)(?<!\\)")[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `IMAGE` | `group(1)` | `group(2), group(3)` | `N/A` |

Attribute used for: `src="{1}" title="{2}"`

Allowed Internal Tokens:
- Emphasis

## Audio

```regex
(?<!\\)!\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)(?<!\\)")[^\S\n]*;[^\S\n]*(audio\/(?:mp3|wav|ogg))[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `AUDIO` | `group(1)` | `group(2), group(3), group(4)` | `N/A` |

Attribute used for: `src="{1}" title="{2}" type="{3}"`

Allowed Internal Tokens:
- Emphasis

## Video

```regex
(?<!\\)!\[[^\S\n]*(\S.*?)[^\S\n]*(?<!\\)\]\([^\S\n]*(\S*?)(?:|[^\S\n]+"(.*?)(?<!\\)")[^\S\n]*;[^\S\n]*(video\/(?:mp4|webm|ogg))[^\S\n]*(?<!\\)\)
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `VIDEO` | `group(1)` | `group(2), group(3), group(4)` | `N/A` |

Attribute used for: `src="{1}" title="{2}" type="{3}"`

Allowed Internal Tokens:
- Emphasis

## Tables

```regex

```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `` | `` | `` | `` |

Attribute used for: ``

Allowed Internal Tokens:
- Emphasis

## Columns

```regex
^\[\|\n([\s\S]*?)\n^\|\|\n([\s\S]*?)\n^\|\]
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `LEFT_COLUMN` | `group(1)` | `N/A` | `N/A` |
| `RIGHT_COLUMN` | `group(2)` | `N/A` | `N/A` |

Allowed Internal Tokens:
- Everything except columns and infoboxes are valid

## Infoboxes

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

Allowed Internal Tokens (`INFOBOX_CONTENT`):
- Emphasis
- Images
- Audio
- Video
- Headings (only of level 3)
- Description Lists

The infobox classes are applied to all children of the infobox

## References

### Footnote References

```regex
\[(\^[A-Za-z0-9]*)\]
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FOOTNOTE_REFERENCE` | `N/A` | `group(1)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- None

### Footnote Notes

```regex
^\[(\^[A-Za-z0-9]*)\]:.+
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `FOOTNOTE_NOTE` | `N/A` | `group(1)` | `N/A` |

Attribute used for: ``

Allowed Internal Tokens:
- N/A

### Endnote References

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

```regex
^\[(_[A-Za-z0-9]*)\]:.+
```

| type | data | attribute | rank |
|:-:|:-:|:-:|:-:|
| `ENDNOTE_NOTE` | `N/A` | `group(1)` | `N/A` |

Attribute used for: `id="endnote-{1}"`

Allowed Internal Tokens:
- TODO

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
