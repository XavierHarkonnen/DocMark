#include "generic_lexer.h"

#include "docmark_lexers.h"

int lex_recursive(Token *token) {
	if (token->num_children > 0) {
		for (int i = 0; i < token->num_children; i++) {
			lex_recursive(token->children[i]);
		}
	} else {
		lex_token(token);
	}
}

static int lex_token(Token *token) {
	switch (token->type) {
		case ROOT:
			return lex_root(token);
		case HEADING:
			return lex_heading(token);
		case ITALIC:
			return lex_(token);
		case BOLD:
			return lex_(token);
		case UNDERSCORE:
			return lex_(token);
		case STRIKETHROUGH:
			return lex_(token);
		case HIGHLIGHT:
			return lex_(token);
		case SUPERSCRIPT:
			return lex_(token);
		case SUBSCRIPT:
			return lex_(token);
		case BLOCKQUOTE:
			return lex_(token);
		case ORDERED_LIST:
			return lex_(token);
		case UNORDERED_LIST:
			return lex_(token);
		case DESCRIPTION_LIST:
			return lex_(token);
		case LIST_ELEMENT:
			return lex_(token);
		case DESCRIPTION_LIST_KEY:
			return lex_(token);
		case DESCRIPTION_LIST_VALUE:
			return lex_(token);
		case LINK:
			return lex_(token);
		case IMAGE:
			return lex_(token);
		case AUDIO:
			return lex_(token);
		case VIDEO:
			return lex_(token);
		case TOP_TITLED_TABLE:
			return lex_(token);
		case LEFT_TITLED_TABLE:
			return lex_(token);
		case TWO_WAY_TABLE:
			return lex_(token);
		case INFOBOX_TITLE:
			return lex_(token);
		case INFOBOX_CONTENT:
			return lex_(token);
		case FOOTNOTE_NOTE:
			return lex_(token);
		case ENDNOTE_NOTE:
			return lex_(token);
		case PARAGRAPH:
			return lex_(token);
		case INDENTED_PARAGRAPH:
			return lex_(token);
		case VARIABLE_DEFINITION:
			return lex_(token);
		case VARIABLE_RETURN:
			return lex_(token);
		case FUNCTION_DEFINITION:
			return lex_(token);
		case FUNCTION_RETURN:
			return lex_(token);
		case BUILT_IN_VARIABLE_DEFINITION:
			return lex_(token);
		case BUILT_IN_VARIABLE_RETURN:
			return lex_(token);
		case BUILT_IN_FUNCTION_RETURN:
			return lex_(token);
		default:
			printf("WARNING: Unknown token type: %d\n", token->type);
			return 0;
	}
}