from hangul import *
import sys

hic = hangul_ic_new("2")

for ascii in raw_input():
    ret = hangul_ic_process(hic, ord(ascii))
    commit = hangul_ic_get_commit_string(hic)
    if len(commit)>0:
        sys.stdout.write(commit)
    if not ret:
        sys.stdout.write(ascii)

if not hangul_ic_is_empty(hic):
    commit = hangul_ic_flush(hic)
    if len(commit)>0:
        sys.stdout.write(commit)

hangul_ic_delete(hic);
sys.stdout.write('\n')
