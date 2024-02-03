#include "docmark_token.h"

#include <malloc.h>
#include <stdio.h>
#include <string.h>

#define MAX_CHILDREN 10000

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

	for (unsigned int i = 0; i < (*token)->num_children; ++i) {
		delete_token(&((*token)->children[i]));
	}

	free((*token)->children);
	free(*token);
	*token = NULL;
}