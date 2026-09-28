/*
 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 * Author : emptyhua@gmail.com
 * Create : 2011.9.26
 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 */

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <unistd.h>
#include <getopt.h>
#include "pinyin.h"
#include "utf8vector.h"
#include "linereader.h"

#ifdef DEBUG
#define MYLOG(x,ARGS...) fprintf (stderr, "[%s: %s (): line %d] "x"\n", __FILE__, __FUNCTION__, __LINE__, ##ARGS)
#else
#define MYLOG(x,ARGS...)
#endif //DEBUG

typedef enum {
    MatchModeFull,
    MatchModeFirstLetter
} MatchMode;

int match_line_with_keyword(const char *line, int line_length, const char *keyword, MatchMode mode, int ignore_case)
{
    MYLOG("line_length %d", line_length);

    wchar_t line_char,keyword_char; 
    int match_hanzi_count = 0;

    utf8vector line_vector = utf8vector_create(line, line_length);
    utf8vector keyword_vector = utf8vector_create(keyword, -1);

    int keyword_length = utf8vector_uni_count(keyword_vector);
    int keyword_index = 0;
    wchar_t *keyword_uni = malloc(sizeof(wchar_t) * keyword_length);

    while ((keyword_char = utf8vector_next_unichar(keyword_vector)) != '\0')
    {
        keyword_uni[keyword_index] = keyword_char;
        keyword_index ++;
    }

    int match_rt = 1;
    keyword_index = 0;

    while((line_char = utf8vector_next_unichar(line_vector)) != '\0'
            && keyword_index < keyword_length)
    {
        keyword_char = keyword_uni[keyword_index];
        if (pinyin_ishanzi(line_char))
        {
            if (pinyin_ishanzi(keyword_char))
            {
                if (line_char != keyword_char)
                {
                    match_rt = 0;
                    break;
                }
            }
            else if (pinyin_isabc(keyword_char))
            {
                keyword_char = pinyin_lowercase(keyword_char);
                const char **pinyins;
                int count = pinyin_get_pinyins_by_unicode(line_char, &pinyins);
                if (mode == MatchModeFirstLetter)
                {
                    int found = 0;
                    for (int i = 0; i < count; i++)
                    {
                        if (keyword_char == pinyins[i][0])
                        {
                            found = 1;
                            break;
                        }
                    }

                    if (found == 0)
                        match_rt = 0;
                    else
                        match_hanzi_count ++;
                }
                else if (mode == MatchModeFull)
                {
                    int found = 0;
                    for (int i = 0; i < count; i++)
                    {
                        int kindex_start = keyword_index;
                        const char *pinyin = pinyins[i];
                        int j = 0;
                        char pinyin_char;

                        while ((pinyin_char = pinyin[j]) != '\0' && kindex_start < keyword_length)
                        {
                            if (pinyin_char != pinyin_lowercase(keyword_uni[kindex_start]))
                            {
                                break;
                            }
                            j++;
                            kindex_start ++;
                        }
                       
                        int matched = (pinyin_char == '\0');
                        
                        if (matched)
                        {
                            found = 1;
                            keyword_index = kindex_start - 1;
                            break;
                        }
                    }

                    if (found == 0)
                        match_rt = 0;
                    else
                        match_hanzi_count ++;
                }

                free(pinyins);

                if (match_rt == 0)
                    break;
            }
            else
            {
                match_rt = 0;
                break;
            }
        }
        else
        {
            if (line_char != keyword_char &&
                !(ignore_case && pinyin_isabc(line_char) && pinyin_isabc(keyword_char) &&
                  pinyin_lowercase(line_char) == pinyin_lowercase(keyword_char)))
            {
                match_rt = 0;
                break;
            }
        }

        keyword_index ++;
    }
    
    //keyword.length > line.length
    if (match_rt == 1 && keyword_index < keyword_length)
        match_rt = 0;

    free(keyword_uni);
    utf8vector_free(line_vector);
    utf8vector_free(keyword_vector);
    if (match_rt == 0)
        return -1;
    else
        return match_hanzi_count;
}

