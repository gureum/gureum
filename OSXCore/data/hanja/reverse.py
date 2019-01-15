#!/usr/bin/env python
import sys

if len(sys.argv) < 2:
    sys.stderr.write('usage: {} source_file\n'.format(sys.argv[0]))

dic = []

f = file(sys.argv[1])
for l in f:
    parts = l.split(':')
    if len(parts) != 3:
        sys.stdout.write(l)
    else:
        descriptions = parts[2].strip().split(',')
        for description in descriptions:
            dic.append((description, parts[1], parts[2]))

dic.sort()
for description, part1, part2 in dic:
    sys.stdout.write('{}:{}:{}'.format(description, part1, part2))
