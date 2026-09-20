#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <wchar.h>
#include <thai/thbrk.h>
#include <thai/thwbrk.h>
#include <thai/thwctype.h>

#define WJ 0x2060

int main(int argc, char **argv) {
    setlocale(LC_ALL, "en_US.UTF-8");
    if (argc != 3) {
        fprintf(stderr, "usage: thaiwj IN OUT\n");
        return 2;
    }
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
    char *isbrk = calloc(wlen + 1, 1);
    {
        size_t wi = 0;
        for (size_t i = 0; i < olen; i++) {
            if (out[i] == WJ) {
                if (wi <= wlen) isbrk[wi] = 1;
            } else {
                wi++;
            }
        }
    }

    FILE *fout = fopen(argv[2], "w");
    if (!fout) { perror("open out"); return 1; }
    for (size_t i = 0; i < wlen; i++) {
        fputwc(w[i], fout);
        if (i + 1 < wlen && th_wcisthai(w[i]) && th_wcisthai(w[i + 1]) && !isbrk[i + 1]) {
            fputwc(WJ, fout);
        }
    }
    fclose(fout);
    th_brk_delete(brk);
    return 0;
}
