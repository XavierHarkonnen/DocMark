#include "generic_parser.h"

#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "docmark_debug.h"

/* LOCAL PARSING VARIABLES */
static int in_blockquote;
static unsigned int blockquote_rank = 0;

static int in_unordered_list;
static unsigned int unordered_list_rank = 0;

static int in_ordered_list;
static unsigned int ordered_list_rank = 0;

static inline char* format_data_buffer(const char* format, ...) {
	va_list args;
	va_list temp_args;
	va_start(args, format);
	va_copy(temp_args, args);

	int size = vsnprintf(NULL, 0, format, temp_args);
	if (size < 0) {
		fprintf(stderr, "ERROR: Could not determine formatted string size\n");
		exit(1);
	}

	va_end(temp_args);

	char* buffer = (char*)malloc((size + 1) * sizeof(char));
	if (buffer == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}

	vsnprintf(buffer, size + 1, format, args);
	va_end(args);
	return buffer;
}

static inline char* generate_identifier_base(const char* data) {
	char* identifier = (char*)malloc((strlen(data) + 1) * sizeof(char));
	if (identifier == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}

	int i = 0, j = 0;
	int in_tag = 0;
	unsigned char buffer_counter = 0;
	char buffer[256];
	buffer[buffer_counter] = '\0';
	while (data[i] != '\0') {
		if (data[i] == '<' && data[(i > 0 ? i : 0)] != '\\') {
			in_tag = 1; // Set flag when entering a tag
		}
		else if (data[i] == '>') {
			in_tag = 0; // Clear flag when exiting a tag
			buffer_counter = 0;
			buffer[buffer_counter] = '\0';
		}
		char c = tolower(data[i]);
		if (isalnum(c)) {
			if (in_tag) { 
				buffer[buffer_counter++] = c;
				buffer[buffer_counter] = '\0';
			} else {
				identifier[j++] = c;
			}
		}
		else if (c == ' ') {
			if (in_tag) { 
				buffer[buffer_counter++] = '-';
				buffer[buffer_counter] = '\0';
			} else {
				identifier[j++] = '-';
			}
		}
		i++;
	}
	while (buffer[buffer_counter] != '\0') {
		identifier[j++] = buffer[buffer_counter++];
	}
	identifier[j] = '\0';
	return identifier;
}

static inline char* make_unique_identifier(char* identifier_base, IdentifierArray* heading_identifier_array, IdentifierArray* other_identifier_array, int is_header) {
	int unique = 1;
	for (int i = 0; i < heading_identifier_array->count; ++i) {
		if (!strcmp(identifier_base, heading_identifier_array->identifiers[i])) {
			unique = 0;
			break;
		}
	}
	for (int i = 0; i < other_identifier_array->count; ++i) {
		if (!strcmp(identifier_base, other_identifier_array->identifiers[i])) {
			unique = 0;
			break;
		}
	}

	if (unique) {
		if (is_header) {
			add_identifier(heading_identifier_array, identifier_base);
		} else {
			add_identifier(other_identifier_array, identifier_base);
		}
		return identifier_base;
	}
	
	int suffix_num = 1;
	char suffix[5];
	char* identifier = (char *) malloc((strlen(identifier_base) + sizeof(suffix) + 1) * sizeof(char));
	if (identifier == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}

	while (1) {
		identifier[0] = '\0';
		int suffix_size = snprintf(suffix, sizeof(suffix), "-%d", suffix_num);
		if (suffix_size >= sizeof(suffix)) {
			printf("ERROR: Identifier suffix size exceeded buffer\n");
			exit(1);
		}

		strcat(identifier, identifier_base);
		strcat(identifier, suffix);
		unique = 1;

		for (int i = 0; i < heading_identifier_array->count; ++i) {
			if (!strcmp(identifier, heading_identifier_array->identifiers[i])) {
				unique = 0;
				break;
			}
		}
		for (int i = 0; i < other_identifier_array->count; ++i) {
			if (!strcmp(identifier, other_identifier_array->identifiers[i])) {
				unique = 0;
				break;
			}
		}

		if (unique) {
			if (is_header) {
				add_identifier(heading_identifier_array, identifier);
			} else {
				add_identifier(other_identifier_array, identifier);
			}
			free(identifier_base);
			return identifier;
		}
		++suffix_num;
	}
}

