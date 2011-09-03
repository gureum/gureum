#include <stdio.h>
#include <string.h>

#include "../hangul/hangul.h"

int
main(int argc, char *argv[])
{
    if (argc != 3)
	return 1;

    hanja_table_txt_to_bin(argv[1], argv[2]);

    return 0;
}
