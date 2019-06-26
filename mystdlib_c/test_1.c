/* File reading-writing test */

#include <stdio.h>
#include <stdlib.h>
#include "Str.h"
#include "File.h"

int main (int argc, char **argv)
{
	struct Str *str;
	struct Str *str1;
	struct Str *str2;
	size_t wrcount = 0;
	str = File_readfilefc("File.c");
	printf("File \"File.c\" contents:\n%s\n(%d bytes)\n", str->str, str->len);
	Str_destroy(str);

	str = File_readfilefc("libFile.so");
	printf("File \"libFile.so\" length: %d bytes\n", str->len);
	Str_destroy(str);

	str1 = File_readfilerc("File.c", 0, 5);
	printf("File \"File.c\" 0-5 bytes: %s\n", str1->str);

	str2 = File_readfilerc("File.c", 1, 5);
	printf("File \"File.c\" 1-5 bytes: %s\n", str2->str);

	str = File_readfilerc("File.c1", 1, 5);
	if (str == NULL) {
		printf("File_errno: %d\n", File_getlasterror());
	} else {
		Str_destroy(str);
		Str_destroy(str1);
		Str_destroy(str2);
		printf("\"raise error\" test failed: %d\n", File_getlasterror());
		exit(3);
	}

	wrcount = File_writefilec("str1_wr", 0, str1);
	if (wrcount != str1->len) {
		printf("\"write str1\" test failed: %d of %d bytes was written\n", wrcount, str1->len);
		exit(5);
	}
	wrcount = File_writefilec("str2_wr", 1, str2);
	if (wrcount != str2->len) {
		printf("\"write str2\" test failed: %d of %d bytes was written\n", wrcount, str2->len);
		exit(6);
	}

	Str_destroy(str1);
	Str_destroy(str2);

	printf("\"getlen\" File.c: %lu bytes\n", File_getlenc("File.c"));
	printf("\"getlen\" str1_wr: %lu bytes\n", File_getlenc("str1_wr"));
	printf("\"getlen\" str2_wr: %lu bytes\n", File_getlenc("str2_wr"));

	printf("test_1 is passed.\n");

	return 0;
}

