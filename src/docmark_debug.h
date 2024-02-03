#ifndef DOCMARK_DEBUG_H
#define DOCMARK_DEBUG_H

#include "docmark_token.h"

void delete_token(Token **token);

void print_token(const char *token_name, Token *token);

#endif