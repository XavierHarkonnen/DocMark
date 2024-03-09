#include "docmark_token.h"

#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_CHILDREN 10000

Token *root_token(const char *data) {
	Token *root = malloc(sizeof(Token));

	if (root == NULL) {
		fprintf(stderr, "Error allocating memory for root token!");
		exit(EXIT_FAILURE);
  }

	root->type = ROOT;
	root->data = strdup(data);;
	root->attribute = NULL;
	root->rank = 0;
	root->parent = NULL;
	root->children = NULL;
	root->num_children = 0;

	return root;
}

void mark_raw(Token *token) {
	if (token->type > 0) {
		token->type = -token->type;
	}
}

int is_raw(Token *token) {
	return (token->type <= 0);
}

void add_child(
	const TokenType type,
	const char* data,
	const char* attribute,
	const unsigned int rank,
	Token *parent
) {
	if (parent->num_children == 0) {
		parent->children = malloc(sizeof(Token*));
	} else if (parent->num_children >= MAX_CHILDREN) {
		fprintf(stderr, "Error: Number of child tokens exceeded maximum (%d)!", MAX_CHILDREN);
		exit(1);
	} else {
		parent->children = realloc(parent->children, (parent->num_children + 1) * sizeof(Token*));
	}

	Token* child = malloc(sizeof(Token));

	child->type = type;
	child->rank = rank;
	child->parent = parent;
	child->children = NULL;
	child->num_children = 0;

	if (data) {
		child->data = strdup(data);
	} else {
		child->data = NULL;
	}

	if (attribute) {
		child->attribute = strdup(attribute);
	} else {
		child->attribute = NULL;
	}

	parent->children[parent->num_children] = child;
	++parent->num_children;
}

void delete_children(Token **token) {
	if ((*token)->children) {
		for (unsigned int i = 0; i < (*token)->num_children; ++i) {
			delete_token(&((*token)->children[i]));
		}
		free((*token)->children);
		(*token)->children = NULL;
	}
	(*token)->num_children = 0;
}

void delete_token(Token **token) {
	if (!token || !(*token)) {
		return;
	}

	if ((*token)->data) {
		free((*token)->data);
	}

	if ((*token)->attribute) {
		free((*token)->attribute);
	}

	delete_children(token);

	free(*token);
	*token = NULL;
}