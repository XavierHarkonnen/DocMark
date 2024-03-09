#ifndef DOCMARK_TOKEN_H
#define DOCMARK_TOKEN_H

#include <stdlib.h>

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
	ORDERED_LIST,
	UNORDERED_LIST,
	DESCRIPTION_LIST,
	LIST_ELEMENT,
	DESCRIPTION_LIST_KEY,
	DESCRIPTION_LIST_VALUE,
	INLINE_CODE,
	START_CODE_BLOCK,
	END_CODE_BLOCK,
	LINK,
	IMAGE,
	AUDIO,
	VIDEO,
	TOP_TITLED_TABLE,
	LEFT_TITLED_TABLE,
	TWO_WAY_TABLE,
	LEFT_COLUMN,
	DIVIDER_COLUMN,
	RIGHT_COLUMN,
	INFOBOX_TITLE,
	INFOBOX_CONTENT,
	FOOTNOTE_NOTE,
	ENDNOTE_NOTE,
	PARAGRAPH,
	INDENTED_PARAGRAPH,
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

	struct Token *parent;
	struct Token **children;
	unsigned int num_children;
} Token;

Token *root_token(const char *data);

void mark_raw(Token *token);

int is_raw(Token *token);

void add_child(
	const TokenType type,
	const char *data,
	const char *attribute,
	const unsigned int rank,
	Token *parent
);

void delete_children(Token **token);

void delete_token(Token **token);

#endif