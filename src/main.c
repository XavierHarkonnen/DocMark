#include "docmark_token.h"
#include "docmark_debug.h"

int main() {
	Token *root = malloc(sizeof(Token));

	if (root == NULL) {
		return 1;
	}

	root->type = ROOT;
	root->rank = 0;
	root->parent = NULL;
	root->children = NULL;
	root->num_children = 0;

	add_child(HEADING, "Hello, World!", NULL, 0, root);
	add_child(PARAGRAPH, "This is a sample document.", NULL, 0, root);
	add_child(BOLD, "Bold Text", NULL, 0, root->children[0]);
	add_child(BOLD, "Base", NULL, 0, root->children[0]->children[0]);

	print_token("Root", root);
	print_token("Heading", root->children[0]);
	print_token("Bold2", root->children[0]->children[0]);

	mark_raw(root->children[0]->children[0]);

	print_token("Root", root);
	print_token("Heading", root->children[0]);
	print_token("Bold2", root->children[0]->children[0]);

	delete_token(&root);

	return 0;
}
