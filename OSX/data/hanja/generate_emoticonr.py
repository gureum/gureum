"""
Generate a emotionr.txt from a emoji-test.txt
"""
from typing import Iterable
import logging

import unittest


def generate_emoticonr(filename: str = 'emoji-test.txt') -> int:
    """generate emoticonr from input file

    Args:
        Input filename
    Return:
        Number of written characters
    """
    data = []

    with open(filename, 'r', encoding='utf-8') as file:
        file_lines = file.readlines()

    qualified_lines = _get_fully_qualified_lines(file_lines)

    for line in qualified_lines:
        data.append(_get_emoticon_data(line))


    with open('emoticonr.txt', 'w') as file:
        for _, emoti, desc in data:
            num = file.write('{1}:{0}:{1}\n'.format(emoti, desc))

    return num


def _get_fully_qualified_lines(lines: list) -> Iterable[str]:
    """Get lines with fully qualified as a iterable"""
    return (l for l in lines if _is_valid_line(l))


def _is_valid_line(line: str) -> bool:
    """Check if the line is fully qualified"""
    if line.startswith('#'):
        return False
    if line.startswith('\n'):
        return False
    if 'non-fully-qualified' in line:
        return False
    return True


def _get_emoticon_data(line: str) -> tuple:
    """Extract the emoticon data from a line

    Args:
        a fully-qualified line
    Return:
        Unicode, Emoticon, Description
    """
    data = line.split('; fully-qualified')

    unicode = data[0].strip()

    bytes_num = len(unicode.split())
    emoticon = data[1].strip()[2:]

    description = emoticon[bytes_num+1:]
    emoticon = emoticon[0:bytes_num]

    return unicode, emoticon, description


class TestGenerateEmoticonr(unittest.TestCase):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_non_fully_qualified_line(self):
        line = '263A                                       ; non-fully-qualified # ☺ smiling face'
        self.assertFalse(_is_valid_line(line))

    def test_empty_line(self):
        line = '\n'
        self.assertFalse(_is_valid_line(line))

    def test_comment_line(self):
        line = '# subgroup: face-negative'
        self.assertFalse(_is_valid_line(line))

    def test_get_emoticon_data(self):
        lines = [
            '1F62F                                      ; fully-qualified     # 😯 hushed face',
            '2620 FE0F                                  ; fully-qualified     # ☠️ skull and crossbones',
            '1F469 1F3FC                                ; fully-qualified     # 👩🏼 woman: medium-light skin tone',
            '1F469 200D 2695 FE0F                       ; fully-qualified     # 👩‍⚕️ woman health worker',
            '1F3CA 1F3FB 200D 2642 FE0F                 ; fully-qualified     # 🏊🏻‍♂️ man swimming: light skin tone',
        ]

        unicode, emoti, desc = _get_emoticon_data(lines[0])
        self.assertEqual(unicode, '1F62F')
        self.assertEqual(emoti, '😯')
        self.assertEqual(desc, 'hushed face')
        unicode, emoti, desc = _get_emoticon_data(lines[1])
        self.assertEqual(unicode, '2620 FE0F')
        self.assertEqual(emoti, '☠️')
        self.assertEqual(desc, 'skull and crossbones')
        unicode, emoti, desc = _get_emoticon_data(lines[2])
        self.assertEqual(unicode, '1F469 1F3FC')
        self.assertEqual(emoti, '👩🏼')
        self.assertEqual(desc, 'woman: medium-light skin tone')
        unicode, emoti, desc = _get_emoticon_data(lines[3])
        self.assertEqual(unicode, '1F469 200D 2695 FE0F')
        self.assertEqual(emoti, '👩‍⚕️')
        self.assertEqual(desc, 'woman health worker')
        unicode, emoti, desc = _get_emoticon_data(lines[4])
        self.assertEqual(unicode, '1F3CA 1F3FB 200D 2642 FE0F')
        self.assertEqual(emoti, '🏊🏻‍♂️')
        self.assertEqual(desc, 'man swimming: light skin tone')


if __name__ == '__main__':
    unittest.main(exit=False)

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)-8s %(message)s'
    )

    try:
        generate_emoticonr()
        logging.info('emoticonr.txt has been created')
    except Exception as e:
        logging.error(e)
