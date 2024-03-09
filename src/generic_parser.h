#ifndef GENERIC_PARSER_H
#define GENERIC_PARSER_H

#include "docmark_token.h"
#include "identifier_array.h"
#include <stdio.h>

int parse_tree(Token *root_token, IdentifierArray* heading_identifier_array, IdentifierArray* other_identifier_array, FILE *output_file);

#endif