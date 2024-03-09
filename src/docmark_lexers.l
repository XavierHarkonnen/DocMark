%top{
	#include "docmark_lexers.h"
	#include "docmark_lexing_standards.h"

	#include <stdio.h>
	#include <string.h>


	Token *current_token;

	int LAST_CONDITION = 0;

	// FLAGS
	unsigned int heading_rank = 0;
	int in_left_column = 0;
	int in_right_column = 0;
}

%option noyywrap
%option nodefault

%x LEX_ROOT
%x LEX_HEADING

%x IN_HEADING
%x IN_BLOCKQUOTE
%x IN_CODE_BLOCK
%x IN_PARAGRAPH

%%
<LEX_ROOT>^---+$ { // HORIZONTAL_RULE
	add_child(HORIZONTAL_RULE, NULL, NULL, 0, current_token);
}

<LEX_ROOT>^\#{1,6}[ \t]+ { // Start Heading
	unsigned int rank = 0;
	while (*yytext == '#') {
		++rank;
		++yytext;
	}
	heading_rank = rank;

	LAST_CONDITION = YY_START;
	BEGIN(IN_HEADING);
}

<IN_HEADING>.+[ \t]+\{[ \t]*[A-Za-z][a-zA-Z0-9\-_:\.]*[ \t]*\}$ { // HEADING with specified identifier
	char *identifier = strrchr(yytext, '{') + 1;
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

	add_child(HEADING, strdup(yytext), strdup(identifier), heading_rank, current_token);

	BEGIN(LAST_CONDITION);
}

<IN_HEADING>.*$ { // HEADING
	int len = strlen(yytext); // Strip trailing spaces from yytext
	while (len > 0 && (yytext[len - 1] == ' ' || yytext[len - 1] == '\t')) {
		yytext[len - 1] = '\0';
		len--;
	}

	add_child(HEADING, yytext, NULL, heading_rank, current_token);

	BEGIN(LAST_CONDITION);
}

<LEX_ROOT>^(\>+[ \t]+.*\n)+ { // BLOCKQUOTE
	char *stripped_data = (char *) malloc((strlen(yytext) + 1) * sizeof(char));
	char *stripped_data_counter = stripped_data;

	while (*yytext == '>') {
		++yytext; // Consume the first `>`
		while (*yytext == ' ' || *yytext == '\t') {
			++yytext; // Consume whitespace
		}
		while (*yytext != '\n') {
			*stripped_data_counter = *yytext;
			++yytext;
			++stripped_data_counter;
		}
		*stripped_data_counter = *yytext;
		++yytext;
		++stripped_data_counter;
	}
	*(--stripped_data_counter) = '\0'; // Discard trailing newline

	add_child(BLOCKQUOTE, stripped_data, NULL, 0, current_token);
	free(stripped_data);
}

<LEX_ROOT>^([0-9]+\.[ \t]+.*\n(([ ]{2,}|\t)+.*\n)*)+ { // ORDERED_LIST		/* WARNING: Must change `{2,}` to `{TAB_SIZE,}` MANUALLY! */
	add_child(ORDERED_LIST, NULL, NULL, 0, current_token);
	Token *working_token = current_token->children[current_token->num_children - 1];

	char *stripped_data = (char *) malloc((strlen(yytext) + 1) * sizeof(char));
	char *stripped_data_counter = stripped_data;

	for (;;) {
		if (*yytext >= '0' && *yytext <= '9') {
			if (stripped_data_counter != stripped_data) { // Create token from last set of data
				*(--stripped_data_counter) = '\0'; // Discard trailing newline
				add_child(LIST_ELEMENT, stripped_data, NULL, 0, working_token);
				stripped_data_counter = stripped_data;
			}
			while (*yytext >= '0' && *yytext <= '9') {
				++yytext; // Consume the numerical signifier
			}
			++yytext; // Consume the period
			while (*yytext == ' ' || *yytext == '\t') {
				++yytext; // Consume whitespace
			}
			while (*yytext != '\n') {
				*stripped_data_counter = *yytext;
				++yytext;
				++stripped_data_counter;
			}
			*stripped_data_counter = *yytext;
			++yytext;
			++stripped_data_counter;
		}
		else if (*yytext == ' ' || *yytext == '\t') {
			unsigned int spacing = 0;
			while ((*yytext == ' ' || *yytext == '\t') && spacing < TAB_SIZE) {
				if (*yytext == ' ') {
					++spacing;
					++yytext;
				}
				else {
					spacing += TAB_SIZE;
					++yytext;
				}
			}
			while (*yytext != '\n') {
				*stripped_data_counter = *yytext;
				++yytext;
				++stripped_data_counter;
			}
			*stripped_data_counter = *yytext;
			++yytext;
			++stripped_data_counter;
		}
		else { // Create token from final set of data
			*(--stripped_data_counter) = '\0'; // Discard trailing newline
			stripped_data_counter = stripped_data;
			add_child(LIST_ELEMENT, stripped_data, NULL, 0, working_token);
			break;
		}
	}
}

