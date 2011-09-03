from hangul import *
import sys

hanja_table_file = None
if len(sys.argv)>2:
    hanja_table_file = sys.argv[1]

table = hanja_table_load(hanja_table_file);
while True:
    buf = sys.stdin.read(1024)
    if len(buf)==0:
        break
    list = hanja_table_match_prefix(table, buf);
    n = hanja_list_get_size(list);
    for i in range(n):
        key     = hanja_list_get_nth_key(list, i)
        value   = hanja_list_get_nth_value(list, i)
        comment = hanja_list_get_nth_comment(list, i)
        print "%s:%s:%s" % (key, value, comment)

hanja_table_delete(table)
