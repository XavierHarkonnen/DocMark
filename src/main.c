#include "docmark_token.h"
#include "docmark_debug.h"
#include "generic_lexer.h"
#include "generic_parser.h"
#include "identifier_array.h"

#include <stdio.h>

const char *output_file_path = "test/out.html";

int main(int argc, char *argv[]) {
	if (argc != 2) {
		fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
		return 1;
	}

	FILE *input_file = fopen(argv[1], "r");
	if (!input_file) {
		fprintf(stderr, "Error opening input file");
		return 1;
	}

	FILE *output_file = fopen(output_file_path, "w");
	if (!input_file) {
		fprintf(stderr, "Error opening output file");
		return 1;
	}

	fseek(input_file, 0, SEEK_END);
	long size = ftell(input_file);
	fseek(input_file, 0, SEEK_SET);

	char *input_file_content = (char *)malloc(size + 1);
	if (input_file_content == NULL) {
		fprintf(stderr, "Memory allocation error");
		fclose(input_file);
		return 1;
	}

	fread(input_file_content, 1, size, input_file);
	input_file_content[size] = '\0';
	fclose(input_file);

	Token *root = root_token(input_file_content);
	IdentifierArray *heading_identifier_array = create_identifier_array();
	IdentifierArray *other_identifier_array = create_identifier_array();

	for (size_t i = 0; i < root->num_children; ++i) {
		print_token("", root->children[i]);
	}

	generic_lex(root);

	for (size_t i = 0; i < root->num_children; ++i) {
		print_token("", root->children[i]);
		mark_raw(root->children[i]);
		fprintf(stdout, "HTML: %s\n", parse_token(root->children[i], heading_identifier_array, other_identifier_array));
	}

	print_token("", root);

	return 0;
}
