#ifndef GENERIC_LEXER_H
#define GENERIC_LEXER_H

#include "docmark_token.h"

/**
 * @brief Recursively lexes a token and its children
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_recursive(Token *token);

#endif