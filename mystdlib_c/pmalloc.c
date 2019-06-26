#include <stdlib.h>
#include <stdio.h>

void *pmalloc (size_t size) {
	void *ptr;
	ptr = malloc(size);
	if (ptr == NULL) {
		printf("pmalloc(): cannot allocate memory (%d bytes)", size);
		exit(1);
	}
	return ptr;
}

