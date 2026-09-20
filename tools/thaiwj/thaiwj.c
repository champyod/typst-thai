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

#define MAXSYL 256

static wchar_t syl_word[MAXSYL][64];
static wchar_t syl_parts[MAXSYL][64];
static int nsyl = 0;

static void load_syllables(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return;
    char line[512];
    while (fgets(line, sizeof line, f) && nsyl < MAXSYL) {
        size_t len = mbstowcs(NULL, line, 0);
        if (len == (size_t)-1 || len >= 128) continue;
        wchar_t w[128];
        mbstowcs(w, line, 128);
        wchar_t *eq = wcschr(w, L'=');
        if (!eq) continue;
        *eq = 0;
        size_t wl = wcslen(w);
        while (wl > 0 && (w[wl - 1] == L'\n' || w[wl - 1] == L'\r')) w[--wl] = 0;
        if (wl == 0 || wl >= 64) continue;
        wcscpy(syl_word[nsyl], w);
        wcscpy(syl_parts[nsyl], eq + 1);
        size_t pl = wcslen(syl_parts[nsyl]);
        while (pl > 0 && (syl_parts[nsyl][pl - 1] == L'\n' || syl_parts[nsyl][pl - 1] == L'\r'))
            syl_parts[nsyl][--pl] = 0;
        nsyl++;
    }
    fclose(f);
}

static const wchar_t *find_syllables(const wchar_t *word, size_t len) {
    for (int i = 0; i < nsyl; i++) {
        if (wcslen(syl_word[i]) == len && wmemcmp(syl_word[i], word, len) == 0)
            return syl_parts[i];
    }
    return NULL;
}

int main(int argc, char **argv) {
    setlocale(LC_ALL, "en_US.UTF-8");
    if (argc < 3 || argc > 5) {
        fprintf(stderr, "usage: thaiwj IN OUT [--hyphen [SYLLABLES]]\n");
        return 2;
    }
    int hyphen = 0;
    for (int a = 3; a < argc; a++) {
        if (strcmp(argv[a], "--hyphen") == 0) hyphen = 1;
        else load_syllables(argv[a]);
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
            const wchar_t *syl = hyphen ? find_syllables(word, wn) : NULL;
            if (syl) {
                wchar_t parts[64];
                wcscpy(parts, syl);
                wchar_t *save = NULL;
                wchar_t *t = wcstok(parts, L"|", &save);
                int first = 1;
                while (t) {
                    if (!first) fputwc(SHY, fout);
                    first = 0;
                    for (size_t j = 0; t[j]; j++) {
                        fputwc(t[j], fout);
                        if (t[j + 1]) fputwc(WJ, fout);
                    }
                    t = wcstok(NULL, L"|", &save);
                }
            } else {
                for (size_t j = 0; j < wn; j++) {
                    fputwc(word[j], fout);
                    if (j + 1 < wn) fputwc(WJ, fout);
                }
            }
            wn = 0;
        }
        if (i < olen && out[i] != WJ) fputwc(out[i], fout);
    }
    fclose(fout);
    th_brk_delete(brk);
    return 0;
}
