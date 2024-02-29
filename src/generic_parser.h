#ifndef GENERIC_PARSER_H
#define GENERIC_PARSER_H

#include "docmark_token.h"
#include "identifier_array.h"
#include <stdio.h>

int parse_tree(Token *root_token, FILE *output_file);

const char *parse_token(Token *token, IdentifierArray* identifier_array, IdentifierArray* other_identifier_array);

#endif