char *parse_token(Token *token, IdentifierArray* heading_identifier_array, IdentifierArray* other_identifier_array) {
	if (token->type > 0) {
		fprintf(stderr, "ERROR: Cannot parse token; token is not raw\n");
		print_token("", token);
		exit(1);
	} else if (token->num_children != 0 || token->children != NULL) {
		fprintf(stderr, "ERROR: Cannot parse token; token has %i children!\n", token->num_children);
		print_token("PARENT", token);
		for (int i = 0; i < token->num_children; i++) {
			print_token("CHILD", token->children[i]);
		}
		exit(1);
	}

	switch (token->type) {
		case HORIZONTAL_RULE:
			return "<hr>\n";
		case FOOTNOTE_REFERENCE: {
			char* header_id;
			if (heading_identifier_array->count <= 0) {
				header_id = "base";
			} else {
				header_id = heading_identifier_array->identifiers[heading_identifier_array->count - 1];
			}

			char *footnote_identifier_base = format_data_buffer("%s-footnote-%s", header_id, token->attribute);
			char *footnote_identifier = make_unique_identifier(footnote_identifier_base, heading_identifier_array, other_identifier_array, 0);
			free(footnote_identifier_base);

			return format_data_buffer(
				"<sup><a href=\"#%s\">%s</a></sup>\n",
				footnote_identifier,
				token->attribute
			);
		}
		case ENDNOTE_REFERENCE: {
			char *endnote_identifier_base = format_data_buffer("endnote-%s", token->attribute);
			char *endnote_identifier = make_unique_identifier(endnote_identifier_base, heading_identifier_array, other_identifier_array, 0);
			free(endnote_identifier_base);

			return format_data_buffer(
				"<sup><a href=\"#%s\">[%s]</a></sup>\n",
				endnote_identifier,
				token->attribute
			);
		}
		case START_CODE_BLOCK:
			return "<pre>\n<code>\n";
		case END_CODE_BLOCK:
			return "</code>\n</pre>\n";
		case LEFT_COLUMN:
			return "<div class=\"column-box\">\n<div class=\"column\">\n";
		case DIVIDER_COLUMN:
			return "</div>\n<div class=\"column\">\n";
		case RIGHT_COLUMN:
			return "</div>\n</div>\n";
		case RAW_DATA: {
			int length = strlen(token->data);
			char *data = (char *)malloc(length + 1);
			if (data == NULL) {
				fprintf(stderr, "ERROR: Memory allocation failed\n");
				exit(1);
			}
			strncpy(data, token->data, length);
			data[length] = '\0';
			return data;
		}
		case -ROOT:
			printf("HIT ROOT\n");
			// end tree traversal
			return strdup(token->data);
		case -HEADING:
			if (!token->attribute) {
				token->attribute = generate_identifier_base(token->data);
			}

			token->attribute = make_unique_identifier(token->attribute, heading_identifier_array, other_identifier_array, 1);

			return format_data_buffer(
				"<h%i type=\"%s\">%s</h%i>\n",
				token->rank,
				token->attribute,
				token->data,
				token->rank
			);
		case -ITALIC:
			return format_data_buffer(
				"<i>%s</i>",
				token->data
			);
		case -BOLD:
			return format_data_buffer(
				"<b>%s</b>",
				token->data
			);
		case -UNDERSCORE:
			return format_data_buffer(
				"<u>%s</u>",
				token->data
			);
		case -STRIKETHROUGH:
			return format_data_buffer(
				"<s>%s</s>",
				token->data
			);
		case -HIGHLIGHT:
			return format_data_buffer(
				"<mark>%s</mark>",
				token->data
			);
		case -SUPERSCRIPT:
			return format_data_buffer(
				"<sup>%s</sup>",
				token->data
			);
		case -SUBSCRIPT:
			return format_data_buffer(
				"<sub>%s</sub>",
				token->data
			);
		case -BLOCKQUOTE: {
			return format_data_buffer(
				"<blockquote>\n%s\n</blockquote>\n",
				token->data
			);
		}
		case -ORDERED_LIST:
			return format_data_buffer(
				"<ol>\n%s</ol>\n",
				token->data
			);
		case -UNORDERED_LIST:
			return format_data_buffer(
				"<ul>\n%s</ul>\n",
				token->data
			);
			case -DESCRIPTION_LIST:
			return format_data_buffer(
				"<dl>\n%s</dl>\n",
				token->data
			);
		case -LIST_ELEMENT:
			return format_data_buffer(
				"<li>\n%s</li>\n",
				token->data
			);
		case -DESCRIPTION_LIST_KEY:
			return format_data_buffer(
				"<dt>%s</dt>\n",
				token->data
			);
		case -DESCRIPTION_LIST_VALUE:
			return format_data_buffer(
				"<dd>%s</dd>\n",
				token->data
			);
		case -INLINE_CODE:
			return format_data_buffer(
				"<code>%s</code>",
				token->data
			);
		case -LINK:
			return format_data_buffer(
				"<a href=\"%s\" title=\"%s\">%s</a>\n",
				strtok(token->attribute, "\0"),
				strtok(NULL, "\0"),
				token->data
			);
		case -IMAGE: {
			const char* source = strtok(token->attribute, "\0");
			const char* title = strtok(NULL, "\0");
			return format_data_buffer(
				"<img src=\"%s\" alt=\"%s\" title=\"%s\">\n",
				source,
				token->data,
				title
			);
		}
		case -AUDIO: {
			const char* source = strtok(token->attribute, "\0");
			const char* title = strtok(NULL, "\0");
			const char* type = strtok(NULL, "\0");
			return format_data_buffer(
				"<audio controls title=\"%s\">\n<source src=\"%s\" type=\"audio/%s\">\n%s\n</audio>\n",
				title,
				source,
				type,
				token->data
			);
		}
		case -VIDEO: {
			const char* source = strtok(token->attribute, "\0");
			const char* title = strtok(NULL, "\0");
			const char* type = strtok(NULL, "\0");
			return format_data_buffer(
				"<video title=\"%s\">\n<source src=\"%s\" type=\"video/%s\">\n%s\n</video>\n",
				title,
				source,
				type,
				token->data
			);
		}
		case -TOP_TITLED_TABLE:
		case -LEFT_TITLED_TABLE:
		case -TWO_WAY_TABLE:
			fprintf(stdout, "<!-- UNKNOWN TOKEN -->\n");
			return NULL;
		case -INFOBOX_TITLE:
			/* if (!token->attribute) {
				token->attribute = generate_identifier_base(token->data);
			}

			token->attribute = make_unique_identifier(token->attribute, identifier_array);

			return format_data_buffer(
				"<div class=\"infobox-container\">\n<div class=\"infobox\">\n<div class=\"%s\">\n<h2>%s</h2>\n</div>\n",
				token->attribute,
				token->data
			); */
		case -INFOBOX_CONTENT:
		case -FOOTNOTE_NOTE:
		case -ENDNOTE_NOTE:
			fprintf(stdout, "<!-- UNKNOWN TOKEN -->\n");
			return NULL;
		case -PARAGRAPH:
			return format_data_buffer(
				"<p>%s</p>\n",
				token->data
			);
		case -INDENTED_PARAGRAPH:
			return format_data_buffer(
				"<p class=\"indented\">%s</p>\n",
				token->data
			);
		case -VARIABLE_DEFINITION:
		case -VARIABLE_RETURN:
		case -FUNCTION_DEFINITION:
		case -FUNCTION_RETURN:
		case -BUILT_IN_VARIABLE_DEFINITION:
		case -BUILT_IN_VARIABLE_RETURN:
		case -BUILT_IN_FUNCTION_RETURN:
		default:
			fprintf(stdout, "<!-- UNKNOWN TOKEN -->\n");
			return NULL;
	}
	
	delete_token(&token);
}

static char *parse_recursive(Token *token, IdentifierArray* heading_identifier_array, IdentifierArray* other_identifier_array) {
	if (token->data == NULL) {
		token->data = malloc(1);
		if (token->data == NULL) {
			printf("ERROR: Memory allocation failed\n");
			exit(1);
		}
		token->data[0] = '\0';
	}
	
	for (size_t i = 0; i < token->num_children; ++i) {
		char *data = parse_recursive(token->children[i], heading_identifier_array, other_identifier_array);
		token->data = realloc(token->data, strlen(token->data) + strlen(data) + 1);

		if (token->data == NULL) {
			fprintf(stderr, "ERROR: Memory allocation failed\n");
			exit(1);
		}

		strcat(token->data, data);
	}

	print_token("", token);

	delete_children(&token);

	mark_raw(token);
	return parse_token(token, heading_identifier_array, other_identifier_array);
}

int parse_tree(Token *root_token, IdentifierArray* heading_identifier_array, IdentifierArray* other_identifier_array, FILE *output_file) {
	parse_recursive(root_token, heading_identifier_array, other_identifier_array);
	fwrite(root_token->data, sizeof(char), strlen(root_token->data), output_file);
	free(root_token->data);
	free(root_token);
	return 0;
}