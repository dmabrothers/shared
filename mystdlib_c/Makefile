build: libStr.so libFile.so

libStr.so: pmalloc.c pmalloc.h Str.c Str.h
	cc -shared -fPIC pmalloc.c Str.c -o libStr.so

libFile.so: pmalloc.c pmalloc.h Str.c Str.h File.c File.h
	cc -shared -fPIC pmalloc.c Str.c File.c -o libFile.so

clean:
	-@ rm -f *~ *.o libStr.so libFile.so test_1_bin str1_wr str2_wr

test_1_bin: libFile.so libStr.so test_1.c
	cc test_1.c -o test_1_bin -lStr -lFile -L.

test: build test_1_bin
	./test_1_bin

