#include "generic_parser.h"

#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
	while (data[i] != '\0') {
		char c = tolower(data[i]);
		if (isalnum(c)) {
			identifier[j++] = c;
		} else if (c == ' ') {
			identifier[j++] = '-';
		}
		i++;
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
		return strdup(identifier_base);
	}
	
	int suffix_num = 1;
	char* identifier;
	while (1) {
		identifier = strdup(identifier_base);
		char suffix[5];
		int suffix_size = snprintf(suffix, sizeof(suffix), "-%d", suffix_num);
		if (suffix_size >= sizeof(suffix)) {
			printf("ERROR: Identifier suffix size exceeded buffer\n");
			exit(1);
		}

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
			return strdup(identifier);
		}
		++suffix_num;
	}
}

int parse_tree(Token *root_token, FILE *output_file) {

}

const char *parse_token(Token *token, IdentifierArray* heading_identifier_array, IdentifierArray* other_identifier_array) {
	if (token->type > 0) {
		fprintf(stderr, "ERROR: Cannot parse token; token is not raw\n");
		exit(1);
	} else if (token->num_children != 0 || token->children != NULL) {
		fprintf(stderr, "ERROR: Cannot parse token; token has children!\n");
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
		case RAW_DATA:
			return strdup(token->data);
		case -ROOT:
			fprintf(stdout, "HIT ROOT\n");
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
		case -BOLD:
			return format_data_buffer(
				"<em>%s</em>\n",
				token->data
			);
		case -UNDERSCORE:
			return format_data_buffer(
				"<u>%s</u>\n",
				token->data
			);
		case -STRIKETHROUGH:
			return format_data_buffer(
				"<s>%s</s>\n",
				token->data
			);
		case -HIGHLIGHT:
			return format_data_buffer(
				"<mark>%s</mark>\n",
				token->data
			);
		case -SUPERSCRIPT:
			return format_data_buffer(
				"<sup>%s</sup>\n",
				token->data
			);
		case -SUBSCRIPT:
			return format_data_buffer(
				"<sub>%s</sub>\n",
				token->data
			);
		case -BLOCKQUOTE: // INCOMPLETE: NESTING BLOCKQUOTES
			printf("%i\n", token->rank);
			return format_data_buffer(
				"<blockquote>%s</blockquote>\n",
				token->data
			);
		case -ORDERED_LIST_ELEMENT: // INCOMPLETE: START AND END OF LIST, LIST TYPE, LIST RANK
			return format_data_buffer(
				"<li>%s</li>\n",
				token->data
			);
		case -UNORDERED_LIST_ELEMENT: // INCOMPLETE: START AND END OF LIST, LIST TYPE, LIST RANK
			return format_data_buffer(
				"<li>%s</li>\n",
				token->data
			);
		case -DESCRIPTION_LIST_KEY: // INCOMPLETE: START AND END OF LIST, LIST TYPE, LIST RANK
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
				"<code>%s</code>\n",
				token->data
			);
		case -CODE_BLOCK:
			return format_data_buffer(
				"<pre>\n<code>\n%s\n</code>\n</pre>\n",
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
		case -LEFT_COLUMN:
			return format_data_buffer(
				"<div class=\"column-box\">\n<div class=\"column\">\n%s\n</div>\n",
				token->data
			);
		case -RIGHT_COLUMN:
			return format_data_buffer(
				"<div class=\"column\">\n%s\n</div>\n</div>",
				token->data
			);
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