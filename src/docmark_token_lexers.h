#ifndef DOCMARK_LEXERS_H
#define DOCMARK_LEXERS_H

#include "docmark_token.h"

/**
 * @brief Lexes a root token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_root(Token *token);

/**
 * @brief Lexes a heading token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_heading(Token *token);

/**
 * @brief Lexes an italic token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_italic(Token *token);

/**
 * @brief Lexes a bold token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_bold(Token *token);

/**
 * @brief Lexes an underscore token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_underscore(Token *token);

/**
 * @brief Lexes a strikethrough token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_strikethrough(Token *token);

/**
 * @brief Lexes a highlight token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_highlight(Token *token);

/**
 * @brief Lexes a superscript token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_superscript(Token *token);

/**
 * @brief Lexes a subscript token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_subscript(Token *token);

/**
 * @brief Lexes a blockquote token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_blockquote(Token *token);

/**
 * @brief Lexes an ordered list token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_ordered_list(Token *token);

/**
 * @brief Lexes an unordered list token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_unordered_list(Token *token);

/**
 * @brief Lexes a description list token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_description_list(Token *token);

/**
 * @brief Lexes a list element token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_list_element(Token *token);

/**
 * @brief Lexes a description list key token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_description_list_key(Token *token);

/**
 * @brief Lexes a description list value token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_description_list_value(Token *token);

/**
 * @brief Lexes a link token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_link(Token *token);

/**
 * @brief Lexes an image token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_image(Token *token);

/**
 * @brief Lexes an audio token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_audio(Token *token);

/**
 * @brief Lexes a video token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_video(Token *token);

/**
 * @brief Lexes a top titled table token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_top_titled_table(Token *token);

/**
 * @brief Lexes a left titled table token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_left_titled_table(Token *token);

/**
 * @brief Lexes a two way table token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_two_way_table(Token *token);

/**
 * @brief Lexes an endnote note title token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_footnote_note(Token *token);

/**
 * @brief Lexes a footnote note title token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_endnote_note(Token *token);

/**
 * @brief Lexes a paragraph token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_paragraph(Token *token);

/**
 * @brief Lexes an indented paragraph token
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_indented_paragraph(Token *token);

/**
 * @brief Placeholder lexing function (NOT TO BE USED IN FINAL VERSION)
 * 
 * @param token The token to be lexed
 * @return int (0 on success, -1 on failure)
 */
int lex_(Token *token);

#endif