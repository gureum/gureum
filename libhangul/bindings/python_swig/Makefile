TARGET=_hangul.so
SWIG=swig
CC=gcc
PYTHON_CFLAGS=`python-config --cflags`
PYTHON_LIBS=`python-config --libs`
HANGUL_CFLAGS=`pkg-config --cflags libhangul`
HANGUL_LIBS=`pkg-config --libs libhangul`
CFLAGS+=-O2 -Wall

all: $(TARGET)

hangul_wrap.c: hangul.i
	$(SWIG) $(HANGUL_CFLAGS) -python hangul.i

hangul_wrap.o: hangul_wrap.c
	$(CC) $(CFLAGS) $(PYTHON_CFLAGS) $(HANGUL_CFLAGS) -c -fPIC -o $@ $<

_hangul.so: hangul_wrap.o
	$(CC) -shared -o $@ $< $(HANGUL_LIBS) 

clean:
	rm -f *.o *_wrap.c hangul.py* $(TARGET)
