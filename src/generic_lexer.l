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
^---+$ { // HORIZONTAL_RULE
	add_child(HORIZONTAL_RULE, NULL, NULL, 0, current_token);

	list_rank = 0;
	description_list = 0;
}

\[\^[a-zA-Z0-9\-_:\.]+\] { // FOOTNOTE_REFERENCE
	yytext += 2; // Points to the start of the substring
	int length = yyleng - 3; // Calculate the length of the substring
	char data[length + 1]; // Allocate space for the substring
	strncpy(data, yytext, length); // Copy the substring
	data[length] = '\0'; // Null-terminate the string

	add_child(FOOTNOTE_REFERENCE, NULL, data, 0, current_token);
}

\[_[a-zA-Z0-9\-_:\.]+\] { // ENDNOTE_REFERENCE
	yytext += 2; // Points to the start of the substring
	int length = yyleng - 3; // Calculate the length of the substring
	char data[length + 1]; // Allocate space for the substring
	strncpy(data, yytext, length); // Copy the substring
	data[length] = '\0'; // Null-terminate the string

	add_child(ENDNOTE_REFERENCE, NULL, data, 0, current_token);
}

 { // RAW_DATA = 0
}

 { // ROOT
}

^\#{1,6}[ \t]+[^\{\n]+[ \t]+\{[ \t]*[A-Za-z][a-zA-Z0-9\-_:\.]*[ \t]*\}$ { // HEADING with specified identifier (TODO: NONGREEDY, permit "{" in data?)
	unsigned int rank = 0;
	while (*yytext == '#') {
		++rank;
		++yytext;
	}
	while (*yytext == ' ' || *yytext == '\t') {
		++yytext;
	}

	char *identifier = strchr(yytext, '{') + 1;
	char *identifier_end = identifier;
	char *data_end = identifier - 2;
	while (*identifier == ' ' || *identifier == '\t') {
		++identifier;
		++identifier_end;
	}
	++identifier_end;
	while (*identifier_end != ' ' && *identifier_end != '\t' && *identifier_end != '}') {
		++identifier_end;
	}
	while (*data_end == ' ' || *data_end == '\t') {
		--data_end;
	}

	*(++data_end) = '\0';
	*(identifier_end) = '\0';

	add_child(HEADING, strdup(yytext), strdup(identifier), rank, current_token);

	list_rank = 0;
	description_list = 0;
}

^\#{1,6}[ \t]+.*$ { // HEADING
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

 { // ITALIC
}

 { // BOLD
}

 { // UNDERSCORE
}

 { // STRIKETHROUGH
}

 { // HIGHLIGHT
}

 { // SUPERSCRIPT
}

 { // SUBSCRIPT
}

^\>+[ \t]+(.*) { // BLOCKQUOTE
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

^[ \t]*[0-9]*\.[ \t]+(.*) { // ORDERED_LIST_ELEMENT
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

^[ \t]*\-[ \t]+(.*) { // UNORDERED_LIST_ELEMENT
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

^[^ \t\r\n\-].*\n:[ \t]+(.*) { // DESCRIPTION_LIST_KEY and first DESCRIPTION_LIST_VALUE
	char* key = strdup(yytext);
	char* newline_position = strchr(key, '\n');

	*newline_position = '\0';
	add_child(DESCRIPTION_LIST_KEY, key, NULL, 0, current_token);

	char* value = newline_position + 2 + strspn(newline_position + 2, " \t");
	add_child(DESCRIPTION_LIST_VALUE, value, NULL, 0, current_token);

	free(key);

	list_rank = 0;
}

^:[ \t]+(.*) { // following DESCRIPTION_LIST_VALUE
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

 { // INLINE_CODE
}

 { // CODE_BLOCK
}

 { // LINK
}

 { // IMAGE
}

 { // AUDIO
}

 { // VIDEO
}

 { // TOP_TITLED_TABLE
}

 { // LEFT_TITLED_TABLE
}

 { // TWO_WAY_TABLE
}

 { // LEFT_COLUMN
}

 { // RIGHT_COLUMN
}

 { // INFOBOX_TITLE
}

 { // INFOBOX_CONTENT
}

 { // FOOTNOTE_NOTE
}

 { // ENDNOTE_NOTE
}

.+ { // PARAGRAPH
	add_child(PARAGRAPH, yytext, NULL, 0, current_token);

	list_rank = 0;
	description_list = 0;
}

 { // VARIABLE_DEFINITION
}

 { // VARIABLE_RETURN
}

 { // FUNCTION_DEFINITION
}

 { // FUNCTION_RETURN
}

 { // BUILT_IN_VARIABLE_DEFINITION
}

 { // BUILT_IN_VARIABLE_RETURN
}

 { // BUILT_IN_FUNCTION_RETURN
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