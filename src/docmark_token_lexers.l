%top{
	#include "docmark_token_lexers.h"

	#include "docmark_debug.h"
	#include "docmark_definitions.h"

	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>

	// FLAGS
	unsigned int heading_rank = 0;
	int in_left_column = 0;
	int in_right_column = 0;

	Token *current_token;
	int LAST_CONDITION = 0;
	int buffer_counter = 0;
	size_t buffer_size = 0;
	char *buffer = NULL;

	static void flush_buffer_raw() {
		if (buffer) {
			add_child(RAW_DATA, buffer, NULL, 0, current_token);
			buffer_counter = 0;
			buffer[buffer_counter] = '\0';
		}
	}
	
	static void flush_buffer_paragraph() {
		char* buffer_pointer = buffer;
		if (buffer) {
			if (strlen(buffer_pointer) > 1) {
				if (*buffer_pointer == ' ' || *buffer_pointer == '\t') {
					while(*buffer_pointer == ' ' || *buffer_pointer == '\t') {
						++buffer_pointer;
					}
					add_child(INDENTED_PARAGRAPH, buffer_pointer, NULL, 0, current_token);
				}
				else {
					add_child(PARAGRAPH, buffer, NULL, 0, current_token);
				}
			}
			buffer_counter = 0;
			buffer[buffer_counter] = '\0';
		}
	}
}

%option noyywrap
%option nodefault

%x LEX_ROOT
%x LEX_HEADING
%x LEX_ITALIC
%x LEX_BOLD
%x LEX_UNDERSCORE
%x LEX_STRIKETHROUGH
%x LEX_HIGHLIGHT
%x LEX_SUPERSCRIPT
%x LEX_SUBSCRIPT
%x LEX_BLOCKQUOTE
%x LEX_LIST_ELEMENT
%x LEX_DESCRIPTION_LIST_KEY
%x LEX_DESCRIPTION_LIST_VALUE
%x LEX_LINK
%x LEX_IMAGE
%x LEX_AUDIO
%x LEX_VIDEO
%x LEX_TOP_TITLED_TABLE
%x LEX_LEFT_TITLED_TABLE
%x LEX_TWO_WAY_TABLE
%x LEX_INFOBOX_TITLE
%x LEX_INFOBOX_CONTENT
%x LEX_FOOTNOTE_NOTE
%x LEX_ENDNOTE_NOTE
%x LEX_PARAGRAPH
%x LEX_INDENTED_PARAGRAPH

%x IN_RAW
%x IN_HEADING
%x IN_ITALIC
%x IN_BLOCKQUOTE
%x IN_CODE_BLOCK
%x IN_PARAGRAPH

%%
<LEX_HEADING,LEX_PARAGRAPH>. { // RAW_DATA
	if (buffer_counter + 1 >= buffer_size) { // Check if buffer needs to be resized
		buffer_size = (buffer_size == 0) ? 1 : buffer_size * 2; // Double the buffer size
		buffer = realloc(buffer, buffer_size);
	}
	if (buffer == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}

	buffer[buffer_counter++] = *yytext;
	buffer[buffer_counter] = '\0';
}

<LEX_HEADING,LEX_PARAGRAPH><<EOF>> { // RAW_DATA
	flush_buffer_raw();
	return 0;
}

