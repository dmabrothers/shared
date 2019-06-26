#ifndef File_H
#define File_H

#include <stdio.h>
#include "pmalloc.h"
#include "Str.h"
#include "File.h"


#define File_ERANGE  1
#define File_EOPEN   2
#define File_ENAME   3
#define File_ESEEK   4
#define File_EDATA   5

/* Read full file data. Filename is c_string */
struct Str *File_readfilefc(char *fname);

/* Read full file data. Filename is Str_string */
struct Str *File_readfilef(struct Str *fname);

/* Read data in range (include bounds). Filename is c_string */
struct Str *File_readfilerc(char *fname, size_t frombyte, size_t tobyte);

/* Read data in range (include bounds). Filename is Str_string */
struct Str *File_readfiler(struct Str *fname, size_t frombyte, size_t tobyte);

/* Write @data starting from @offset. Filename is c_string */
size_t File_writefilec(char *fname, size_t offset, struct Str *data);

/* Write @data starting from @offset. Filename is Str_string */
size_t File_writefile(struct Str *fname, size_t offset, struct Str *data);

size_t File_getlenc(char *fname);

size_t File_getlen(struct Str *fname);

int File_getlasterror (void);

void File_clearerror (void);

#endif

