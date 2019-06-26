#include <stdlib.h>
#include <string.h>
#include "Str.h"

struct Str *Str_new (StrSize size) {
	struct Str *newstr;
	newstr = pmalloc(sizeof(struct Str));
	newstr->str = pmalloc(size + 1);
	memset(newstr->str, 0, size + 1);
	newstr->len = size;
	newstr->IsWrapped = 0;
	return newstr;
}

struct Str *Str_fromcstr (char *cstr, StrSize size) {
	struct Str *newstr;
	newstr = Str_new(size);
	memcpy(newstr->str, cstr, size + 1);
	newstr->IsWrapped = 0;
	return newstr;
}

struct Str *Str_wrap (char *cstr, StrSize size) {
	struct Str *newstr;
	newstr = pmalloc(sizeof(struct Str));
	newstr->str = cstr;
	newstr->len = size;
	newstr->IsWrapped = 1;
	return newstr;
}

void Str_destroy (struct Str *str) {
	if (!(str->IsWrapped)) {
		free(str->str);
		str->str = NULL;
	}
	free(str);
}

StrSize Str_getsize (struct Str *str) {
	return str->len;
}

char *Str_getcstr (struct Str *str) {
	return str->str;
}

