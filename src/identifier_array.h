#ifndef IDENTIFIER_ARRAY_H
#define IDENTIFIER_ARRAY_H

#include <stdlib.h>

typedef struct IdentifierArray {
	char** identifiers;
	size_t count;
} IdentifierArray;

IdentifierArray* create_identifier_array();

void add_identifier(IdentifierArray* identifier_array, const char* id);

void free_identifier_array(IdentifierArray* identifier_array);

#endif