<LEX_HEADING,LEX_PARAGRAPH>\n { // RAW_DATA
	flush_buffer_raw();
}

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

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\*[^\* \t\r\n\\]\* { // Single character ITALIC
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(ITALIC, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\*[^\* \t\r\n].*[^\* \t\r\n\\]\* { // ITALIC
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '*') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(ITALIC, yytext + 1, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\+[^\+ \t\r\n\\]\+ { // Single character BOLD
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(BOLD, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\+[^\+ \t\r\n].*[^\+ \t\r\n\\]\+ { // BOLD
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '+') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(BOLD, yytext + 1, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\~[^\~ \t\r\n\\]\~ { // Single character UNDERSCORE
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(UNDERSCORE, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\~[^\~ \t\r\n].*[^\~ \t\r\n\\]\~ { // UNDERSCORE
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '~') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(UNDERSCORE, yytext + 1, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\-[^\- \t\r\n\\]\- { // Single character STRIKETHROUGH
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(STRIKETHROUGH, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\-[^\- \t\r\n].*[^\- \t\r\n\\]\- { // STRIKETHROUGH
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '-') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(STRIKETHROUGH, yytext + 1, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\=[^\= \t\r\n\\]\= { // Single character HIGHLIGHT
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(HIGHLIGHT, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\=[^\= \t\r\n].*[^\= \t\r\n\\]\= { // HIGHLIGHT
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '=') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(HIGHLIGHT, yytext + 1, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\^[^\^ \t\r\n\\]\^ { // Single character SUPERSCRIPT
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(SUPERSCRIPT, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\^[^\^ \t\r\n].*[^\^ \t\r\n\\]\^ { // SUPERSCRIPT
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '^') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(SUPERSCRIPT, yytext + 1, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\_[^\_ \t\r\n\\]\_ { // Single character SUBSCRIPT
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(SUBSCRIPT, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\_[^\_ \t\r\n].*[^\_ \t\r\n\\]\_ { // SUBSCRIPT
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '_') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(SUBSCRIPT, yytext + 1, NULL, 0, current_token);
}

<LEX_ROOT,LEX_LIST_ELEMENT>^(\>+[ \t]+.*\n)+ { // BLOCKQUOTE
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

<LEX_ROOT,LEX_LIST_ELEMENT>^([0-9]+\.[ \t]+.*\n(([ ]{2,}|\t)+.*\n)*)+ { // ORDERED_LIST		/* WARNING: Must change `{2,}` to `{TAB_SIZE,}` MANUALLY! */
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

<LEX_ROOT,LEX_LIST_ELEMENT>^(-[ \t]+.*\n(([ ]{2,}|\t)+.*\n)*)+ { // UNORDERED_LIST		/* WARNING: Must change `{2,}` to `{TAB_SIZE,}` ! MANUALLY ! */
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

<LEX_ROOT,LEX_LIST_ELEMENT>^([^ \t\r\n\-:].*\n(:[ \t]+.*\n)+)+ { // DESCRIPTION_LIST
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

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\`[^\` \t\r\n\\]\` { // Single character INLINE_CODE
	flush_buffer_raw();
	yytext += 2;
	*yytext = '\0';
	--yytext;
	add_child(INLINE_CODE, yytext, NULL, 0, current_token);
}

<LEX_HEADING,LEX_PARAGRAPH,LEX_LIST_ELEMENT>\`[^\` \t\r\n].*[^\` \t\r\n\\]\` { // INLINE_CODE
	flush_buffer_raw();
	char *data_pointer = yytext + 1;
	while (*data_pointer != '`') {
		++data_pointer;
	}
	*data_pointer = '\0';
	yyless(data_pointer - yytext + 1);
	add_child(INLINE_CODE, yytext + 1, NULL, 0, current_token);
}


<LEX_ROOT>^\`\`[A-Za-z0-9]*$ { // Start CODE_BLOCK
	yytext += 2;
	add_child(START_CODE_BLOCK, yytext, NULL, 0, current_token);
	BEGIN(IN_CODE_BLOCK);
}

<IN_CODE_BLOCK>^\`\`$ { // End CODE_BLOCK
	add_child(END_CODE_BLOCK, NULL, NULL, 0, current_token);
	BEGIN(LEX_ROOT);
}

<IN_CODE_BLOCK>^.+$ {
	char *data = malloc(strlen(yytext) + 2);
	strcpy(data, yytext);
	strcat(data, "\n");
	add_child(RAW_DATA, data, NULL, 0, current_token);
	free(data);
}

<IN_CODE_BLOCK>\n\n {
	yyless(1);
	add_child(RAW_DATA, "\n", NULL, 0, current_token);
}

<IN_CODE_BLOCK>\n {}

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

<LEX_ROOT,LEX_LIST_ELEMENT>. { // PARAGRAPH
	if (buffer_counter + 1 >= buffer_size) { // Check if buffer needs to be resized
		buffer_size = (buffer_size == 0) ? 1 : buffer_size * 2; // Double the buffer size
		buffer = realloc(buffer, buffer_size);
	}
	if (buffer == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}

	buffer[buffer_counter++] = *yytext;
	buffer[buffer_counter] = '\0';
}

<LEX_ROOT,LEX_LIST_ELEMENT><<EOF>> { // PARAGRAPH
	flush_buffer_paragraph();
	return 0;
}

<LEX_ROOT,LEX_LIST_ELEMENT>\n { // PARAGRAPH
	flush_buffer_paragraph();
}


<*>. {
	printf("UNHANDLED: %c\n", *yytext);
}

<*>\n {
	printf("UNHANDLED: %c", *yytext);
}
%%

static void lex(int mode, Token *token) {
	size_t input_size = strlen(token->data);
	char *input = (char *) malloc((input_size + 2) * sizeof(char));
	strcpy(input, token->data);
	input[input_size] = '\n';
	input[input_size + 1] = '\0';

	yyin = fmemopen(input, strlen(token->data), "r");
	current_token = token;

	BEGIN(mode);
	yylex();

	free(token->data);
	free(input);
	token->data = NULL;
	mark_raw(token);
}

int lex_root(Token *token) {
	lex(LEX_ROOT, token);
}

int lex_heading(Token *token) {
	lex(LEX_HEADING, token);
}

int lex_italic(Token *token) {
	lex(LEX_ITALIC, token);
}

int lex_bold(Token *token) {
	lex(LEX_BOLD, token);
}

int lex_underscore(Token *token) {
	lex(LEX_UNDERSCORE, token);
}

int lex_strikethrough(Token *token) {
	lex(LEX_STRIKETHROUGH, token);
}

int lex_highlight(Token *token) {
	lex(LEX_HIGHLIGHT, token);
}

int lex_superscript(Token *token) {
	lex(LEX_SUPERSCRIPT, token);
}

int lex_subscript(Token *token) {
	lex(LEX_SUBSCRIPT, token);
}

int lex_blockquote(Token *token) {
	lex(LEX_BLOCKQUOTE, token);
}

int lex_list_element(Token *token) {
	lex(LEX_LIST_ELEMENT, token);
}

int lex_description_list_key(Token *token) {
	lex(LEX_DESCRIPTION_LIST_KEY, token);
}

int lex_description_list_value(Token *token) {
	lex(LEX_DESCRIPTION_LIST_VALUE, token);
}

int lex_link(Token *token) {
	lex(LEX_LINK, token);
}

int lex_image(Token *token) {
	lex(LEX_IMAGE, token);
}

int lex_audio(Token *token) {
	lex(LEX_AUDIO, token);
}

int lex_video(Token *token) {
	lex(LEX_VIDEO, token);
}

int lex_top_titled_table(Token *token) {
	lex(LEX_TOP_TITLED_TABLE, token);
}

int lex_left_titled_table(Token *token) {
	lex(LEX_LEFT_TITLED_TABLE, token);
}

int lex_two_way_table(Token *token) {
	lex(LEX_TWO_WAY_TABLE, token);
}

int lex_infobox_title(Token *token) {
	lex(LEX_INFOBOX_TITLE, token);
}

int lex_infobox_content(Token *token) {
	lex(LEX_INFOBOX_CONTENT, token);
}

int lex_footnote_note(Token *token) {
	lex(LEX_FOOTNOTE_NOTE, token);
}

int lex_endnote_note(Token *token) {
	lex(LEX_ENDNOTE_NOTE, token);
}

int lex_paragraph(Token *token) {
	lex(LEX_PARAGRAPH, token);
}

int lex_indented_paragraph(Token *token) {
	lex(LEX_INDENTED_PARAGRAPH, token);
}

int lex_(Token *token) {
	// printf("WARNING: Token is not being lexed: uses `lex_()` as lexing function\n");
	// print_token("", token);
	return 0;
}