#include <stdio.h>
#include "pmalloc.h"
#include "Str.h"
#include "File.h"

int LastError = 0;

/* Read full file data. Filename is c_string */
struct Str *File_readfilefc (char *fname) {

	FILE *fd;
	size_t flen = 0, bytesread = 0;
	struct Str *outstr;

	if (fname == NULL) {
		LastError = File_ENAME;
		return NULL;
	}

	fd = fopen(fname, "rb");
	if (fd == NULL) {
		LastError = File_EOPEN;
		return NULL;
	}

	fseek(fd, 0, SEEK_END);
	flen = ftell(fd);
	if (flen == -1) {
		fclose(fd);
		LastError = File_ESEEK;
		return NULL;
	}

	if (fseek(fd, 0, SEEK_SET)) {
		fclose(fd);
		LastError = File_ESEEK;
		return NULL;
	}

	outstr = Str_new(flen+1);

	bytesread = fread(outstr->str, 1, flen, fd);
	fclose(fd);
	outstr->str[bytesread] = '\0';
	outstr->len = bytesread;

	return outstr;
}

/* Read full file data. Filename is Str_string */
struct Str *File_readfilef (struct Str *fname) {
	if (fname == NULL) {
		LastError = File_ENAME;
		return NULL;
	}
	return File_readfilefc(fname->str);
}

/* Read data in range (include bounds). Filename is c_string */
struct Str *File_readfilerc (char *fname, size_t frombyte, size_t tobyte) {

	FILE *fd;
	size_t rlen = 0, bytesread = 0;
	struct Str *outstr;

	if (fname == NULL) {
		LastError = File_ENAME;
		return NULL;
	}

	if (frombyte > tobyte) {
		LastError = File_ERANGE;
		return NULL;
	}

	fd = fopen(fname, "rb");
	if (fd == NULL) {
		LastError = File_EOPEN;
		return NULL;
	}

	fseek(fd, frombyte, SEEK_SET);
	if (ftell(fd) != frombyte) {
		fclose(fd);
		LastError = File_ESEEK;
		return NULL;
	}

	rlen = tobyte - frombyte + 1;
	outstr = Str_new(rlen+1);

	bytesread = fread(outstr->str, 1, rlen, fd);
	fclose(fd);
	outstr->str[bytesread] = '\0';
	outstr->len = bytesread;

	return outstr;
}

/* Read data in range (include bounds). Filename is Str_string */
struct Str *File_readfiler (struct Str *fname, size_t frombyte, size_t tobyte) {
	if (fname == NULL) {
		LastError = File_ENAME;
		return NULL;
	}
	return File_readfilerc(fname->str, frombyte, tobyte);
}

/* Write @data starting from @offset. Filename is c_string */
size_t File_writefilec (char *fname, size_t offset, struct Str *data) {

	FILE *fd;
	size_t byteswritten = 0;

	if (fname == NULL) {
		LastError = File_ENAME;
		return 0;
	}

	if (data == NULL) {
		LastError = File_EDATA;
		return 0;
	}

	/* touch file */
	fd = fopen(fname, "a+b");
	if (fd == NULL) {
		LastError = File_EOPEN;
		return 0;
	}
	fclose(fd);

	fd = fopen(fname, "r+b");
	if (fd == NULL) {
		LastError = File_EOPEN;
		return 0;
	}

	fseek(fd, offset, SEEK_SET);
	if (ftell(fd) != offset) {
		fclose(fd);
		LastError = File_ESEEK;
		return 0;
	}

	byteswritten = fwrite(data->str, 1, data->len, fd);
	fclose(fd);

	return byteswritten;
}

/* Write @data starting from @offset. Filename is Str_string */
size_t File_writefile (struct Str *fname, size_t offset, struct Str *data) {
	if (fname == NULL) {
		LastError = File_ENAME;
		return 0;
	}
	return File_writefilec(fname->str, offset, data);
}

size_t File_getlenc (char *fname) {
	FILE *fd;
	size_t flen = 0;

	if (fname == NULL) {
		LastError = File_ENAME;
		return 0;
	}

	fd = fopen(fname, "rb");
	if (fd == NULL) {
		LastError = File_EOPEN;
		return 0;
	}

	fseek(fd, 0, SEEK_END);
	flen = ftell(fd);
	if (flen == -1) {
		fclose(fd);
		LastError = File_ESEEK;
		return 0;
	}

	fclose(fd);

	return flen;
}

size_t File_getlen (struct Str *fname) {
	if (fname == NULL) {
		LastError = File_ENAME;
		return 0;
	}
	return File_getlenc(fname->str);
}

int File_getlasterror (void) {
	return LastError;
}

void File_clearerror (void) {
	LastError = 0;
}

