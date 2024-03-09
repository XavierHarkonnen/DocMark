#include "generic_lexer.h"

#include "docmark_lexers.h"

static int lex_token(Token *token) {
	switch (token->type) {
		case ROOT:
			return lex_root(token);
		case HEADING:
			return lex_heading(token);
		default:
			return 0;
	}
}

static int lex_recursive(Token *token) {
	if (token->num_children > 0) {
		for (int i = 0; i < token->num_children; i++) {
			lex_recursive(token->children[i]);
		}
	} else {
		lex_token(token);
	}
}

int lex_tree(Token *root_token) {
	lex_recursive(root_token);
}