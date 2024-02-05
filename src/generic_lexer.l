%top{
	#include "generic_lexer.h"

	#include <stdio.h>
	#include <string.h>

	#define TAB_SIZE 2

	Token *current_token;

	unsigned int list_rank = 0;
	int description_list = 0;
}

%option noyywrap

%%
^\#{1,6}[ \t]+.*$ { // Header
	unsigned int rank = 0;
	while (*yytext == '#') {
		++rank;
		++yytext;
	}
	while (*yytext == ' ' || *yytext == '\t') {
		++yytext;
	}

	add_child(HEADING, yytext, NULL, rank, current_token);

	list_rank = 0;
	description_list = 0;
}

^\>+[ \t]+(.*) { // Blockquote
	unsigned int rank = 0;
	++yytext;
	while (*yytext == '>') {
		++rank;
		++yytext;
	}
	while (*yytext == ' ' || *yytext == '\t') {
		++yytext;
	}

	add_child(BLOCKQUOTE, yytext, NULL, rank, current_token);

	list_rank = 0;
	description_list = 0;
}

^[ \t]*[0-9]*\.[ \t]+(.*) { // Ordered List
	unsigned int rank = 0;
	while (*yytext == ' ' || *yytext == '\t') {
		if (*yytext == ' ') { ++rank; }
		else { rank += TAB_SIZE; }
		++yytext;
	}
	list_rank = rank;

	while (*yytext >= '0' && *yytext <= '9') {
		++yytext;
	}

	++yytext;
	while (*yytext == ' ' || *yytext == '\t') {
		++yytext;
	}

	add_child(ORDERED_LIST_ELEMENT, yytext, NULL, rank, current_token);

	description_list = 0;
}

^[ \t]*\-[ \t]+(.*) { // Unordered List
	unsigned int rank = 0;
	while (*yytext == ' ' || *yytext == '\t') {
		if (*yytext == ' ') { ++rank; }
		else { rank += TAB_SIZE; }
		++yytext;
	}
	list_rank = rank;

	++yytext;
	while (*yytext == ' ' || *yytext == '\t') {
		++yytext;
	}

	add_child(UNORDERED_LIST_ELEMENT, yytext, NULL, rank, current_token);

	description_list = 0;
}

^[^ \t\r\n\-].*\n:[ \t]+(.*) { // Description List: First Key and Value
	char* key = strdup(yytext);
	char* newline_position = strchr(key, '\n');

	*newline_position = '\0';
	add_child(DESCRIPTION_LIST_KEY, key, NULL, 0, current_token);

	char* value = newline_position + 2 + strspn(newline_position + 2, " \t");
	add_child(DESCRIPTION_LIST_VALUE, value, NULL, 0, current_token);

	free(key);

	list_rank = 0;
}

^:[ \t]+(.*) { // Description List: Subsequent Value
	if (description_list) {
		++yytext;
		while (*yytext == ' ' || *yytext == '\t') {
			++yytext;
		}

		add_child(DESCRIPTION_LIST_VALUE, yytext, NULL, 0, current_token);
	}

	add_child(PARAGRAPH, yytext, NULL, 0, current_token);

	list_rank = 0;
}

.+ { // Paragraph
	add_child(PARAGRAPH, yytext, NULL, 0, current_token);

	list_rank = 0;
	description_list = 0;
}

. {
	printf("Error: skipped: %s\n", yytext);

	list_rank = 0;
	description_list = 0;
}

\n {
	list_rank = 0;
	description_list = 0;
}

%%

int generic_lex(Token *token) {
	yyin = fmemopen(token->data, strlen(token->data), "r");
	current_token = token;
	return yylex();
}