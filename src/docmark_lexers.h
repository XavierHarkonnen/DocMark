#ifndef DOCMARK_LEXERS_H
#define DOCMARK_LEXERS_H

#include "docmark_token.h"

/**
 * @brief Lex the root token
 * 
 * 
 * 
 * @param token The token to which children will be added
 * @return int (0 on success, -1 on failure)
 */
int lex_root(Token *token);

int lex_heading(Token *token);

#endif