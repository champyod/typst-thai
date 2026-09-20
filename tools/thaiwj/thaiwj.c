#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <thai/thbrk.h>
#include <thai/thwbrk.h>
#include <thai/thwctype.h>

#define WJ 0x2060
#define SHY 0x00AD
#define HYPHEN_MIN_LEN 12

int main(int argc, char **argv) {
    setlocale(LC_ALL, "en_US.UTF-8");
    if (argc < 3 || argc > 4) {
        fprintf(stderr, "usage: thaiwj IN OUT [--hyphen]\n");
        return 2;
    }
    int hyphen = (argc == 4 && strcmp(argv[3], "--hyphen") == 0);
    FILE *fin = fopen(argv[1], "r");
    if (!fin) { perror("open in"); return 1; }
    fseek(fin, 0, SEEK_END);
    long n = ftell(fin);
    fseek(fin, 0, SEEK_SET);
    char *utf8 = malloc(n + 1);
    if (fread(utf8, 1, n, fin) != (size_t)n) { perror("read"); return 1; }
    fclose(fin);
    utf8[n] = 0;

    size_t wlen = mbstowcs(NULL, utf8, 0);
    wchar_t *w = malloc((wlen + 1) * sizeof(wchar_t));
    mbstowcs(w, utf8, wlen + 1);

    ThBrk *brk = th_brk_new(NULL);
    wchar_t *out = malloc((wlen * 2 + 1) * sizeof(wchar_t));
    th_brk_wc_insert_breaks(brk, w, out, wlen * 2 + 1, L"\u2060");

    size_t olen = wcslen(out);
    wchar_t *word = malloc((olen + 1) * sizeof(wchar_t));

    FILE *fout = fopen(argv[2], "w");
    if (!fout) { perror("open out"); return 1; }
    size_t wn = 0;
    for (size_t i = 0; i <= olen; i++) {
        int boundary = (i == olen) || !th_wcisthai(out[i]);
        if (!boundary) {
            word[wn++] = out[i];
            continue;
        }
        if (wn > 0) {
            wchar_t joiner = (hyphen && wn >= HYPHEN_MIN_LEN) ? SHY : WJ;
            for (size_t j = 0; j < wn; j++) {
                fputwc(word[j], fout);
                if (j + 1 < wn) fputwc(joiner, fout);
            }
            wn = 0;
        }
        if (i < olen && out[i] != WJ) fputwc(out[i], fout);
    }
    fclose(fout);
    th_brk_delete(brk);
    return 0;
}