<LEX_ROOT>^(-[ \t]+.*\n(([ ]{2,}|\t)+.*\n)*)+ { // UNORDERED_LIST		/* WARNING: Must change `{2,}` to `{TAB_SIZE,}` ! MANUALLY ! */
	add_child(UNORDERED_LIST, NULL, NULL, 0, current_token);
	Token *working_token = current_token->children[current_token->num_children - 1];

	char *stripped_data = (char *) malloc((strlen(yytext) + 1) * sizeof(char));
	char *stripped_data_counter = stripped_data;

	for (;;) {
		if (*yytext == '-') {
			if (stripped_data_counter != stripped_data) { // Create token from last set of data
				*(--stripped_data_counter) = '\0'; // Discard trailing newline
				add_child(LIST_ELEMENT, stripped_data, NULL, 0, working_token);
				stripped_data_counter = stripped_data;
			}
			++yytext; // Consume the signifying dash
			while (*yytext == ' ' || *yytext == '\t') {
				++yytext; // Consume whitespace
			}
			while (*yytext != '\n') {
				*stripped_data_counter = *yytext;
				++yytext;
				++stripped_data_counter;
			}
			*stripped_data_counter = *yytext;
			++yytext;
			++stripped_data_counter;
		}
		else if (*yytext == ' ' || *yytext == '\t') {
			unsigned int spacing = 0;
			while ((*yytext == ' ' || *yytext == '\t') && spacing < TAB_SIZE) {
				if (*yytext == ' ') {
					++spacing;
					++yytext;
				}
				else {
					spacing += TAB_SIZE;
					++yytext;
				}
			}
			while (*yytext != '\n') {
				*stripped_data_counter = *yytext;
				++yytext;
				++stripped_data_counter;
			}
			*stripped_data_counter = *yytext;
			++yytext;
			++stripped_data_counter;
		}
		else { // Create token from final set of data
			*(--stripped_data_counter) = '\0'; // Discard trailing newline
			stripped_data_counter = stripped_data;
			add_child(LIST_ELEMENT, stripped_data, NULL, 0, working_token);
			break;
		}
	}
}

<LEX_ROOT>^([^ \t\r\n\-:].*\n(:[ \t]+.*\n)+)+ { // DESCRIPTION_LIST
	add_child(DESCRIPTION_LIST, NULL, NULL, 0, current_token);
	Token *working_token = current_token->children[current_token->num_children - 1];

	while (*yytext != '\0') {
		if (*yytext == ':') {
			++yytext;
			while (*yytext == ' ' || *yytext == '\t') {
				++yytext;
			}
			char *data_pointer = yytext;
			while (*data_pointer != '\n') {
				++data_pointer;
			}
			*data_pointer = '\0';
			add_child(DESCRIPTION_LIST_VALUE, yytext, NULL, 0, working_token);
			yytext = ++data_pointer;
		}
		else {
			char *data_pointer = yytext;
			while (*data_pointer != '\n') {
				++data_pointer;
			}
			*data_pointer = '\0';
			add_child(DESCRIPTION_LIST_KEY, yytext, NULL, 0, working_token);
			yytext = ++data_pointer;
		}
	}
}

<LEX_ROOT>^\`\`[A-Za-z0-9]*$ { // Start CODE_BLOCK
	yytext += 2;
	add_child(START_CODE_BLOCK, yytext, NULL, 0, current_token);
	BEGIN(IN_CODE_BLOCK);
}

<IN_CODE_BLOCK>.* {
	add_child(RAW_DATA, yytext, NULL, 0, current_token);
}

<IN_CODE_BLOCK>\n {}

<IN_CODE_BLOCK>^\`\`$ { // End CODE_BLOCK
	add_child(END_CODE_BLOCK, yytext, NULL, 0, current_token);
	BEGIN(LEX_ROOT);
}

 { // TOP_TITLED_TABLE
}

 { // LEFT_TITLED_TABLE
}

 { // TWO_WAY_TABLE
}

<LEX_ROOT>^\[\|$ { // LEFT_COLUMN
	if (in_left_column || in_right_column) {
		add_child(PARAGRAPH, yytext, NULL, 0, current_token);
	} else {
		add_child(LEFT_COLUMN, NULL, NULL, 0, current_token);
	}
	in_left_column = 1;
}

<LEX_ROOT>^\|\|$ { // DIVIDER_COLUMN
	if (!in_left_column || in_right_column) {
		add_child(PARAGRAPH, yytext, NULL, 0, current_token);
	} else {
		add_child(DIVIDER_COLUMN, NULL, NULL, 0, current_token);
	}
	in_left_column = 0;
	in_right_column = 1;
}

<LEX_ROOT>^\|\]$ { // RIGHT_COLUMN
	if (in_left_column || !in_right_column) {
		add_child(PARAGRAPH, yytext, NULL, 0, current_token);
	} else {
		add_child(RIGHT_COLUMN, NULL, NULL, 0, current_token);
	}
	in_right_column = 0;
}

 { // INFOBOX_TITLE
}

 { // INFOBOX_CONTENT
}

 { // FOOTNOTE_NOTE
}

 { // ENDNOTE_NOTE
}

<LEX_ROOT>. { // Nothing else matched; go to PARAGRAPH
	yyless(0);
	LAST_CONDITION = YY_START;
	BEGIN(IN_PARAGRAPH);
}

<IN_PARAGRAPH>[ \t]+.+ { // INDENTED_PARAGRAPH
	while (*yytext == ' ' || *yytext == '\t') {
		++yytext;
	}
	add_child(INDENTED_PARAGRAPH, yytext, NULL, 0, current_token);
	BEGIN(LAST_CONDITION);
}

<IN_PARAGRAPH>.+ { // PARAGRAPH
	add_child(PARAGRAPH, yytext, NULL, 0, current_token);
	BEGIN(LAST_CONDITION);
}

<LEX_ROOT>\n {
}

%%

int lex_root(Token *token) {
	yyin = fmemopen(token->data, strlen(token->data), "r");
	current_token = token;
	BEGIN(LEX_ROOT);
	yylex();
	free(token->data);
	token->data = NULL;
	mark_raw(token);
	return 0;
}

int lex_heading(Token *token) {
	BEGIN(LEX_HEADING);
	yyin = fmemopen(token->data, strlen(token->data), "r");
	current_token = token;
	return yylex();
}