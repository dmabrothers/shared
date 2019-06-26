#ifndef Str_H
#define Str_H

#include <stdlib.h>
#include "pmalloc.h"

typedef size_t StrSize;

struct Str {
	size_t len;
	char *str;
	char IsWrapped;
};

struct Str *Str_new(StrSize size);
struct Str *Str_wrap(char *cstr, StrSize size);
struct Str *Str_fromcstr(char *cstr, StrSize size);
void Str_destroy(struct Str *str);
StrSize Str_getsize(struct Str *str);
char *Str_getcstr(struct Str *str);

#endif
