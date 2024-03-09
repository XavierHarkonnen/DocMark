#include "docmark_debug.h"

#include <stdio.h>

static void print_null(const char *field, const char *string) {
	if (string) {
		printf("\t%s:\n%s\n", field, string);
	} else {
		printf("\t%s: NULL\n", field);
	}
}

static void print_type(TokenType type) {
	printf("\ttype: ");

	if (type < 0) {
		type = -type;
		printf("RAW ");
	}

	switch (type) {
		case -HORIZONTAL_RULE: printf("HORIZONTAL_RULE\n"); break;
		case -FOOTNOTE_REFERENCE: printf("FOOTNOTE_REFERENCE\n"); break;
		case -ENDNOTE_REFERENCE: printf("ENDNOTE_REFERENCE\n"); break;

		case RAW_DATA: printf("RAW_DATA\n"); break;
		
		case ROOT: printf("ROOT\n"); break;
		case HEADING: printf("HEADING\n"); break;
		case ITALIC: printf("ITALIC\n"); break;
		case BOLD: printf("BOLD\n"); break;
		case UNDERSCORE: printf("UNDERSCORE\n"); break;
		case STRIKETHROUGH: printf("STRIKETHROUGH\n"); break;
		case HIGHLIGHT: printf("HIGHLIGHT\n"); break;
		case SUPERSCRIPT: printf("SUPERSCRIPT\n"); break;
		case SUBSCRIPT: printf("SUBSCRIPT\n"); break;
		case BLOCKQUOTE: printf("BLOCKQUOTE\n"); break;
		case ORDERED_LIST: printf("ORDERED_LIST\n"); break;
		case UNORDERED_LIST: printf("UNORDERED_LIST\n"); break;
		case DESCRIPTION_LIST: printf("DESCRIPTION_LIST\n"); break;
		case LIST_ELEMENT: printf("LIST_ELEMENT\n"); break;		
		case DESCRIPTION_LIST_KEY: printf("DESCRIPTION_LIST_KEY\n"); break;
		case DESCRIPTION_LIST_VALUE: printf("DESCRIPTION_LIST_VALUE\n"); break;
		case INLINE_CODE: printf("INLINE_CODE\n"); break;
		case START_CODE_BLOCK: printf("START_CODE_BLOCK\n"); break;
		case END_CODE_BLOCK: printf("END_CODE_BLOCK\n"); break;
		case LINK: printf("LINK\n"); break;
		case IMAGE: printf("IMAGE\n"); break;
		case AUDIO: printf("AUDIO\n"); break;
		case VIDEO: printf("VIDEO\n"); break;
		case TOP_TITLED_TABLE: printf("TOP_TITLED_TABLE\n"); break;
		case LEFT_TITLED_TABLE: printf("LEFT_TITLED_TABLE\n"); break;
		case TWO_WAY_TABLE: printf("TWO_WAY_TABLE\n"); break;
		case LEFT_COLUMN: printf("LEFT_COLUMN\n"); break;
		case DIVIDER_COLUMN: printf("DIVIDER_COLUMN\n"); break;
		case RIGHT_COLUMN: printf("RIGHT_COLUMN\n"); break;
		case INFOBOX_TITLE: printf("INFOBOX_TITLE\n"); break;
		case INFOBOX_CONTENT: printf("INFOBOX_CONTENT\n"); break;
		case FOOTNOTE_NOTE: printf("FOOTNOTE_NOTE\n"); break;
		case ENDNOTE_NOTE: printf("ENDNOTE_NOTE\n"); break;
		case PARAGRAPH: printf("PARAGRAPH\n"); break;
		case INDENTED_PARAGRAPH: printf("INDENTED PARAGRAPH\n"); break;
		case VARIABLE_DEFINITION: printf("VARIABLE_DEFINITION\n"); break;
		case VARIABLE_RETURN: printf("VARIABLE_RETURN\n"); break;
		case FUNCTION_DEFINITION: printf("FUNCTION_DEFINITION\n"); break;
		case FUNCTION_RETURN: printf("FUNCTION_RETURN\n"); break;
		case BUILT_IN_VARIABLE_DEFINITION: printf("BUILT_IN_VARIABLE_DEFINITION\n"); break;
		case BUILT_IN_VARIABLE_RETURN: printf("BUILT_IN_VARIABLE_RETURN\n"); break;
		case BUILT_IN_FUNCTION_RETURN: printf("BUILT_IN_FUNCTION_RETURN\n"); break;
		default: printf("Unknown Type (%d)\n", type);
	}
}

void print_token(const char *token_name, Token *token) {
	printf("{\tToken: %s\n", token_name);

	if (!token) {
		printf("\tNULL\n");
		printf("}\n");
		return;
	}

	print_type(token->type);
	print_null("data", token->data);
	print_null("attribute", token->attribute);
	printf("\trank: %d\n", token->rank);
	printf("\tnum_children: %d\n", token->num_children);

	printf("}\n");
}