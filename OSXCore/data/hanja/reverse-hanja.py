#!/usr/bin/env python3

import sys

header = []

compat_table = {}
freq_table = {}

def load_compat(filename):
    src = open(filename, 'r')
    for i in src.readlines():
        list = i.strip().split('\t')
        key = chr(int(list[0], 16))
        value = chr(int(list[1], 16))
        compat_table[key] = value
    src.close()

def get_unified(text):
    res = u''
    for i in text:
        if i in compat_table:
            res += compat_table[i]
        else:
            res += i
    return res

def load_frequency(filename):
    src = open(filename, 'rb')
    for i in src.readlines():
        list = i.strip().decode('utf-8').split(u':')
        key = list[0]
        value = float(list[1])
        if key in freq_table:
            freq_table[key] = max(freq_table[key], value)
        else:
            freq_table[key] = value

    src.close()

def get_frequency(key):
    if key in freq_table:
        return freq_table[key]
    else:
        return 0

# load freq table
load_frequency('freq-hanja.txt')
load_frequency('freq-hanjaeo.txt')

# load compatibility char table
load_compat('compat-table.txt')

table = {}
for file in sys.argv[1:]:
    src = open(file, 'rb')

    for line in src.readlines():
        if line.startswith(b'#'):
            header += line;
            continue;

        line = line.strip().decode('utf-8').split(u':')
        if len(line) < 3:
            continue

        key = line[0]
        value = get_unified(line[1])
        comment = line[2].strip()
        freq = get_frequency(value)

        if key in table:
            isDuplicate = False
            # check duplicate
            for i in table[key]:
                if i['value'] == value:
                    if len(comment) == 0:
                        sys.stderr.write('%s:%s is duplicate, ignored\n' % (key, value))
                        isDuplicate = True
                    else:
                        if len(i['comment']) == 0:
                            sys.stderr.write('%s:%s is duplicate, but has new comment, added: ' % (key, value))
                            sys.stderr.write('"%s"\n' % comment)
                            i['comment'] = comment
                            isDuplicate = True
                        elif i['comment'] == comment:
                            sys.stderr.write('%s:%s is duplicate, ignored\n' % (key, value))
                            isDuplicate = True
                        else:
                            # 기존의 테이블에 새로운 커멘트가 있는지 확인한다.
                            # 띄어쓰기로 다른 스트링으로 처리되는 문제를 피하기
                            # 위해서 빈칸을 지운다
                            res = i['comment'].replace(' ','').find(comment.replace(' ', ''))
                            if res >= 0:
                                sys.stderr.write('%s:%s is duplicate, already includes that comments, ignored\n' % (key, value))
                                isDuplicate = True
                            else:
                                sys.stderr.write('%s:%s is duplicate, but has different comments, merged: ' % (key, value))
                                sys.stderr.write('"%s" + "%s"\n' % (i['comment'], comment))
                                i['comment'] = i['comment'] + ', ' + comment
                                isDuplicate = True

            if not isDuplicate:
                table[key].append({ 'key' : key, 'value': value, 'freq': freq, 'comment': comment })
        else:
            table[key] = [ { 'key': key, 'value': value, 'freq': freq, 'comment': comment } ]

    src.close()

keys = list(table.keys())
keys.sort()

for i in header:
    sys.stdout.write(str(i))
sys.stdout.write('\n')

mtable = {}
for key in keys:
    tlist = table[key]
    key = key

    tlist.sort(key=lambda x: x['freq'])
    for i in tlist:
        value   = i['value']
        freq    = i['freq']
        comment = i['comment']
        comments = comment.split(', ')
        for c in comments:
            if not c: continue
            if c == key: continue
            if c == u'지명':
                continue
                c += ' ' + key
            if not c in mtable.keys():
                mtable[c] = []
            mtable[c].append(i)

keys = list(mtable.keys())
keys.sort()

for key in keys:
    if key < u'가': continue
    if key > u'힣': break
    list = mtable[key]

    list.sort(key=lambda x: x['freq'])
    for i in list:
        value   = i['value']
        freq    = i['freq']
        comment = i['comment']
        sys.stdout.write('%s:%s:%s\n' % (key, value, comment))

