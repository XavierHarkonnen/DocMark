
### Columns

```
[
Lorem ipsum dolor sit amet, ...
|
Lorem ipsum dolor sit amet, ...
]
```

```
<div class="row">
	<div class="column">Lorem ipsum dolor sit amet, ...</div>
	<div class="column">Lorem ipsum dolor sit amet, ...</div>
</div>
```

```
<style>
.column-box {
	display: flex;
	justify-content: space-between; /* Adjust as needed */
}

.column {
	width: 48%; /* Adjust as needed */
	padding: 10px; /* Adjust the padding as needed */
	box-sizing: border-box; /* Ensures padding is included in the width */
	margin-bottom: 10px; /* Optional: Add margin between columns */
}
</style>
```
<style>
.column-box {
	display: flex;
	justify-content: space-between; /* Adjust as needed */
}

.column {
	width: 48%; /* Adjust as needed */
	padding: 10px; /* Adjust the padding as needed */
	box-sizing: border-box; /* Ensures padding is included in the width */
	margin-bottom: 10px; /* Optional: Add margin between columns */
}
</style>

<div class="column-box">
	<div class="column">Lorem ipsum dolor sit amet, ...</div>
	<div class="column">Lorem ipsum dolor sit amet, ...</div>
</div>


### Lists

### Checklists

## Limited Inline CSS

## Tables

Markdown Standard, Left-headed, bidirectional, merging cells, etc.

## Superscripts and Subscripts

| Markup | HTML | Render |
|:-:|:-:|:-:|
| `^Superscript^` | `<sup>Superscript</sup>` | <sup>Superscript</sup> |
| `_Subscript_` | `<sub>Subscript</sub>` | <sub>Subscript</sub> |

### TECHNICALLY HTML BUT SUPER EASY

| HTML | Render |
|:-:|:-:|
| `<u>Underlined Text</u>` | <u>Underlined Text</u> |
| `<s>Struck-through Text</s>` | <s>Struck-through Text</s> |

## Block Quotes

### Nested Blockquotes

## Links

[Name](path/to/destination) 

## Media

![Hover Text](path/to/destination)

Preceding a link to an image with an exclamation mark will insert it into the document.

### Escape Character

The escape character for the `Expansive Markup (name pending)` language is the backslash (`\`). It serves two purposes:

#### Character Literals

To display a character that would otherwise be used to format text, precede it with a backslash. For example, to display a backtick, you would enter `` \` ``.

#### Escape Sequences

think of this later

## Functions and Variables

Tokens that begin with a percentage symbol (`%`) are expanded at compile time. `%variable` is a variable, with a determinate value, while `%function()` is a function that will be evaluated based on its parameters. Functions and variables must be defined in the pages preamble (or included from another file). The preamble of a page is the sector before a double percentage symbol, and will not be rendered into HTML.

```
%variable = value
%function(parameter) {
	if():
}
%%
```

The scripting syntax for these functions and variables must be as C-like as possible.

## LaTeX Math

### Inline LaTeX Math

`$f(x)=2x+3$`

### Display LaTeX Math

```
$$
f(x)=2x+3
$$
```

## Inline HTML

For when all else fails

# TODO: SPECIAL SYMBOLS

Allowed special symbols

```
\ : Escape Character
~ : 
` : Code Blocks
# : Headers
$ : LaTeX Math
% : Functions and Variables
& : 
* : Italics and Bold
^ : Superscript
_ : Subscript
- : Unordered Lists
+ : 
= : 
< : Inline HTML // kind of
> : Block Quote
| : 
{ : 
} : 
[ : 
] : 
```

Forbidden special symbols (except in structures)

```
! : Punctuation is commonly used
( : Punctuation is commonly used
) : Punctuation is commonly used
, : Punctuation is commonly used
. : Punctuation is commonly used
? : Punctuation is commonly used
" : Punctuation is commonly used
' : Punctuation is commonly used
; : Punctuation is commonly used
: : Punctuation is commonly used
@ : emails are too common
 : 
 : 
 : 
 : 
```

```
/
```

## Columns

## Footnotes

## Compiler Flags

| Flag | Meaning |
|---|---|
| --keep-comments | compile comments instead of discarding |
