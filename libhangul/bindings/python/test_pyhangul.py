# coding: utf-8
#
# Author: Gyoung-Yoon Noh <nohmad@gmail.com>
# License: Same as libhangul.

import sys
import hangul
import unittest

class TestHangul(unittest.TestCase):
    def setUp(self):
        self.ic = hangul.create_ic('hangul2')

    def testSimpleString(self):
        input  = u"vkdlTjs gksrmf fkdlqmfjfl xptmxm"
        output = u"파이썬 한글 라이브러리 테스트"
        buffer = u''
        for i in input:
            ret = self.ic.process(ord(i))
            buffer += self.ic.commit_string()
            if not ret:
                buffer += str(i)
        buffer += self.ic.flush()
        buffer += self.ic.commit_string()
        self.assertEqual(output, buffer)

if __name__ == '__main__':
    unittest.main()
