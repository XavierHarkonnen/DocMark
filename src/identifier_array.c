#include "identifier_array.h"

#include <ctype.h>
#include <stdio.h>
#include <string.h>

IdentifierArray* create_identifier_array() {
	IdentifierArray* identifier_array = (IdentifierArray*)malloc(sizeof(IdentifierArray));
	if (identifier_array == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}
	identifier_array->identifiers = NULL;
	identifier_array->count = 0;
	return identifier_array;
}

void add_identifier(IdentifierArray* identifier_array, const char* id) {
	identifier_array->identifiers = (char**)realloc(identifier_array->identifiers, (identifier_array->count + 1) * sizeof(char*));
	if (identifier_array->identifiers == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}

	identifier_array->identifiers[identifier_array->count] = strdup(id);
	if (identifier_array->identifiers[identifier_array->count] == NULL) {
		fprintf(stderr, "ERROR: Memory allocation failed\n");
		exit(1);
	}
	identifier_array->count++;
}

void free_identifier_array(IdentifierArray* identifier_array) {
	if (identifier_array == NULL)
		return;

	for (size_t i = 0; i < identifier_array->count; i++) {
		free(identifier_array->identifiers[i]);
	}
	free(identifier_array->identifiers);
	free(identifier_array);
}