// Compare the typed text with a candidate name or one of its prefixes.
static int one_edit(const char *typed, int typed_length, const char *candidate, int candidate_length)
{
    int i = 0, j = 0, edits = 0;
    while (i < typed_length && j < candidate_length)
    {
        if (pinyin_lowercase(typed[i]) == pinyin_lowercase(candidate[j]))
        {
            i++;
            j++;
            continue;
        }

        if (++edits > 1)
            return 0;

        if (typed_length == candidate_length && i + 1 < typed_length &&
            pinyin_lowercase(typed[i]) == pinyin_lowercase(candidate[j + 1]) &&
            pinyin_lowercase(typed[i + 1]) == pinyin_lowercase(candidate[j]))
        {
            i += 2;
            j += 2;
        }
        else if (typed_length > candidate_length)
            i++;
        else if (typed_length < candidate_length)
            j++;
        else
        {
            i++;
            j++;
        }
    }
    return edits + (typed_length - i) + (candidate_length - j) == 1;
}

static int typo_match(const char *line, int line_length, const char *keyword, int whole_name)
{
    int keyword_length = 0;
    while (keyword[keyword_length] != '\0')
    {
        if (!pinyin_isabc((unsigned char)keyword[keyword_length]))
            return 0;
        keyword_length++;
    }
    if (keyword_length < 3)
        return 0;

    for (int i = 0; i < line_length; i++)
        if ((unsigned char)line[i] >= 128)
            return 0;

    if (whole_name)
        return one_edit(keyword, keyword_length, line, line_length);

    for (int length = keyword_length - 1; length <= keyword_length + 1; length++)
        if (length <= line_length &&
            one_edit(keyword, keyword_length, line, length))
            return 1;
    return 0;
}

void show_usage(char* bin) {
    printf("USAGE: %s [options] keyword\n\n", bin);
    printf("options:\n");
    printf("\t-h --help              show this usage document\n");
    printf("\t-c --show_match_count  show match count\n");
    printf("\t-f --firstletter       first letter\n");
    printf("\t-F --firstletter-only  first letter only\n");
    printf("\t-i --ignore-case       ignore ASCII letter case\n");
    printf("\t-t --typo              suggest one-edit ASCII filename prefixes\n");
    printf("\t-T --typo-whole        suggest one-edit whole ASCII filenames\n");
}

void guide_to_help(char* bin) {
    printf("%s -h for help\n", bin);
}

int main(int argc, char **argv)
{
    int show_match_count = 0;
    int match_firstletter = 0;
    int match_firstletter_only = 0;
    int ignore_case = 0;
    int typo = 0;
    int typo_whole = 0;

    static struct option long_options[] =
    {
        {"help", no_argument, NULL, 'h'},
        {"show-match-count", no_argument, NULL, 'c'},
        {"firstletter", no_argument, NULL, 'f'},
        {"firstletter-only", no_argument, NULL, 'F'},
        {"ignore-case", no_argument, NULL, 'i'},
        {"typo", no_argument, NULL, 't'},
        {"typo-whole", no_argument, NULL, 'T'},
        {0,0,0,0}
    };

    while(1)
    {
        int option_index = 0;
        int c = getopt_long(argc, argv, "hcfFitT", long_options, &option_index);

        if (c == -1) break;

        switch(c)
        {
            case 'h':
                show_usage(argv[0]);
                return 0;
                break;
            case 'c':
                show_match_count = 1;
                break;
            case 'f':
                match_firstletter = 1;
                break;
            case 'F':
                match_firstletter_only = 1;
                break;
            case 'i':
                ignore_case = 1;
                break;
            case 't':
                typo = 1;
                break;
            case 'T':
                typo = 1;
                typo_whole = 1;
                break;
            default:
                guide_to_help(argv[0]);
                return 1;
                break;
        }
    }
    
    if (optind >= argc)
    {
        fprintf(stderr, "keyword missing\n");
        guide_to_help(argv[0]);
        return 1;
    }
    
    char *keyword = argv[optind];

    linereader reader = linereader_create(STDIN_FILENO);
    int count;
    while ((count = linereader_readline(reader)) != -1)
    {
        const char *line = reader->line_buffer;
        int match_count = -1;
        if (typo)
        {
            if (typo_match(line, count, keyword, typo_whole))
                match_count = 0;
        }
        else if (!match_firstletter_only)
        {
            match_count = match_line_with_keyword(line, count, keyword, MatchModeFull, ignore_case);

            if (match_count == -1 && match_firstletter)
            {
                match_count = match_line_with_keyword(line, count, keyword, MatchModeFirstLetter, ignore_case);
            }

        }
        else
        {
            match_count = match_line_with_keyword(line, count, keyword, MatchModeFirstLetter, ignore_case);
        }

        if (match_count != -1)
        {
            if (show_match_count)
                printf("%d\t%.*s\n", match_count, count, line);
            else
                printf("%.*s\n", count, line);
        }
    }
    linereader_free(reader);
    return 0;
}
