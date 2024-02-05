#include "docmark_token.h"
#include "docmark_debug.h"
#include "generic_lexer.h"

#include <stdio.h>

int main(int argc, char *argv[]) {
	if (argc != 2) {
		fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
		return 1;
	}

	FILE *file = fopen(argv[1], "r");
	if (!file) {
		fprintf(stderr, "Error opening file");
		return 1;
	}

	fseek(file, 0, SEEK_END);
	long size = ftell(file);
	fseek(file, 0, SEEK_SET);

	char *file_content = (char *)malloc(size + 1);
	if (file_content == NULL) {
		fprintf(stderr, "Memory allocation error");
		fclose(file);
		return 1;
	}

	fread(file_content, 1, size, file);
	file_content[size] = '\0';
	fclose(file);

	Token *root = root_token(file_content);

	for (size_t i = 0; i < root->num_children; ++i) {
		print_token("", root->children[i]);
	}

	generic_lex(root);

	for (size_t i = 0; i < root->num_children; ++i) {
		print_token("", root->children[i]);
	}

	delete_token(&root);

	return 0;
}
