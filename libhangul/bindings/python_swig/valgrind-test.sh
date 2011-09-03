#!/bin/sh
exec valgrind --tool=memcheck --leak-check=full python test_hangul.py $@

