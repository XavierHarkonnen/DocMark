# Preprocessor

## Steps

### Initial Processing

1. The input file is read into memory and broken into lines.
2. All comments are replaced with single spaces.

### Tokenization

## Inline Code and Code Blocks

Any data that would normally be preprocessed will not be preprocessed if it is within an inline code section or a code block.

However, variables and functions preceded by a (single backtick (`` ` ``) | backslash (`\`)) *will* be expanded in the code block. There is no way to expand variables inside of inline code, but a function to transmute a variable into inline code is easy to write:

```
%insert_inline(string1, value) {
	string result = "`"
	result = strcat(result, string1)
	result = strcat(result, value)
	result = strcat(result, "`")
	return result;
}

%value = 12

The line %insert_inline("int x = ", %value) ...
```

becomes

```
The line `int x = 12` ...
```

## Comments

Comments follow the same syntax as C/C++: characters between `//` and `\n`, as well as characters between `/*` and `*/` are discarded.

## Preprocessor Directives

### Macros

A macro is a statement that is evaluated and expanded into the resulting document. Macros must begin with an alphabetic character and can only contain alphanumeric characters.

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

Functions return in two ways. It is either be assigned to another variable (`%var = %func(val)`), or inserted at the location that it is called (`%func(val)`).

```
%func(param) {
	...;
	return ...;
}
```

TODO: Choose or design a language for the macros.

### Inherent

Variables and functions that begin with an underscore are built-in, and cannot be defined by the user.

#### %_css

Specifies the path to the CSS of the document.

#### %_title

Specifies the title of the document.

#### %_timestamp()

Returns the current date and time.

#### %_insert()

Returns the contents of another file at the location of the macro. Takes a single argument, the path to the inserted file.

#### %_insert()()

Returns the contents of another file at the location of the macro as a function. It first takes a single argument, the path to the inserted file, and then any number of arguments as specified by the inserted file.

```
// Inserted file

| %1 | %2 |
|---|---|
| %3 | %4 |
```

The second set of values passed to `%insert()()` will be inserted into the file at locations specified by their order (the first argument is inserted at `%1`, the second at `%2`, and so on).

#### %_fetch()

Dynamically fetches data from another location and returns it. Takes a single argument, the URL of the data.